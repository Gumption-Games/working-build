class_name FittedHitboxObject extends Area2D

var type

var global_vars
var IMG_PATH
var size
var collision_shape : CollisionShape2D

### INITIALIZER METHODS ###

func _init():
	type = "FittedHitboxObject"

func _ready():
	# Access the GlobalVariables singleton
	global_vars = get_node("/root/GlobalVariables")
	
	var sprite = _check_for_sprite()
	if !sprite && IMG_PATH:
		# Creates new sprite using IMG_PATH for texture
		var image = load(IMG_PATH)
		print("Loading ", IMG_PATH)
		print(type)
		sprite = Sprite.new()
		sprite.set_texture(image)
		sprite.set_name("Sprite")
		add_child(sprite)
	
	self.size = sprite.texture.get_size()
	
	# Initialize a CollisionShape with a rectangle the size of the sprite
	var new_collision_shape = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	rectangle.set_extents(self.size/2)
	new_collision_shape.set_shape(rectangle)
	add_child(new_collision_shape)
	
	self.collision_shape = new_collision_shape


func enable():
	if collision_shape:
		collision_shape.set_disabled(false)
		return true
	return false


func disable():
	if collision_shape:
		collision_shape.set_disabled(true)
		return true
	return false


### PARENT METHOD OVERRIDES ###

# Taken from:
# https://godotengine.org/qa/24745/how-to-check-type-of-a-custom-class
# 2020-02-03
func is_class(type): return type == self.type or .is_class(type)
func get_class(): return self.type


### PRIVATE METHODS ###

func _check_for_sprite():
	var children = get_children()
	for child in children:
		if child.is_class("Sprite"):
			return child
	return null
