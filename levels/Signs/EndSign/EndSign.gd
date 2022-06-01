class_name EndSign extends Node2D


# SIGNALS


signal playerReached


# EXPORTS


export(int, 0, 255, 8) var _hitboxHeight: int = 64
export(float, 0, 10, 0.1) var _levelUnlockSfxDelay: float = 1


# VARS


var levelCanEnd: bool = false setget _setLevelCanEnd


# METHODS - NODE PROCESSES


func _ready():
	_setHitBoxShapeAndPosition()


# METHODS - SETTERS & GETTERS


func _setLevelCanEnd(levelCanEndValue: bool) -> void:
	if levelCanEnd == levelCanEndValue:
		return

	levelCanEnd = levelCanEndValue

	$MinimumPresentsBarrier/CollisionShape2D.disabled = levelCanEnd
	if levelCanEnd:
		yield(get_tree().create_timer(_levelUnlockSfxDelay), "timeout")
		$NextLevelUnlockedSFX.play()


# METHODS - PRIVATE


func _setHitBoxShapeAndPosition() -> void:
	var hitboxLevelEnd: CollisionShape2D = $Area2D/CollisionShape2D
	var hitboxLevelEndShape: RectangleShape2D = hitboxLevelEnd.shape
	hitboxLevelEndShape.extents.y = _hitboxHeight / 2
	hitboxLevelEnd.position.y = -hitboxLevelEndShape.extents.y / 2

	var hitboxBarrier: CollisionShape2D = $MinimumPresentsBarrier/CollisionShape2D
	var hitboxBarrierShape: RectangleShape2D = hitboxBarrier.shape
	hitboxBarrierShape.extents.y = _hitboxHeight / 2
	hitboxBarrier.position.y = -hitboxBarrierShape.extents.y / 2


# METHODS - SIGNAL CALLBACKS


func _onPlayerReached(_body):
	if levelCanEnd:
		$LevelEndSFX.play()
		emit_signal("playerReached")
