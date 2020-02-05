extends Area2D

var type

export var enable : bool = true

var global_vars
var IMG_PATH
var size

func _init():
	type = "FittedHitboxObject"

func _ready():
	# Access the GlobalVariables singleton
	global_vars = get_node("/root/GlobalVariables")
	
	var sprite = _check_for_sprite()
	print(sprite, get_class())
	if !sprite:
		# Creates new sprite using IMG_PATH for texture
		var image = load(IMG_PATH)
		sprite = Sprite.new()
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

func _check_for_sprite():
	var children = get_children()
	for child in children:
		if child.is_class("Sprite"):
			return child
	return null