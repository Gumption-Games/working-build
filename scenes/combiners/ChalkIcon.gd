class_name ChalkIcon extends FittedHitboxObject

var scene
var disabled : bool = true
var dragging : bool = false


func _init():
	IMG_PATH = ".import/circle.png-6efbe600b7e2418cd5091089237d13c1.stex"
	type = "ChalkIcon"


func _ready():
	hide()
	scene = get_parent().get_parent()


func _on_ChalkIcon_input_event(viewport, event, shape_idx):
	if disabled: return
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			# Object is picked up
			dragging = true
		else:
			# Held object is being dropped
			dragging = false
			scene.reset()

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and dragging:
		set_global_position(get_global_mouse_position())