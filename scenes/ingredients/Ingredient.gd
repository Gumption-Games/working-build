class_name Ingredient extends FittedHitboxObject


var dragging : bool = false


### INITIALIZER METHODS ###

func _init():
	IMG_PATH = ".import/circle.png-6efbe600b7e2418cd5091089237d13c1.stex"
	type = "Ingredient"


### PRIVATE METHODS ###

# Taken from:
# https://godotengine.org/qa/41946/drag-and-drop-a-sprite-is-there-a-built-in-function-for-a-node
# 2020-01-30
func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and dragging:
		position = get_global_mouse_position()


# Called when input occurs AND mouse is within object's CollisionShape2D
func _on_Ingredient_input_event(viewport, event, shape_idx):
	print("hello????")
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		print("hey")
		if event.pressed:
			# Object is picked up
			dragging = true
			global_vars.held_object = self
		else:
			# Held object is being dropped
			dragging = false
			global_vars.held_object = null
			_handle_overlaps()


# Avoids overlaps between objects
func _handle_overlaps():
	var overlaps = get_overlapping_areas()

	for obj in overlaps:
		# TODO: Handle combinations here
		if obj is Combiner:	# Add object to combiner
			obj.handle_new_ingredient(self)
		else:	# avoid overlaps
			# Distance to the centre of the overlapping area
			var to_area = (obj.position - self.position)
			# Chooses direction (left or right) based on which side self is closer to
			var direction = 1 if to_area.x<0 else -1
			position.x += to_area.x + (obj.get_size().x + self.size.x)/2 * direction


### PUBLIC METHODS ###

func get_size():
	return self.size

