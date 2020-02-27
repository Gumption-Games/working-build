class_name Cauldron extends "res://scenes/combiners/Combiner.gd"

onready var NewIngredientSound := $NewIngredientSound
onready var CookingSound := $CookingSound

func _init():
	type = "Cauldron"
	minigame_path = "res://scenes/skillchecks/cauldron/CauldronSkillCheck.tscn"

func _ready():
	connect("new_ingredient", self, "_on_new_ingredient")
	connect("no_ingredients", self, "_on_no_ingredients")
	connect("multiple_ingredients", self, "_on_multiple_ingredients")
	$Filled.hide()
	$Empty.show()

func _on_new_ingredient():
	if NewIngredientSound.is_playing():
		NewIngredientSound.stop()
	NewIngredientSound.play(0.0)
	$Filled.show()
	$Empty.hide()

func _on_no_ingredients():
	CookingSound.stop()
	$Filled.hide()
	$Empty.show()

func _on_multiple_ingredients():
	CookingSound.play()

