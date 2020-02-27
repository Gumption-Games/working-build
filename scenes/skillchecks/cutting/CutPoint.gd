class_name CutPoint extends Area2D

var width : float = 5.0 	# by default; gets overwritten
var height: float = 20.0	# by default; gets overwritten
onready var shape : RectangleShape2D = $CollisionShape2D.shape

var cut := false
var color : Color = Color(Color.blue)

func _ready():
	shape.set_extents(Vector2(width, height))

func _process(delta):
	if cut and color==Color.blue:
		color = Color(Color.red)
		update()

func _draw():
	# Drawing simple shapes using CanvasItem methods
	draw_rect(
		Rect2(Vector2(-width,-height), Vector2(width*2, height*2)), \
		color, \
		true \
	)