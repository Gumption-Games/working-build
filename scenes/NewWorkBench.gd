class_name NewWorkBench extends Node2D

onready var global_vars = get_node("/root/GlobalVariables")
onready var book = get_node("/root/RecipeBook")
onready var new_ing_dialog_scene = preload("res://scenes/gui/NewIngPopup.tscn")

onready var cauldron := $Cauldron
onready var knife := $Knife
onready var combiners : Array = [cauldron, knife]


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


func _on_ingredient_discovered(ing:Ingredient):
	var ing_name = ing.label.text
	var popup = new_ing_dialog_scene.instance()
	self.add_child(popup)
	popup.label.text = ing_name
	var ing_spr = ing.find_node("Sprite")
	if ing_spr:
		var popup_spr = ing_spr.duplicate()
		popup_spr.set_scale(Vector2(0.5, 0.5))
		popup_spr.set_position(Vector2(popup.size.x*0.5, popup.size.y*0.45))
		popup.add_child(popup_spr)
	popup.popup()

