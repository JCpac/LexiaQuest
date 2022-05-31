class_name Level extends Node2D


# PRELOADS & CONSTS
const presentScene: PackedScene = preload("res://collectibles/Present/Present.tscn")

const DB_PATH: String = "res://assets/Database/db.json"

# EXPORTS
export(String) var nextLevelPath: String = "res://levels/Level-2/Level-2.tscn"
export var levelBounds: Dictionary = {
	"top": -440,
	"right": 8568,
	"bottom": 2944,
	"left": -384
}
export(bool) var hasCliff = true
export(int, 0, 2048, 32) var cliffCameraBottomBound = 1024
export(int, 0, 100) var playerBottomBoundOffset = 40
export(int, 30, 1800, 30) var timerStart = 300
export(String, MULTILINE) var victoryMessage = "Chegaste ao fim do nível!"
export(String, MULTILINE) var timeoutMessage = "Oh no! You ran out of time and died mysteriously...\nWould you like to play again?"
export(String, MULTILINE) var fallMessage = "Essa deve ter doído...\nQueres tentar outra vez?"

# VARS
onready var player: Player = $Player
onready var timer: TimerUI = $CanvasLayer/TimerUI
onready var collectibles: Node2D = $Collectibles
onready var scoreCounter: ScoreUI = $CanvasLayer/ScoreUI
onready var quizCompleteTimer: Timer = $QuizCompleteTimer
onready var endScreen: EndScreenUI = $CanvasLayer/EndScreenUI
onready var quiz: Dictionary = {
	matchImage = $"CanvasLayer/Quiz-FourChoices",
	matchWord = $"CanvasLayer/Quiz-Syllables",
	hangman = $"CanvasLayer/Quiz-Hangman"
}
var score: int = 0
var paused: bool = false
var currentLevelBounds: Dictionary
var currentPresent: Present

# METHODS
func _enter_tree():
	currentLevelBounds = {
		"top": levelBounds.top,
		"right": levelBounds.right,
		"bottom": cliffCameraBottomBound if hasCliff else levelBounds.bottom,
		"left": levelBounds.left
	}

func _ready():
	setupPresentCollectibles()
	setCameraBounds()
	adjustSkyScale()

func _process(_delta):
	if paused:
		return

	lockPlayerInLevelBounds()

func setCameraBounds() -> void:
	var camera: Camera2D = player.get_node("PlayerCamera")
	camera.limit_top = currentLevelBounds.top
	camera.limit_right = currentLevelBounds.right
	camera.limit_bottom = currentLevelBounds.bottom
	camera.limit_left = currentLevelBounds.left

func lockPlayerInLevelBounds() -> void:
	var playerExtents: Vector2 = (player.get_node("CollisionShape2D").shape as RectangleShape2D).extents
	if player.position.y - playerExtents.y < currentLevelBounds.top:
		player.position.y = currentLevelBounds.top + playerExtents.y
		player.velocity.y = 0
	if player.position.x - playerExtents.x < currentLevelBounds.left:
		player.position.x = currentLevelBounds.left + playerExtents.x
		player.velocity.x = 0
	if player.position.x + playerExtents.x > currentLevelBounds.right:
		player.position.x = currentLevelBounds.right - playerExtents.x
		player.velocity.x = 0

	# Player fell off level bounds
	if player.position.y + playerExtents.y > currentLevelBounds.bottom + playerBottomBoundOffset:
		endScreen.message = fallMessage
		endScreen.showNextLevelButton = false
		killPlayer()

func adjustSkyScale() -> void:
	# With a no-zoom viewport, sky bg fits nicely into the viewport at a 0.8 scale
	var noCameraZoomScale: Vector2 = Vector2(0.8, 0.8)

	var cameraZoom: Vector2 = $Player/PlayerCamera.zoom

	var skyScale: Vector2 = Vector2(noCameraZoomScale.x * cameraZoom.x, noCameraZoomScale.y * cameraZoom.y)

	$ParallaxBackground/ParallaxLayer/Sky.scale = skyScale

# Replaces all present tiles on `Collectible Tiles` tilemap with `Present` scenes.
# Also sets-up the maximum score counter in `ScoreUI`
# Found in https://www.reddit.com/r/godot/comments/6vg5v8/using_tilemaps_for_more_advanced_objects/dm26wy7/
func setupPresentCollectibles() -> void:
	var debugString: String = "Replaced %s present tiles at the following positions:\n"

	var presentCount: int = 0

	# Get tilemap information
	var tileMap: TileMap = $"Collectible Tiles"
	var cellSize: Vector2 = tileMap.get_cell_size()
	var usedCells: Array = tileMap.get_used_cells()

	# Iterate over tilemap to find and replace present tiles
	for position in usedCells:
		# Create and place present instance on tile position
		# Tile positions are cell-based, so must multiply by cell size to get positions in the scene
		# Tile positions in the scene are top-left-corner-based and present positions are centered,
		# so must add half the cell size on each axis when placing presents on tiles
		var node = presentScene.instance()
		node.position = Vector2( position.x * cellSize.x + (0.5*cellSize.x), position.y * cellSize.y + (0.5*cellSize.y))
		collectibles.add_child(node)

		# Remove present tile from tilemap
		tileMap.set_cell(position.x, position.y, -1)

		# Setup signals
		node.connect("opened", self, "onPresentOpened", [node])
		node.connect("collected", self, "onPresentCollected")

		presentCount += 1

		debugString += "(%s, %s) " % [node.position.x, node.position.y]

	scoreCounter.setMaxScore(presentCount)

	print_debug("\n", debugString % presentCount, "\n")

