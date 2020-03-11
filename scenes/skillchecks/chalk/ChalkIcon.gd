extends Ingredient

var scene
var disabled = true


func _ready():
	scene = get_parent().get_parent()


func _on_ChalkIcon_input_event(viewport, event, shape_idx):
	if disabled: return
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			# Object is picked up
			dragging = true
		else:
			# Held object is being dropped
			dragging = false
			scene.reset()