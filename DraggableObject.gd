extends Area2D

export var enable : bool = false

var dragging : bool = false

#TODO: dynamically set size of collisionshape to match sprite

# Called when input occurs AND mouse is within object's CollisionShape2D
func _on_DraggableObject_input_event(viewport, event, shape_idx):
	if not enable:
		self.hide()
		return
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		if dragging && !event.pressed:
			_handle_overlaps()
		dragging = event.pressed

# Taken from:
# https://godotengine.org/qa/41946/drag-and-drop-a-sprite-is-there-a-built-in-function-for-a-node
# 2020-01-30
func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and dragging:
		position = get_global_mouse_position()

func _handle_overlaps():
	var overlaps = get_overlapping_areas()
	var dimensions = get_node("CollisionShape2D").shape.extents * 2

	for obj in overlaps:
		# TODO: Handle combinations here
		
		# Distance to the centre of the overlapping area
		var to_area = (obj.position - self.position)
		# Chooses direction (left or right) based on which side self is closer to
		var direction = 1 if to_area.x<0 else -1
		position.x += to_area.x + dimensions.x*direction