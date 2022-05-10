class_name WallSlidingDetector extends Node2D


# VARS
var topLeft: Array = []
var bottomLeft: Array = []
var topRight: Array = []
var bottomRight: Array = []

enum COLLISION_SIDE { LEFT, RIGHT }
var collisionSide = null

# METHODS
func _ready():
	pass

func _physics_process(_delta):
	_setCollisionSide()

func _setCollisionSide() -> void:
	if not topLeft.empty() and not bottomLeft.empty():
		collisionSide = COLLISION_SIDE.LEFT
	elif not topRight.empty() and not bottomRight.empty():
		collisionSide = COLLISION_SIDE.RIGHT
	else:
		collisionSide = null

func _on_TopLeft_body_entered(body:Node):
	match body.get_class():
		"TileMap":
			if not body in topLeft:
				topLeft.append(body)
		_:
			pass

func _on_TopLeft_body_exited(body:Node):
	match body.get_class():
		"TileMap":
			topLeft.erase(body)
		_:
			pass

func _on_TopRight_body_entered(body:Node):
	match body.get_class():
		"TileMap":
			if not body in topRight:
				topRight.append(body)
		_:
			pass

func _on_TopRight_body_exited(body:Node):
	match body.get_class():
		"TileMap":
			topRight.erase(body)
		_:
			pass

func _on_BottomLeft_body_entered(body:Node):
	match body.get_class():
		"TileMap":
			if not body in bottomLeft:
				bottomLeft.append(body)
		_:
			pass

func _on_BottomLeft_body_exited(body:Node):
	match body.get_class():
		"TileMap":
			bottomLeft.erase(body)
		_:
			pass

func _on_BottomRight_body_entered(body:Node):
	match body.get_class():
		"TileMap":
			if not body in bottomRight:
				bottomRight.append(body)
		_:
			pass

func _on_BottomRight_body_exited(body:Node):
	match body.get_class():
		"TileMap":
			bottomRight.erase(body)
		_:
			pass

func getCollisionSide() -> int:
	if COLLISION_SIDE.LEFT == collisionSide:
		return -1
	if COLLISION_SIDE.RIGHT == collisionSide:
		return 1

	return 0
