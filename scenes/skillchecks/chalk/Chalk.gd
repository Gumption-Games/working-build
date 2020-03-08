class_name Chalk extends Line2D


var starting_point = Vector2(40, 100)


func reset():
	OS.delay_msec(400)
	clear_points()
	$ChalkIcon.position = starting_point