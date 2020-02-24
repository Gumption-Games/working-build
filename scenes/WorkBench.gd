extends Node2D

var global_vars
var book


# Called when the node enters the scene tree for the first time.
func _ready():
	global_vars = get_node("/root/GlobalVariables")
	global_vars.workbench = self
	book = get_node("/root/RecipeBook")