class_name EndSign extends Node2D


# SIGNALS
signal playerReached

func _ready():
	pass

func _on_Area2D_body_entered(_body):
	emit_signal("playerReached")
