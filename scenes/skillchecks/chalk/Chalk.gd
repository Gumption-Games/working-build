class_name Chalk extends Line2D


var dragging = false
#var starting_point = Vector2(40, 100)
var starting_point = Vector2(ProjectSettings.get_setting("display/window/size/width")/2,
	ProjectSettings.get_setting("display/window/size/height")/2)


func _ready():
	$ChalkIcon.position = starting_point


func _input(event):
#	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
#		if event.pressed:
#			print("dragging")
#			# Chalk is picked up
#			dragging = true
#		else:
#			# Chalk is dropped
#			dragging = false
	if $ChalkIcon.dragging and event is InputEventMouseMotion:
		add_point(event.position)


func reset():
	OS.delay_msec(400)
	clear_points()
	$ChalkIcon.position = starting_point