# Called after generating quiz sets to store each quiz in a present
func setupPresentQuizzes() -> void:
	for present in collectibles.get_children():
		var quiz: Dictionary = QuizGenerator.getNextQuiz()
		# If no more quizzes were generated, remove present from scene
		if quiz.empty():
			present.queue_free()
			continue

		# Assign next quiz to present
		present.quiz = quiz

func killPlayer() -> void:
	timer.pause()
	paused = true
	player.kill()

func endLevel() -> void:
	player.paused = true
	endScreen.enabled = true
	endScreen.visible = true

# SIGNAL CALLBACKS
func onPresentOpened(present: Present) -> void:
	player.paused = true
	currentPresent = present

	match present.quiz.quizType:
		QuizGenerator.QUIZ_TYPES.MATCH_IMAGE:
			assert(quiz.matchImage, "'Match Image' quiz was opened, but no 'Quiz-FourChoices' instance exists in scene tree")
			quiz.matchImage.prepareQuiz(present.quiz.target, present.quiz.extraAnswers)
			quiz.matchImage.visible = true

		QuizGenerator.QUIZ_TYPES.STARTS_WITH:
			assert(quiz.matchWord, "'Starts With' quiz was opened, but no 'Quiz-Syllables' instance exists in scene tree")
			quiz.matchWord.prepareQuiz(present.quiz.target, present.quiz.correctAnswers, present.quiz.wrongAnswers, present.quiz.quizType)
			quiz.matchWord.visible = true

		QuizGenerator.QUIZ_TYPES.RHYMES_WITH:
			assert(quiz.matchWord, "'Rhymes With' quiz was opened, but no 'Quiz-Syllables' instance exists in scene tree")
			quiz.matchWord.prepareQuiz(present.quiz.target, present.quiz.correctAnswers, present.quiz.wrongAnswers, present.quiz.quizType)
			quiz.matchWord.visible = true

		QuizGenerator.QUIZ_TYPES.HANGMAN:
			assert(quiz.hangman, "'Hangman' quiz was opened, but no 'Quiz-Hangman' instance exists in scene tree")
			quiz.hangman.prepareQuiz(present.quiz.target, present.quiz.hiddenTarget, present.quiz.answers)
			quiz.hangman.visible = true

		_:
			assert(false, "The value '%s' does not exist in 'QuizGenerator.QUIZ_TYPES'" % present.quiz.quizType)

func _onQuizCompleted():
	quizCompleteTimer.start()
	yield(quizCompleteTimer, "timeout")

	currentPresent.collect()
	currentPresent = null

func onPresentCollected() -> void:
	score += 1
	scoreCounter.setScore(score)
	player.paused = false
	if quiz.matchImage:
		quiz.matchImage.visible = false
	if quiz.matchWord:
		quiz.matchWord.visible = false
	if quiz.hangman:
		quiz.hangman.visible = false

func _onPlayerCrossedStartSign():
	if not timer.isRunning():
		timer.start(timerStart)

func _onPlayerReachedEndOfLevel():
	timer.pause()
	paused = true
	endScreen.message = victoryMessage
	endScreen.showNextLevelButton = true if self.nextLevelPath else false
	endLevel()

func _onGoToNextLevel() -> void:
	var code: int = get_tree().change_scene(nextLevelPath)

	if OK != code:
		var error: String = "Can't open resource path for next level" if ERR_CANT_OPEN else "Couldn't instantiate next level scene"
		push_error(error)
		print_stack()
		get_tree().quit()

func _onRestartLevel() -> void:
	var code: int = get_tree().reload_current_scene()

	if OK != code:
		var error: String = "Can't open resource path for current level" if ERR_CANT_OPEN else "Couldn't instantiate current level scene"
		push_error(error)
		print_stack()
		get_tree().quit()

func _onBackToStartScreen() -> void:
	var code: int = get_tree().change_scene("res://levels/StartScreen/StartScreen.tscn")

	if OK != code:
		var error: String = "Can't open resource path for StartScreen" if ERR_CANT_OPEN else "Couldn't instantiate StartScreen scene"
		push_error(error)
		print_stack()
		get_tree().quit()

func _onTimerTimeout():
	endScreen.message = timeoutMessage
	endScreen.showNextLevelButton = false
	killPlayer()

func _onPlayerDied():
	endLevel()

# Determines if player is in cliff area or not and adjusts level bounds accordingly
func _onPlayerExitedEntrance(body):
	var entrance: Area2D = $Entrance
	if body.position.x < entrance.position.x:
		currentLevelBounds.bottom = cliffCameraBottomBound
	else:
		currentLevelBounds.bottom = levelBounds.bottom

	setCameraBounds()
