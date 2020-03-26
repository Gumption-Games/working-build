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

onready var _0_ : Area2D = $Wheel/_0_/Sprite_0_
onready var _1_ : Area2D = $Wheel/_1_/Sprite_1_
onready var _2_ : Area2D = $Wheel/_2_/Sprite_2_
onready var _3_ : Area2D = $Wheel/_3_/Sprite_3_
onready var _4_ : Area2D = $Wheel/_4_/Sprite_4_
onready var _5_ : Area2D = $Wheel/_5_/Sprite_5_
onready var _6_ : Area2D = $Wheel/_6_/Sprite_6_
onready var _7_ : Area2D = $Wheel/_7_/Sprite_7_
onready var _8_ : Area2D = $Wheel/_8_/Sprite_8_
onready var _9_ : Area2D = $Wheel/_9_/Sprite_9_
onready var _10_ : Area2D = $Wheel/_10_/Sprite_10_
onready var _11_ : Area2D = $Wheel/_11_/Sprite_11_

# Game variables
onready var game_nodes = [ 
	_0_,
	_1_,
	_2_,
	_3_,
	_4_,
	_5_,
	_6_,
	_7_,
	_8_,
	_9_,
	_10_,
	_11_,
]
var go := false
var finished := false
var accum : float = 0.0
var selected = []
var pattern = []
var position_active = -1

func _ready():
	
	# Cleanup node sprites
	_cleanup()
	
	# Determine possible hit points
	_generate()

	# Sweeping arm
	arm.name = 'arm'
	arm.rect_pivot_offset = Vector2(20, 168)
	
	# Initialize the Label
	label.text = "Click on the wheel when over a point!"

func _process(delta):
	
	if finished:
		label.text = "Well Done."
		return
	
	if go: # Wait for user input before beginning
		
		# End the game if the pattern is complete
		if pattern.empty():
			finished = true
		else:	
			game_nodes[pattern.back()].show()
		
		# Update Arm
		accum += delta
		arm.rect_rotation += abs(clamp(sin(accum), 0.3, 1)) * speed * delta * direction * combo

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
			
			if position_active == pattern.back():
				game_nodes[pattern.back()].modulate = Color(0, 1, 0)
				selected.push_back(pattern.back())
				pattern.pop_back()
				
				# Change direction of arm 
				direction = -direction
				combo += 1
		
			else:
				while !selected.empty():
					pattern.push_back(selected.pop_back())
				_cleanup()
				combo = 1
				label.text = "MISS"

# Helper Functions
func _cleanup():
	for node in game_nodes:
		node.modulate = Color(1, 1, 1)
		node.hide()
		
func _generate():
	while len(pattern) < difficulty:
		var rand = (randi() % 12)
		if !pattern.has(rand):
			pattern.append(rand)

# Signals
func _on__0__area_shape_entered(area_id, area, area_shape, self_shape):
	position_active = 0

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
