class_name Level extends Node2D


# PRELOADS


const _presentScene: PackedScene = preload("res://collectibles/Present/Present.tscn")


# EXPORTS


export(String) var _nextLevelPath: String = "res://levels/Level-2/Level-2.tscn"
export(int, 0) var _minimumPresentsColected = 3 setget _setMinimumPresentsCollected
export var _levelBounds: Dictionary = {
	"top": -440,
	"right": 8568,
	"bottom": 2944,
	"left": -384
}
export(bool) var _hasCliff = true
export(int, 0, 2048, 32) var _cliffCameraBottomBound = 1024
export(int, 0, 100) var _playerBottomBoundOffset = 40
export(String, MULTILINE) var _victoryMessage = "Chegaste ao fim do nível!"
export(String, MULTILINE) var _timeoutMessage = "Oh no! You ran out of time and died mysteriously...\nWould you like to play again?"
export(String, MULTILINE) var _fallMessage = "Essa deve ter doído...\nQueres tentar outra vez?"


# VARS


onready var _player: Player = $Player
onready var _timer: TimerUI = $CanvasLayer/TimerUI
onready var _collectibles: Node2D = $Collectibles
onready var _scoreCounter: ScoreUI = $CanvasLayer/ScoreUI
onready var _endScreen: EndScreenUI = $CanvasLayer/EndScreenUI
var _score: int = 0
var _paused: bool = false	# TODO: add setter
var _currentLevelBounds: Dictionary


# METHODS - NODE PROCESSES


func _enter_tree():
	_currentLevelBounds = {
		"top": _levelBounds.top,
		"right": _levelBounds.right,
		"bottom": _cliffCameraBottomBound if _hasCliff else _levelBounds.bottom,
		"left": _levelBounds.left
	}

func _ready():
	_setupPresentCollectibles()
	_setCameraBounds()
	_adjustSkyScale()
	_setMinimumPresentsCollected(_minimumPresentsColected)

func _process(_delta):
	if _paused:
		return

	_lockPlayerInLevelBounds()


# METHODS - SETTERS & GETTERS


func _setMinimumPresentsCollected(minimumPresentsColectedValue: int) -> void:
	if minimumPresentsColectedValue < 0:
		minimumPresentsColectedValue = 0
	if _collectibles and minimumPresentsColectedValue > _collectibles.get_children().size():
		minimumPresentsColectedValue = _collectibles.get_children().size()

	_minimumPresentsColected = minimumPresentsColectedValue

	_updateCanLevelEnd()


# METHODS - PUBLIC


# Called after generating quiz sets to store each quiz in a present
func setupPresentQuizzes() -> void:
	for present in _collectibles.get_children():
		var quiz: Dictionary = QuizGenerator.getNextQuiz()
		# If no more quizzes were generated, remove present from scene
		if quiz.empty():
			present.queue_free()
			continue

		# Assign next quiz to present
		present.quiz = quiz


# METHODS - PRIVATE


# Replaces all present tiles on `Collectible Tiles` tilemap with `Present` scenes.
# Also sets-up the maximum score counter in `ScoreUI`
# Found in https://www.reddit.com/r/godot/comments/6vg5v8/using_tilemaps_for_more_advanced_objects/dm26wy7/
func _setupPresentCollectibles() -> void:
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
		var node = _presentScene.instance()
		node.position = Vector2( position.x * cellSize.x + (0.5*cellSize.x), position.y * cellSize.y + (0.5*cellSize.y))
		_collectibles.add_child(node)

		# Remove present tile from tilemap
		tileMap.set_cell(position.x, position.y, -1)

		# Setup signals
		node.connect("opened", self, "_onPresentOpened")
		node.connect("collected", self, "_onPresentCollected")

		presentCount += 1

		debugString += "(%s, %s) " % [node.position.x, node.position.y]

	_scoreCounter.maxScore = presentCount

	print_debug("\n", debugString % presentCount, "\n")

