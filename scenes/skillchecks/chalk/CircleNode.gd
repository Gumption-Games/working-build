extends "res://scenes/FittedHitboxObject.gd"

var idx
signal node_entered(idx)

func _init():
	type = "CircleNode"

func _on_CircleNode_mouse_entered():
	emit_signal("node_entered", idx)

func flash(c, delay):
	$Sprite.modulate = Color(int(c=='R'), int(c=='G'), int(c=='B')) # blue shade
	yield(get_tree().create_timer(delay), "timeout")
	$Sprite.modulate = Color(1, 1, 1) # reset to default