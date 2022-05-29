class_name StartScreen extends Node2D


# CONSTS
const firstLevelPath: String = "res://levels/Level-1/Level-1.tscn"

# VARS
onready var animation: AnimationPlayer = $AnimationPlayer
onready var ui: StartScreenUI = $CanvasLayer/StartScreenUI

func _input(event):
	# Left mouse button clicked during animation
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if animation.is_playing():
			animation.advance(6)
			get_tree().set_input_as_handled()

	# Pressed Enter during animation
	if event.is_action_pressed("ui_accept"):
		if animation.is_playing():
			animation.advance(6)
			get_tree().set_input_as_handled()

func _ready():
	_adjustSkyScale()

func _adjustSkyScale() -> void:
	# With a no-zoom viewport, sky bg fits nicely into the viewport at a 0.8 scale
	var noCameraZoomScale: Vector2 = Vector2(0.8, 0.8)

	var cameraZoom: Vector2 = $Camera2D.zoom

	var skyScale: Vector2 = Vector2(noCameraZoomScale.x * cameraZoom.x, noCameraZoomScale.y * cameraZoom.y)

	$ParallaxBackground/ParallaxLayer/Sky.scale = skyScale


func _on_AnimationPlayer_animation_finished(_anim_name):
	ui.enabled = true

func _on_StartScreenUI_startGame():
	var code: int = get_tree().change_scene(firstLevelPath)

	if OK != code:
		var error: String = "Can't open resource path for first level" if ERR_CANT_OPEN else "Couldn't instantiate level scene"
		push_error(error)
		print_stack()
		get_tree().quit()

func _on_StartScreenUI_exitGame():
	get_tree().quit()
