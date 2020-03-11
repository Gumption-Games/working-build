class_name Ingredient extends FittedHitboxObject

var dragging : bool = false
var sticky_pos : Vector2
onready var label : Label = $Label

### INITIALIZER METHODS ###

func _init():
	IMG_PATH = ".import/circle.png-6efbe600b7e2418cd5091089237d13c1.stex"
	type = "Ingredient"

func _ready():
	label.hide()

### PRIVATE METHODS ###

# Taken from:
# https://godotengine.org/qa/41946/drag-and-drop-a-sprite-is-there-a-built-in-function-for-a-node
# 2020-01-30
func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and dragging:
		position = get_global_mouse_position()


func _on_Ingredient_input_event(viewport, event, shape_idx):
	# If input occurs AND mouse is within object's CollisionShape2D
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			# Object is picked up
			dragging = true
			global_vars.held_object = self
			sticky_pos = get_position() # Save pos for resetting
		else:
			# Held object is being dropped
			dragging = false
			global_vars.held_object = null
			_handle_overlaps()


# Avoids overlaps between objects
func _handle_overlaps():
	var overlaps = get_overlapping_areas()
	if overlaps:
		for obj in overlaps:
			# TODO: Handle combinations here
			if obj is Combiner: # Add object to combiner
				obj.handle_new_ingredient(self)
				return
		
		# Reset to the original position
		self.set_position(sticky_pos)
		
		# No combiner found -- avoid overlaps
		# Distance to the centre of the overlapping area
		#var to_area = overlaps[0].position - self.position
		# Chooses direction (left or right) based on which side self is closer to
		#var direction = 1 if to_area.x<0 else -1
		#position.x += to_area.x + (overlaps[0].get_size().x + self.size.x)/2 * direction
	else:
		self.set_position(sticky_pos)


func _set_label(label_str:String):
	label.text = label_str
	#void set_margins_preset( LayoutPreset preset, LayoutPresetMode resize_mode=0, int margin=0 )
	#var layoutpreset : LayoutPreset = LayoutPreset.CENTER
	#label.set_margins_preset( \
	#		LayoutPreset.CENTER, \
	#		LayoutPresetMode.PRESET_MODE_KEEP_SIZE, \
	#		40 \
	#)


func _on_Ingredient_mouse_entered():
	label.visible = true


func _on_Ingredient_mouse_exited():
	label.visible = false


### PUBLIC METHODS ###

func get_size():
	return self.size

