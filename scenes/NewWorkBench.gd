class_name NewWorkBench extends Node2D

onready var cauldron := $Cauldron
#onready var cutting := $CuttingSkillCheck
onready var skill_checks : Array = [cauldron]

onready var global_vars = get_node("/root/GlobalVariables")
onready var book = get_node("/root/RecipeBook")

# Called when the node enters the scene tree for the first time.
func _ready():
	global_vars.workbench = self
	global_vars.current_combiner = cauldron
	hide_all_skill_checks()
	show_cauldron()

func hide_all_skill_checks():
	for skill_check in skill_checks:
		GlobalVariables.freeze_scene(skill_check, true)
		skill_check.hide()

func show_cauldron(): # Connected to CauldronButton
	hide_all_skill_checks()
	GlobalVariables.freeze_scene(cauldron, false)
	cauldron.show()
