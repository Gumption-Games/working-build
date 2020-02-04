extends Area2D

class_name DraggableObject
var type = "DraggableObject"

export var enable : bool = true

var global_vars
var IMG_PATH
var size
var dragging : bool = false


func _init():
	IMG_PATH = ".import/circle.png-6efbe600b7e2418cd5091089237d13c1.stex"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Access the GlobalVariables singleton
	global_vars = get_node("/root/GlobalVariables")

	# Creates new sprite using IMG_PATH for texture
	var image = load(IMG_PATH)
	var sprite = Sprite.new()
	sprite.set_texture(image)
	sprite.set_name("Sprite")
	add_child(sprite)
	
	self.size = sprite.texture.get_size()
	
	# Initialize a CollisionShape with a rectangle the size of the sprite
	var collision_shape = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	rectangle.set_extents(self.size/2)
	collision_shape.set_shape(rectangle)
	add_child(collision_shape)

# Taken from:
# https://godotengine.org/qa/24745/how-to-check-type-of-a-custom-class
# 2020-02-03
func is_class(type): return type == self.type or .is_class(type)
func get_class(): return self.type


# Called when input occurs AND mouse is within object's CollisionShape2D
func _on_DraggableObject_input_event(viewport, event, shape_idx):
	if not enable:
		hide()
		return

	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		if event.pressed:
			# Object is picked up
			dragging = true
			global_vars.held_object = self
		else:
			# Held object is being dropped
			dragging = false
			global_vars.held_object = null
			_handle_overlaps()


# Taken from:
# https://godotengine.org/qa/41946/drag-and-drop-a-sprite-is-there-a-built-in-function-for-a-node
# 2020-01-30
func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and dragging:
		position = get_global_mouse_position()


func _handle_overlaps():
	var overlaps = get_overlapping_areas()
	var dimensions = self._get_child_node("Sprite").texture.get_size()

	for obj in overlaps:
		# TODO: Handle combinations here
#		if obj is Combiner:
#			emit_signal("entered_combiner", self)
##			self.enable = false
#		else:
		# Distance to the centre of the overlapping area
		var to_area = (obj.position - self.position)
		# Chooses direction (left or right) based on which side self is closer to
		var direction = 1 if to_area.x<0 else -1
		position.x += to_area.x + (obj.get_size().x + self.size.x)/2 * direction


func _get_child_node(type_name):
	for obj in self.get_children():
		if obj.get_class() == type_name:
			return obj


func get_size():
	return self.size