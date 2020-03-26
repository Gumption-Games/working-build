class_name Celestial extends Combiner

# Play with these values to change the game
export var speed : int = 100
export var direction : int = 1
export var combo : int = 1
export var difficulty : int = 5

# Accessing nodes in scene
onready var label := $Label
onready var wheel := $Wheel
onready var arm := $Wheel/Arm
onready var hitarea := $Wheel/Arm/HitArea
onready var center := Vector2(0, 0)

onready var _1_ : Area2D = $Wheel/_1_/CollisionShape2D/
onready var _2_ : Area2D = $Wheel/_2_/CollisionShape2D/
onready var _3_ : Area2D = $Wheel/_3_/CollisionShape2D/
onready var _4_ : Area2D = $Wheel/_4_/CollisionShape2D/
onready var _5_ : Area2D = $Wheel/_5_/CollisionShape2D/
onready var _6_ : Area2D = $Wheel/_6_/CollisionShape2D/
onready var _7_ : Area2D = $Wheel/_7_/CollisionShape2D/
onready var _8_ : Area2D = $Wheel/_8_/CollisionShape2D/
onready var _9_ : Area2D = $Wheel/_9_/CollisionShape2D/
onready var _10_ : Area2D = $Wheel/_10_/CollisionShape2D/
onready var _11_ : Area2D = $Wheel/_11_/CollisionShape2D/
onready var _12_ : Area2D = $Wheel/_12_/CollisionShape2D/ 

# Game variables
var go := false
var finished := false
var accum : float = 0.0
var selected = []
var pattern = []
var position_active = 0

func _ready():
	# Determine possible hit points
	_generate()

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
		arm.rect_rotation += abs(clamp(sin(accum), 0.3, 1)) * speed * delta * direction * combo
		finished = false
		
		# End the game!
		if pattern.empty():
			finished = true
			
		# Now check to see if we're done
		if finished:
			label.text = "Well Done."
	
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
				combo += 1
				label.text = "HIT"
			else:
				label.text = "MISS"
				while !selected.empty():
					pattern.push_back(selected.pop_back())
				combo = 1
				print(pattern)
				print(selected)

# Helper Functions
func _generate():
	while len(pattern) < difficulty:
		var rand = (randi() % 12) + 1
		if !pattern.has(rand):
			pattern.append(rand)

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
