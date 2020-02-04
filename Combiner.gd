extends Node2D

class_name Combiner

var global_vars
var held_ingredients = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Access the GlobalVariables singleton
	global_vars = get_node("/root/GlobalVariables")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Combiner_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT
		and !event.pressed):
		_handle_new_ingredient(global_vars.held_object)

func _handle_new_ingredient(obj):
	if !obj:
		return
	print(obj.is_class("Area2D"))
	print(obj.is_class("DraggableObject"))
	obj.hide()
	obj.enable=false
	held_ingredients.append(obj)
	print(held_ingredients)

func get_size():
	return Vector2(128, 128)
