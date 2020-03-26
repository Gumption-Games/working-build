class_name Knife extends Combiner

var CutPointScene := preload("res://scenes/combiners/CutPoint.tscn")

# Play with these values to change the game
export var speed : int = 100
export var direction : int = 1

# Accessing nodes in scene
onready var label := $Label
onready var wheel := $CelestialWheel
onready var arm := $CelestialWheel/Arm
onready var hitarea := $CelestialWheel/Arm/HitArea
onready var center := Vector2(0, 0)

onready var _1_ : Area2D = $CelestialWheel/_1_/CollisionShape2D/
onready var _2_ : Area2D = $CelestialWheel/_2_/CollisionShape2D/
onready var _3_ : Area2D = $CelestialWheel/_3_/CollisionShape2D/
onready var _4_ : Area2D = $CelestialWheel/_4_/CollisionShape2D/
onready var _5_ : Area2D = $CelestialWheel/_5_/CollisionShape2D/
onready var _6_ : Area2D = $CelestialWheel/_6_/CollisionShape2D/
onready var _7_ : Area2D = $CelestialWheel/_7_/CollisionShape2D/
onready var _8_ : Area2D = $CelestialWheel/_8_/CollisionShape2D/
onready var _9_ : Area2D = $CelestialWheel/_9_/CollisionShape2D/
onready var _10_ : Area2D = $CelestialWheel/_10_/CollisionShape2D/
onready var _11_ : Area2D = $CelestialWheel/_11_/CollisionShape2D/
onready var _12_ : Area2D = $CelestialWheel/_12_/CollisionShape2D/ 

# Game variables
var go := false
var finished := false
var accum : float = 0.0
var selected = []
var pattern = []
var position_active = 0

func _ready():
	for i in range(5):
		pattern.append((int(rand_range(1, 12))))
	
	# Determine possible hit points
	print(pattern)
#	for i in pattern:
#		var cutpoint = CutPointScene.instance()
#		add_child(cutpoint)
#		var angle2 = i * (360/60)
#		cutpoint.name = 'dot2_%d' % (i+1)
#		var cutpoint_rect_pivot_offset = Vector2(1,1)
#		cutpoint.width = 8.0
#		cutpoint.height = 8.0
#		cutpoint.position = (center-cutpoint_rect_pivot_offset) + Vector2(cos(deg2rad(angle2)), sin(deg2rad(angle2))) * 140
#		cutpoint.shape.set_extents(Vector2(cutpoint.width, cutpoint.height))

	# Sweeping arm
	arm.name = 'arm'
	arm.rect_pivot_offset = Vector2(20, 168)
	
	# Initialize the Label
	label.text = "Click on the wheel when over a point!"

func _process(delta):
	
	if finished:
		return
	
	if go: # Wait for user input before beginning
		accum += delta
		arm.rect_rotation += abs(clamp(sin(accum), 0.3, 1)) * speed * delta * direction
		finished = false
		
		# End the game!
		if pattern.empty():
			finished = true
			
		# Now check to see if we're done
		if finished:
			label.text = "Well Done."
		
		# Move the HitArea on a sine wave
		#sine_x += hit_area_speed * delta
		#print($arm.rect_rotation)
		#hitarea.rotation = int(hitarea.rotation) % 360
		#hitarea.position = peak.x + ((sin(sine_x)+1) * ingredient_size.x/amplitude_factor)
		#print(int(hitarea.rotation) % 360)
		update()

func _input(event):
	if finished:
		return
	
	if event is InputEventMouseButton and event.is_pressed():
		if not go:
			go = true
			return
		
		# Here's something cool:
		# InputEventMouseButton has a property called "factor"
		# which corresponds to how *much* the button is held.
		# We could use this to cut using the scroll wheel.
		#if event.button_index==BUTTON_WHEEL_DOWN:
		#	if event.factor > 0.7:
		if event.button_index==BUTTON_LEFT \
		or event.button_index==BUTTON_RIGHT \
		or event.button_index==BUTTON_MIDDLE:
			print(position_active)
			if position_active == pattern.back():
				selected.push_back(pattern.back())
				pattern.pop_back()
				print(pattern)
				# Change direction of arm 
				direction = -direction
				label.text = "HIT"
			else:
				label.text = "MISS"
				while !selected.empty():
					pattern.push_back(selected.pop_back())
				print(pattern)
				print(selected)

# Signals
func _on__1__area_shape_entered(area_id, area, area_shape, self_shape):
	position_active = 1

func _on__2__area_shape_entered(area_id, area, area_shape, self_shape):
	position_active = 2

func _on__3__area_shape_entered(area_id, area, area_shape, self_shape):
	position_active = 3

func _on__4__area_shape_entered(area_id, area, area_shape, self_shape):
	position_active = 4

func _on__5__area_shape_entered(area_id, area, area_shape, self_shape):
	position_active = 5

func _on__6__area_shape_entered(area_id, area, area_shape, self_shape):
	position_active = 6

func _on__7__area_shape_entered(area_id, area, area_shape, self_shape):
	position_active = 7

func _on__8__area_shape_entered(area_id, area, area_shape, self_shape):
	position_active = 8

func _on__9__area_shape_entered(area_id, area, area_shape, self_shape):
	position_active = 9

func _on__10__area_shape_entered(area_id, area, area_shape, self_shape):
	position_active = 10

func _on__11__area_shape_entered(area_id, area, area_shape, self_shape):
	position_active = 11

func _on__12__area_shape_entered(area_id, area, area_shape, self_shape):
	position_active = 12
