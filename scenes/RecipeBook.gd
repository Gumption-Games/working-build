extends Node2D

class_name RecipeBook
var type

var book = Dictionary()
var default_recipe = ["BlueObject", "RedObject"]
var default_result = "PurpleObject"


### INITIALIZER METHODS ###

func _init():
	book[default_recipe] = default_result
	type = "RecipeBook"


### PARENT METHOD OVERRIDES ###

# Taken from:
# https://godotengine.org/qa/24745/how-to-check-type-of-a-custom-class
# 2020-02-03
func is_class(type): return type == self.type or .is_class(type)
func get_class(): return self.type


### PUBLIC METHODS ###

# To be used for loading recipes from file
func load_book():
	pass


# Loads a recipe into the RecipeBook dictionary
func load_recipe(ingredients : Array, result):
	if ingredients.empty():
		return false
	ingredients.sort()
	book[ingredients] = result
	return true


# Checks the recipe dict for a given array of input ingredients
# Returns the result if found, null otherwise
func check_recipe(ingredients : Array):
	if book.has(ingredients):
		return book[ingredients]
	return null