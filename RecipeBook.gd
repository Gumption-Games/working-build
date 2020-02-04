extends Node2D

class_name RecipeBook

var book = Dictionary()
var default_recipe = ["BlueObject", "RedObject"]
var default_result = "PurpleObject"


func _init():
	book[default_recipe] = default_result


func load_list(list = []):
	pass


func load_recipe(ingredients : Array, result):
	if ingredients.empty():
		return false
	ingredients.sort()
	book[ingredients] = result
	return true


func check_recipe(ingredients : Array):
	if book.has(ingredients):
		return book[ingredients]
	return null