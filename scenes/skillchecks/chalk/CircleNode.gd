extends "res://scenes/FittedHitboxObject.gd"

var idx
signal node_entered(idx)

func _init():
	type = "CircleNode"

func _on_CircleNode_mouse_entered():
	emit_signal("node_entered", idx)