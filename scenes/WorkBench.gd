extends Node2D

onready var book_gui := $RecipeBookGUI
onready var toggle_book_pos := $ToggleBookPosition
onready var hidden_pos : Vector2 = $HiddenBookPosition.get_position()
onready var show_pos : Vector2 = $ShowBookPosition.get_position()

var global_vars
var book


# Called when the node enters the scene tree for the first time.
func _ready():
	global_vars = get_node("/root/GlobalVariables")
	global_vars.workbench = self
	book = get_node("/root/RecipeBook")
	
	book_gui.set_position(hidden_pos)
	#toggle_book_pos.set_position(Vector2(GlobalVariables.SCREEN_SIZE.x/2, GlobalVariables.SCREEN_SIZE.y))
	# TODO: Set the toggle_book_pos collision shape extents to match screen size
	
func _on_ToggleBookPosition_mouse_entered():
	# Move the Book!
	if book_gui.get_position() == hidden_pos:
		book_gui.set_position(show_pos)
	elif book_gui.get_position() == show_pos:
		book_gui.set_position(hidden_pos)
