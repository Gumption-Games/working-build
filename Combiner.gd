extends "res://FittedHitboxObject.gd"

class_name Combiner

var held_ingredients = Array()
var recipe_book


### INITIALIZER METHODS ###

func _init():
	IMG_PATH = ".import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex"
	# Load recipebook
	recipe_book = preload("res://RecipeBook.gd").new()


### PRIVATE METHODS ###

# Handles mouse inputs on the combiner
func _on_Combiner_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		# Handles user clicks
		if event.pressed:
			_combine_ingredients()


# Attempts to combine all held ingredients
func _combine_ingredients():
	if held_ingredients.empty():
		return

	# Convert all held ingredients to recipe format...
	var recipe = _convert_held_to_recipe()

	# Then check against the combiner's recipe book
	var result_name = recipe_book.check_recipe(recipe)
	if result_name:
		var minigame_result = _skill_check()
		if minigame_result:
			_spawn_result(result_name)
			return
		# TODO: Actually delete the ingredients used
	
	# Reached if the recipe is wrong, or if the minigame is failed
	_return_ingredients()


# Converts held ingredients to recipe format: a sorted list of class names
func _convert_held_to_recipe():
	var recipe = []
	for ing in held_ingredients:
		recipe.append(ing.get_class())
	recipe.sort()
	return recipe


# Replaced in subclesses with calls to cooking minigames
func _skill_check():
	return true

# Adds a combination's result as a new instance in the current scene
func _spawn_result(ingredient_name):
	# Create new instance of spawned ingredient
	var path = "ingredients/"+ingredient_name+".tscn"
	var result = load(path).instance()
	
	# Add new ingredient to scene
	get_tree().current_scene.add_child(result)
	
	# Move new ingredient to below combiner
	var offset = Vector2(0, get_size().y * 0.75)
	result.position = self.position + offset
	
	# Remove Held Ingredients
	held_ingredients.clear()


# Ejects held ingredients on failed combination
func _return_ingredients():
	var target = self.position - get_size()/2
	var ing
	while !held_ingredients.empty():
		ing = held_ingredients.pop_back()
		ing.enable = true
		# target gradually moves down to avoid stacking
		target.y += ing.get_size().y
		ing.position = target - ing.get_size()/2
		ing.show()


### PUBLIC METHODS ###

# Called when an ingredient is dropped into the Combiner
func handle_new_ingredient(ingredient):
	global_vars.held_object = null
	
	ingredient.hide()
	ingredient.enable=false
	held_ingredients.append(ingredient)
	print("Combiner:: ", held_ingredients)


func get_size():
	return size
