class_name Combiner extends FittedHitboxObject

signal new_ingredient
signal no_ingredients
signal multiple_ingredients
signal correct_recipe_entered
signal ingredient_discovered

var held_ingredients : Array = [] # Array
var recipe_book

var minigame_path
var minigame
var result_name

onready var workbench = find_parent("NewWorkBench")

### INITIALIZER METHODS ###

func _init():
	IMG_PATH = ".import/icon.png-487276ed1e3a0c39cad0279d744ee560.stex"
	type = "Combiner"
	# minigame_path is assigned in each inherited scene

func _ready():
	recipe_book = get_node("/root/RecipeBook")
	connect("ingredient_discovered", workbench, "_on_ingredient_discovered")


### PRIVATE METHODS ###

# Handles mouse inputs on the combiner
func _on_Combiner_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		# Handles user clicks
		if event.pressed and not result_name:
			_combine_ingredients()


# Attempts to combine all held ingredients
func _combine_ingredients():
	if held_ingredients.empty():
		return

	# Convert all held ingredients to recipe format...
	var recipe = _convert_held_to_recipe()

	# Then check against the combiner's recipe book
	print(recipe_book)
	result_name = recipe_book.check_recipe(recipe, self.type)
	if result_name:
		# Let the tool do its thing
		#_skill_check()
		print("Determine success based on tool outcome")
		emit_signal("correct_recipe_entered")
	else:
		# Reached if the recipe is wrong
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
	print(type+":: Skill Check Called")
	if !minigame_path:
		print("\tNo game path supplied.")
		minigame_result(true)

	# Used later to return result
	global_vars.current_combiner = self
	
	# Freezes and hides everything in the main workbench scene
	global_vars.freeze_scene(global_vars.workbench, true)
	global_vars.workbench.hide()

	# Adds minigame scene to current tree
	minigame = load(minigame_path).instance()
	get_tree().get_root().add_child(minigame)


# Adds a combination's result as a new instance in the current scene
func _spawn_result(ingredient_name):
	if held_ingredients.empty():
		return
	
	# Check to see if we already have that ingredient
	# WARNING: this is conflating Ing type and recipe result
	#		** Ing's type needs to match its name in the Recipe book
	print("New Ingredient name: ", ingredient_name)
	var learned :bool = GlobalVariables.shelf.learn_ing_type(ingredient_name)
	if learned: # if the result is an undiscovered ingredient
		# Create new instance of spawned ingredient
		var path = "scenes/ingredients/"+ingredient_name+".tscn"
		var result = load(path).instance()
		# Add new ingredient to scene
		GlobalVariables.shelf.add_child(result)
		# Place new ingredient on the Shelf
		GlobalVariables.shelf.place_new_ing(result)
		emit_signal("ingredient_discovered", result)
	_return_ingredients()
	held_ingredients.clear()


# Ejects held ingredients on failed combination
func _return_ingredients():
	var ing
	while !held_ingredients.empty():
		ing = held_ingredients.pop_back()
		GlobalVariables.shelf.put_back_ing(ing)
		ing.enable()
		ing.show()
	emit_signal("no_ingredients")


# Frees all held ingredients and clears held_ingredients
func _clear_held_ingredients():
	for ing in held_ingredients:
		ing.queue_free()
	held_ingredients.clear()
	
	emit_signal("no_ingredients")
	

### PUBLIC METHODS ###

# Called when an ingredient is dropped into the Combiner
func handle_new_ingredient(ingredient):
	global_vars.held_object = null
	
	held_ingredients.append(ingredient)
	
	ingredient.disable()
	ingredient.hide()
	
	emit_signal("new_ingredient")
	if held_ingredients.size() >= 2:
		emit_signal("multiple_ingredients")


# Called by the minigame on completion
func minigame_result(success):
	#minigame.queue_free()
	
	#global_vars.freeze_scene(global_vars.workbench, false)
	#global_vars.workbench.show()
	#global_vars.current_combiner = null

	if success:
		_spawn_result(result_name)
	else:
		_return_ingredients()


func get_size():
	return size
