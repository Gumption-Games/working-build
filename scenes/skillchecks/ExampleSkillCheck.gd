class_name ExampleSkillCheck extends SkillCheck


### PRIVATE METHODS ###

func _check_for_success():
	var circle = get_node("TestCircle")
	if circle.position.x>800 and circle.position.y<100 and circle.dragging==false:
		return_result(false)
	elif circle.position.x>512 and circle.dragging==false:
		return_result(true)