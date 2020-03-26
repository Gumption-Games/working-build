class_name NewWorkBench extends Node2D

onready var global_vars = get_node("/root/GlobalVariables")
onready var book = get_node("/root/RecipeBook")
onready var new_ing_dialog_scene = preload("res://scenes/gui/NewIngPopup.tscn")

onready var bgm1 := $bgm1
onready var bgm2 := $bgm2
onready var bgms :Array = [bgm1, bgm2] # Cycle between background music tracks
onready var bgm_index := 0
onready var bgm_timer := $BgmTimer # Period of silence between music tracks
onready var cauldron := $Cauldron
onready var celestial := $Celestial
onready var chalk := $Chalk
onready var combiners : Array = [cauldron, celestial, chalk]


# Called when the node enters the scene tree for the first time.
func _ready():
	global_vars.workbench = self
	global_vars.current_combiner = cauldron # Do we need this?
	global_vars.shelf_label = $ShelfLabel
	hide_all_combiners()
	show_cauldron()
	_cycle_bgm() # Start the background music


func hide_all_combiners():
	for combiner in combiners:
		GlobalVariables.freeze_scene(combiner, true)
		combiner.hide()


func show_cauldron(): # Connected to CauldronButton
	hide_all_combiners()
	GlobalVariables.freeze_scene(cauldron, false)
	cauldron.show()
	$TicSound.play()


func show_celestial():
	hide_all_combiners()
	GlobalVariables.freeze_scene(celestial, false)
	celestial.show()
	$TicSound.play()


func show_chalk():
	hide_all_combiners()
	GlobalVariables.freeze_scene(chalk, false)
	chalk.show()
	$TicSound.play()

	
func _on_ingredient_discovered(ing:Ingredient):
	var ing_name = ing.label.text
	var popup = new_ing_dialog_scene.instance()
	$PopupLayer.add_child(popup)
	popup.label.text = ing_name
	var ing_spr = ing.find_node("Sprite")
	if ing_spr:
		var popup_spr = ing_spr.duplicate()
		#popup_spr.set_scale(Vector2(0.5, 0.5))
		popup_spr.set_position(Vector2(popup.size.x*0.5, popup.size.y*0.45))
		popup.add_child(popup_spr)
	popup.popup()


func _on_bgm_finished():
	bgm_timer.start() # Buffer of silence between music


# Triggered on BgmTimer timeout
func _cycle_bgm():
	if bgm_index >= bgms.size():
		# We reached the end of the tracklist; restart it
		bgm_index = 0
		bgm_timer.start() # Extra long silence before the tracklist repeats
		return
	bgms[bgm_index].play()
	bgm_index += 1

