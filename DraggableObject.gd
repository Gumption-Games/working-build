extends Area2D

const IMG_PATH = ".import/circle.png-6efbe600b7e2418cd5091089237d13c1.stex"

export var enable : bool = true

var dragging : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Creates new sprite using IMG_PATH for texture
	var image = preload(IMG_PATH)
	var sprite = Sprite.new()
	sprite.set_texture(image)
	add_child(sprite)
	
	# Set the ingredient's collisionshape to the size of the sprite
	var dimensions = sprite.texture.get_size()
	print(dimensions)
	var collision_shape = get_node("CollisionShape2D")
	print(collision_shape.shape.get_extents())
	collision_shape.shape.set_extents(dimensions)

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