extends Node2D


# PRELOADS
const cherryScene: PackedScene = preload("res://collectibles/Cherry/Cherry.tscn")
const EndScreenUIScene: PackedScene = preload("res://UI/end-screen/EndScreenUI.tscn")

# EXPORTS
export var levelBounds: Dictionary = {
	"top": -440,
	"right": 8568,
	"bottom": 2944,
	"left": -384
}
export(int, 0, 2048, 32) var cliffCameraBottomBound = 1024
export(int, 0, 100) var playerBottomBoundOffset = 40
export(int, 30, 1800, 30) var timerStart = 300
export(String, MULTILINE) var victoryMessage = "Congratulations! You escaped the cave!\nWould you like to play again?"
export(String, MULTILINE) var timeoutMessage = "Oh no! You ran out of time and died mysteriously...\nWould you like to play again?"
export(String, MULTILINE) var fallMessage = "Ouch! That must've hurt. Why would you jump off the cliff like that!?\nWould you like to play again?"

# VARS
onready var player: Player = $Player
onready var timer: TimerUI = $CanvasLayer/TimerUI
onready var collectibles: Node2D = $Collectibles
onready var scoreCounter: ScoreUI = $CanvasLayer/ScoreUI
var score: int = 0
var endScreenMessage: String = "Your message here..."
var paused: bool = false
var currentLevelBounds: Dictionary

func _ready():
	currentLevelBounds = {
		"top": levelBounds.top,
		"right": levelBounds.right,
		"bottom": cliffCameraBottomBound,
		"left": levelBounds.left
	}

	setupCherryCollectibles()
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
	if player.position.x - playerExtents.x < currentLevelBounds.left:
		player.position.x = currentLevelBounds.left + playerExtents.x
	if player.position.x + playerExtents.x > currentLevelBounds.right:
		player.position.x = currentLevelBounds.right - playerExtents.x

	# Player fell off level bounds
	if player.position.y + playerExtents.y > currentLevelBounds.bottom + playerBottomBoundOffset:
		endScreenMessage = fallMessage
		killPlayer()

func adjustSkyScale() -> void:
	# With a no-zoom viewport, sky bg fits nicely into the viewport at a 0.8 scale
	var noCameraZoomScale: Vector2 = Vector2(0.8, 0.8)

	var cameraZoom: Vector2 = $Player/PlayerCamera.zoom

	var skyScale: Vector2 = Vector2(noCameraZoomScale.x * cameraZoom.x, noCameraZoomScale.y * cameraZoom.y)

	$ParallaxBackground/ParallaxLayer/Sky.scale = skyScale

# Replaces all cherry tiles on `Collectibles and Signs` tilemap with `Cherry` scenes.
# Also sets-up the maximum score counter in `ScoreUI`
# Found in https://www.reddit.com/r/godot/comments/6vg5v8/using_tilemaps_for_more_advanced_objects/dm26wy7/
func setupCherryCollectibles() -> void:
	var debugString: String = "Replaced %s cherry tiles at the following positions:\n"

	var cherryCount: int = 0

	# Get tilemap information
	var tileMap: TileMap = $"Collectible Tiles"
	var cellSizeX: float = tileMap.get_cell_size().x
	var cellSizeY: float = tileMap.get_cell_size().y
	var tileSet: TileSet = tileMap.get_tileset()
	var usedCells: Array = tileMap.get_used_cells()

	# Iterate over tilemap to find and replace cherry tiles
	for position in usedCells:
		var id: int = tileMap.get_cell(position.x, position.y)
		var name: String = tileSet.tile_get_name(id)
		if name == "Present-Closed.png 0":
			# Create and place cherry entity on tilemap position
			var node = cherryScene.instance()
			node.position = Vector2( position.x * cellSizeX + (0.5*cellSizeX), position.y * cellSizeY + (0.5*cellSizeY))
			collectibles.add_child(node)

			# Remove cherry tile from tilemap
			tileMap.set_cell(position.x, position.y, -1)

			# Setup signal
			node.connect("collected", self, "onCherryCollected")

			cherryCount += 1

			debugString += "(%s, %s) " % [node.position.x, node.position.y]

	scoreCounter.setMaxScore(cherryCount)

	print_debug(debugString % cherryCount)

func endGame() -> void:
	player.paused = true

	var endScreen = EndScreenUIScene.instance()
	endScreen.enabled = true
	endScreen.text = endScreenMessage
	endScreen.connect("restartGame", self, "onRestartGame")
	endScreen.connect("backToStartScreen", self, "onBackToStartScreen")
	$CanvasLayer.add_child(endScreen)

func onCherryCollected() -> void:
	score += 1
	scoreCounter.setScore(score)

func _on_StartSign_playerHasCrossed():
	if not timer.isRunning():
		timer.start(timerStart)

func _on_EndSign_playerReached():
	timer.pause()
	paused = true
	endScreenMessage = victoryMessage
	endGame()

func onRestartGame() -> void:
	var code: int = get_tree().reload_current_scene()

	if OK != code:
		var error: String = "Can't open resource path for Level_1" if ERR_CANT_OPEN else "Couldn't instantiate Level_1 scene"
		push_error(error)
		print_stack()
		get_tree().quit()

func onBackToStartScreen() -> void:
	var code: int = get_tree().change_scene("res://levels/StartScreen/StartScreen.tscn")

	if OK != code:
		var error: String = "Can't open resource path for StartScreen" if ERR_CANT_OPEN else "Couldn't instantiate StartScreen scene"
		push_error(error)
		print_stack()
		get_tree().quit()

func _on_TimerUI_timeout():
	endScreenMessage = timeoutMessage
	killPlayer()

func killPlayer() -> void:
	timer.pause()
	paused = true
	player.kill()

func _on_Player_died():
	endGame()

# Determines if player is in cliff area or not and adjusts level bounds accordingly
func _on_Entrance_body_exited(body):
	var entrance: Area2D = $Entrance
	if body.position.x < entrance.position.x:
		currentLevelBounds.bottom = cliffCameraBottomBound
	else:
		currentLevelBounds.bottom = levelBounds.bottom

	setCameraBounds()
