extends FittedHitboxObject

var chalk


func _ready():
	chalk = get_parent()


func _on_ChalkIcon_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			# Object is picked up
			dragging = true
		else:
			# Held object is being dropped
			dragging = false
			chalk.reset()