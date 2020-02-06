extends Node2D

var global_vars


### INITIALIZER METHODS ###

func _ready():
	global_vars = get_node("/root/GlobalVariables")


### PRIVATE METHODS ###

func _process(delta):
	_check_for_success()

func _check_for_success():
	return_result(true) # Replace with actual test


### PUBLIC METHODS ###

func return_result(result):
	global_vars.current_combiner.minigame_result(result)