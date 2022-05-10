class_name Cherry extends Node2D


# SIGNALS
signal collected

# EXPORTS
export(int, 0, 64) var spriteHoverLimit = 20
export(float, 0, 10) var spriteHoverSpeed = 0.5

# VARS
onready var sprite: Sprite = $Sprite
var spriteHoverDirection: int = 1

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

func _on_Area2D_body_entered(_body):
	$CollectSFX.play()
	emit_signal("collected")
	sprite.queue_free()
	$Area2D.queue_free()


func _on_CollectSFX_finished():
	queue_free()
