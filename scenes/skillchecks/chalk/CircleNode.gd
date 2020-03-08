extends "res://scenes/FittedHitboxObject.gd"

var idx
signal node_entered(idx)

func _init():
	type = "CircleNode"

func _on_CircleNode_mouse_entered():
	emit_signal("node_entered", idx)

func flash():
	print("node ", idx, " flashing")
	$Sprite.modulate = Color(0, 0, 1) # blue shade
	yield(get_tree().create_timer(0.4), "timeout")
	$Sprite.modulate = Color(1, 1, 1) # reset to default