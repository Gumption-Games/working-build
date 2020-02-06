extends Node2D

var global_vars

func _ready():
	global_vars = get_node("/root/GlobalVariables")


func _process(delta):
	_check_for_success()

func _check_for_success():
	var circle = get_node("TestCircle")
	if circle.position.x>800 and circle.position.y<100 and circle.dragging==false:
		_return_result(false)
	elif circle.position.x>512 and circle.dragging==false:
		_return_result(true)

func _return_result(result):
	global_vars.current_combiner.minigame_result(result)