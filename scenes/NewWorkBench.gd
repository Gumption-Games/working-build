class_name NewWorkBench extends Node2D

onready var cauldron := $Cauldron
onready var cutting := $CuttingSkillCheck
onready var skill_checks : Array = [cauldron, cutting]

onready var global_vars = get_node("/root/GlobalVariables")
onready var book = get_node("/root/RecipeBook")

# Called when the node enters the scene tree for the first time.
func _ready():
	global_vars.workbench = self
	#hide_all_skill_checks()
	#_on_CauldronButton_pressed()

## Called every frame. 'delta' is the elapsed time since the previous frame.
##func _process(delta):
##	pass
#
#func hide_all_skill_checks():
#	for skill_check in skill_checks:
#		GlobalVariables.freeze_scene(skill_check, true)
#		skill_check.hide()
#
#func _on_CauldronButton_pressed(): # Show the Cauldron
#	hide_all_skill_checks()
#	GlobalVariables.freeze_scene(cauldron, false)
#	cauldron.show()
#
#func _on_CuttingButton_pressed(): # Show the Cutting
#	hide_all_skill_checks()
#	GlobalVariables.freeze_scene(cutting, false)
#	cutting.show()
