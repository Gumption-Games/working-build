extends Node2D

class_name Combiner

var global_vars
var held_ingredients = Array()
var recipe_book

# Called when the node enters the scene tree for the first time.
func _ready():
	# Access the GlobalVariables singleton
	global_vars = get_node("/root/GlobalVariables")
	recipe_book = preload("res://RecipeBook.gd").new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	passa


func _on_Combiner_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
#		if !event.pressed and global_vars.held_object:
#			# Object dropped into combiner
#			_handle_new_ingredient(global_vars.held_object)
##			global_vars.held_object = null
#			return
		if event.pressed:
			_combine_ingredients()


func handle_new_ingredient(ingredient):
	global_vars.held_object = null
	
	ingredient.hide()
	ingredient.enable=false
	held_ingredients.append(ingredient)
	print("Combiner:: ", held_ingredients)


func _combine_ingredients():
	if held_ingredients.empty():
		return
	var recipe = _convert_held_to_recipe()
	recipe.sort()
	var result_name = recipe_book.check_recipe(recipe)
	if result_name:
		_spawn_result(result_name)
	else:
		_return_ingredients()
		


func _spawn_result(ingredient_name):
	# Create new instance of spawned ingredient
	var path = "ingredients/"+ingredient_name+".tscn"
	var result = load(path).instance()
	
	# Add new ingredient to scene
	get_tree().current_scene.add_child(result)
	
	# Move new ingredient to below combiner
	var offset = Vector2(0, get_size().y * 0.75)
	result.position = self.position + offset


func _return_ingredients():
	var target = self.position - get_size()/2
	var ing
	while !held_ingredients.empty():
		ing = held_ingredients.pop_back()
		ing.enable = true
		target.y += ing.get_size().y
		ing.position = target - ing.get_size()/2
		ing.show()


func _convert_held_to_recipe():
	var recipe = []
	for ing in held_ingredients:
		recipe.append(ing.get_class())
	return recipe


func get_size():
	return Vector2(128, 128)
