class_name WallSlidingDetector extends Node2D


# ENUMS
enum COLLISION_SIDE { LEFT, RIGHT }

# VARS
var _topLeft: Array = []
var _bottomLeft: Array = []
var _topRight: Array = []
var _bottomRight: Array = []
var _collisionSide = null

# METHODS
func _physics_process(_delta):
	_setCollisionSide()

func _setCollisionSide() -> void:
	if not _topLeft.empty() and not _bottomLeft.empty():
		_collisionSide = COLLISION_SIDE.LEFT
	elif not _topRight.empty() and not _bottomRight.empty():
		_collisionSide = COLLISION_SIDE.RIGHT
	else:
		_collisionSide = null

func _on_TopLeft_body_entered(body:Node):
	match body.get_class():
		"TileMap":
			if not body in _topLeft:
				_topLeft.append(body)
		_:
			pass

func _on_TopLeft_body_exited(body:Node):
	match body.get_class():
		"TileMap":
			_topLeft.erase(body)
		_:
			pass

func _on_TopRight_body_entered(body:Node):
	match body.get_class():
		"TileMap":
			if not body in _topRight:
				_topRight.append(body)
		_:
			pass

func _on_TopRight_body_exited(body:Node):
	match body.get_class():
		"TileMap":
			_topRight.erase(body)
		_:
			pass

func _on_BottomLeft_body_entered(body:Node):
	match body.get_class():
		"TileMap":
			if not body in _bottomLeft:
				_bottomLeft.append(body)
		_:
			pass

func _on_BottomLeft_body_exited(body:Node):
	match body.get_class():
		"TileMap":
			_bottomLeft.erase(body)
		_:
			pass

func _on_BottomRight_body_entered(body:Node):
	match body.get_class():
		"TileMap":
			if not body in _bottomRight:
				_bottomRight.append(body)
		_:
			pass

func _on_BottomRight_body_exited(body:Node):
	match body.get_class():
		"TileMap":
			_bottomRight.erase(body)
		_:
			pass

func getCollisionSide() -> int:
	if COLLISION_SIDE.LEFT == _collisionSide:
		return -1
	if COLLISION_SIDE.RIGHT == _collisionSide:
		return 1

	return 0
