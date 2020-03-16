class_name Shelf extends Node2D

export var ings_per_row := 3
export var margin := Vector2(60.0, 60.0)
var pos := Vector2(0.0, 0.0)

onready var topleft :Vector2 = $Sprite.get_global_position() + (margin/2)

func _ready():
	# globalvars for combiners to place new ingredients
	GlobalVariables.shelf = self
	
	# Arrange the initial ingredients
	for child in get_children():
		if child is Ingredient and child.visible:
			# Place it at the (x,y) position on the shelf
			place_new_ing(child)


func place_new_ing(ing : Ingredient):
	""" 
	Takes a new Ingredient and gives it a position
	"""
	var new_x : float = topleft.x + (margin.x * pos.x)
	var new_y : float = topleft.y + (margin.y * pos.y)
	var new_pos := Vector2(new_x, new_y)
	ing.sticky_pos = new_pos
	put_back_ing(ing)
	pos.x += 1.0
	if pos.x >= ings_per_row:
		pos.x = 0.0
		pos.y += 1.0


func put_back_ing(ing : Ingredient):
	ing.set_global_position(ing.sticky_pos)

