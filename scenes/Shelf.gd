class_name Shelf extends Node2D

export var ings_per_row := 3
export var ing_scale := Vector2(0.25, 0.25)
export var margin := Vector2(66.0, 66.0)
var pos := Vector2(0.0, 0.0)

# List of unique ingredients that the player has discovered
var ing_types_known := []

onready var topleft :Vector2 = $Sprite.get_global_position() + (margin/2)


func _ready():
	# globalvars for combiners to place new ingredients
	GlobalVariables.shelf = self
	
	# Arrange the initial ingredients
	for child in get_children():
		if child is Ingredient and child.visible:
			# Place it at the (x,y) position on the shelf
			place_new_ing(child)


func place_new_ing(new_ing : Ingredient):
	""" 
	Takes a new Ingredient and gives it a position
	"""
	var new_x : float = topleft.x + (margin.x * pos.x)
	var new_y : float = topleft.y + (margin.y * pos.y)
	var new_pos := Vector2(new_x, new_y)
	new_ing.sticky_pos = new_pos
	new_ing.set_scale(ing_scale)
	put_back_ing(new_ing)
	pos.x += 1.0
	if pos.x >= ings_per_row:
		pos.x = 0.0
		pos.y += 1.0
	
	# Make the ingredient known if it isn't already
	learn_ing_type(new_ing.type)


func put_back_ing(ing : Ingredient):
	ing.set_global_position(ing.sticky_pos)


func know_ing_type(new_ing_type : String) -> bool:
	"""
	Checks to see if a particular type of ingredient has
	been discovered yet.
	"""
	var known := false
	for ing_type in ing_types_known:
		if ing_type == new_ing_type and ing_type != "Ingredient":
			known = true
			break
	return known


func learn_ing_type(new_ing_type : String) -> bool:
	"""
	Adds a new ingredient type to the list of discovered
	types if hasn't been already.
	"""
	if not know_ing_type(new_ing_type):
		ing_types_known.append(new_ing_type)
		return true # type learned successfully
	return false # type already learned

