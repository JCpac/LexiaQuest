class_name EndSign extends Node2D


# SIGNALS
signal playerReached

# EXPORTS
export(int, 0, 255, 8) var hitboxHeight: int = 64

# METHODS
func _ready():
	_setHitBoxShapeAndPosition()

func _setHitBoxShapeAndPosition() -> void:
	var hitbox: CollisionShape2D = $Area2D/CollisionShape2D
	var hitboxShape: RectangleShape2D = hitbox.shape
	hitboxShape.extents.y = hitboxHeight / 2
	hitbox.position.y = -hitboxShape.extents.y / 2

func _on_Area2D_body_entered(_body):
	emit_signal("playerReached")
