class_name DustCloud extends Node2D


# EXPORTS
export(float, 0, 10) var rotationSpeed = PI

# VARS
onready var sprite: Sprite = $Sprite
onready var animation: AnimationPlayer = $AnimationPlayer

func _ready():
	animation.play("DustCloudAnimation")

func _process(delta: float):
	sprite.rotate(rotationSpeed * delta)

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
