class_name Present extends Node2D


# SIGNALS
signal opened
signal collected

# EXPORTS
export(int, 0, 64) var spriteHoverLimit = 20
export(float, 0, 10) var spriteHoverSpeed = 0.5

# VARS
onready var sprite: Sprite = $Sprite
var spriteHoverDirection: int = 1

# METHODS
func _ready():
	pass

func _process(_delta):
	_spriteHoverProcess()

func _spriteHoverProcess() -> void:
	if not is_instance_valid(sprite):
		return

	sprite.offset.y += spriteHoverSpeed if spriteHoverDirection == 1 else -spriteHoverSpeed

	if ((spriteHoverDirection == 1 and spriteHoverLimit <= sprite.offset.y)
	or (spriteHoverDirection == -1 and -spriteHoverLimit >= sprite.offset.y)):
		spriteHoverDirection = -spriteHoverDirection

func collect() -> void:
	$CollectSFX.play()
	$Area2D.queue_free()
	$Sprite.texture = load("res://assets/Sprites/presents/Present-Open.png")
	emit_signal("collected")

# SETTERS/GETTERS
func _onPresentTouched(_body):
	$OpenSFX.play()
	emit_signal("opened")
