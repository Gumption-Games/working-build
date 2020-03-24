extends Node2D

var type

var book = Dictionary()
var recipes_path = "res://assets/Recipes.json"
var default_recipe = ["BlueIngredient", "RedIngredient"]
var default_result = "PurpleIngredient"


### INITIALIZER METHODS ###

func _init():
	type = "RecipeBook"
	
	# Load and parse recipes
	var file = File.new()
	file.open(recipes_path, file.READ)
	load_book(file)
	file.close()


### PARENT METHOD OVERRIDES ###

# Taken from:
# https://godotengine.org/qa/24745/how-to-check-type-of-a-custom-class
# 2020-02-03
func is_class(type): return type == self.type or .is_class(type)
func get_class(): return self.type


### PUBLIC METHODS ###

# Loads recipes into book given a file
func load_book(file):
	var json_text = file.get_as_text()
	var parse_result = JSON.parse(json_text)
	if parse_result.error!=OK:
		print("JSON Parse Error: ", parse_result.error_string)
		return
	var recipes_json = parse_result.result
	for key in recipes_json:
		load_recipe(key.split('+'), recipes_json[key])


# Loads a recipe into the RecipeBook dictionary
func load_recipe(ingredients : Array, result : Dictionary):
	if ingredients.empty():
		return false
	ingredients.sort()
	book[ingredients] = result
	return true


# Checks the recipe dict for a given array of input ingredients
# Returns the result if found, null otherwise
func check_recipe(ingredients : Array, combiner : String):
	if book.has(ingredients):
		if book[ingredients]["combiner"] == combiner:
			return book[ingredients]["result"]
	return null
