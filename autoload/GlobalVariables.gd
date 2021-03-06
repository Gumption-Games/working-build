extends Node2D

var SCREEN_SIZE : Vector2 = OS.get_screen_size()

var held_object
var current_combiner
var workbench
var shelf : Shelf
var shelf_label = null

# Called when the node enters the scene tree for the first time.
func _ready():
	held_object = null
	current_combiner = null
	workbench = null


### PUBLIC METHODS ###

# Taken from:
# https://github.com/godotengine/godot/issues/15993#issuecomment-567242789
# 2020-02-06
func freeze_node(node, freeze): # freeze = true freezes nodes, false thaws
	node.set_process(!freeze)
	node.set_physics_process(!freeze)
	node.set_process_input(!freeze)
	node.set_process_internal(!freeze)
	node.set_process_unhandled_input(!freeze)
	node.set_process_unhandled_key_input(!freeze)
	if node is CollisionShape2D:
		node.set_disabled(freeze)

func freeze_scene(node, freeze):
	freeze_node(node, freeze)
	for c in node.get_children():
		freeze_scene(c, freeze)