# Keep the player's camera inside the level's boundaries
func _setCameraBounds() -> void:
	var camera: Camera2D = _player.get_node("PlayerCamera")
	camera.limit_top = _currentLevelBounds.top
	camera.limit_right = _currentLevelBounds.right
	camera.limit_bottom = _currentLevelBounds.bottom
	camera.limit_left = _currentLevelBounds.left

# Make the sky background fill the entire viewport
func _adjustSkyScale() -> void:
	# With a no-zoom viewport, sky bg fits nicely into the viewport at a 0.8 scale
	var noCameraZoomScale: Vector2 = Vector2(0.8, 0.8)
	var cameraZoom: Vector2 = $Player/PlayerCamera.zoom
	var skyScale: Vector2 = Vector2(noCameraZoomScale.x * cameraZoom.x, noCameraZoomScale.y * cameraZoom.y)
	$ParallaxBackground/ParallaxLayer/Sky.scale = skyScale

# Keep the player inside the level's boundaries, except the bottom boundary, which kills them when they go bellow it
# Used in `_process()`
func _lockPlayerInLevelBounds() -> void:
	var playerExtents: Vector2 = (_player.get_node("CollisionShape2D").shape as RectangleShape2D).extents
	if _player.position.y - playerExtents.y < _currentLevelBounds.top:
		_player.position.y = _currentLevelBounds.top + playerExtents.y
		_player.velocity.y = 0
	if _player.position.x - playerExtents.x < _currentLevelBounds.left:
		_player.position.x = _currentLevelBounds.left + playerExtents.x
		_player.velocity.x = 0
	if _player.position.x + playerExtents.x > _currentLevelBounds.right:
		_player.position.x = _currentLevelBounds.right - playerExtents.x
		_player.velocity.x = 0

	# Player fell off level bounds
	if _player.position.y + playerExtents.y > _currentLevelBounds.bottom + _playerBottomBoundOffset:
		_endScreen.message = _fallMessage
		_endScreen.showNextLevelButton = false
		_killPlayer()

# Check if the player has collected the minimum number of presents to proceed to the next level and updates the `EndSign`'s state
func _updateCanLevelEnd() -> void:
	var endSign: EndSign = $Signs/EndSign
	if not _scoreCounter or not endSign:
		return

	endSign.levelCanEnd = _scoreCounter.score >= _minimumPresentsColected

# Kill the player, pausing the level and the level timer
# This triggers the player's death animation, so the timer is paused here, instead of waiting for the animation to finish
func _killPlayer() -> void:
	_timer.paused = true
	_paused = true
	_player.kill()

# Show the end screen, pausing the player
func _endLevel() -> void:
	_player.paused = true
	_endScreen.enabled = true
	_endScreen.visible = true


# METHODS - SIGNAL CALLBACKS


func _onPresentOpened() -> void:
	_player.paused = true

func _onPresentCollected() -> void:
	_scoreCounter.score = _scoreCounter.score + 1
	_player.paused = false
	_updateCanLevelEnd()

func _onPlayerCrossedStartSign():
	if not _timer.isRunning():
		_timer.start()

func _onPlayerReachedEndOfLevel():
	_timer.paused = true
	_paused = true
	_endScreen.message = _victoryMessage
	_endScreen.showNextLevelButton = true if _nextLevelPath else false
	_endLevel()

func _onGoToNextLevel() -> void:
	var code: int = get_tree().change_scene(_nextLevelPath)

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
	_endScreen.message = _timeoutMessage
	_endScreen.showNextLevelButton = false
	_killPlayer()

func _onPlayerDied():
	_endLevel()

# Determines if player is in cliff area or not and adjusts level bounds accordingly
func _onPlayerExitedEntrance(body):
	var entrance: Area2D = $Entrance
	if body.position.x < entrance.position.x:
		_currentLevelBounds.bottom = _cliffCameraBottomBound
	else:
		_currentLevelBounds.bottom = _levelBounds.bottom

	_setCameraBounds()
