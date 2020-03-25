class_name NewWorkBench extends Node2D

onready var global_vars = get_node("/root/GlobalVariables")
onready var book = get_node("/root/RecipeBook")

onready var cauldron := $Cauldron
onready var knife := $Knife
onready var chalk := $Chalk
onready var combiners : Array = [cauldron, knife, chalk]


# Called when the node enters the scene tree for the first time.
func _ready():
	global_vars.workbench = self
	global_vars.current_combiner = cauldron # Do we need this?
	hide_all_combiners()
	show_cauldron()


func hide_all_combiners():
	for combiner in combiners:
		GlobalVariables.freeze_scene(combiner, true)
		combiner.hide()


func show_cauldron(): # Connected to CauldronButton
	hide_all_combiners()
	GlobalVariables.freeze_scene(cauldron, false)
	cauldron.show()


func show_knife():
	hide_all_combiners()
	GlobalVariables.freeze_scene(knife, false)
	knife.show()


func show_chalk():
	hide_all_combiners()
	GlobalVariables.freeze_scene(chalk, false)
	chalk.show()
