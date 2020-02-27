class_name Cauldron extends Combiner

# References to child nodes
onready var StirSound := $StirSound
onready var NewIngredientSound := $NewIngredientSound
onready var CookingSound := $CookingSound
onready var bowl : Sprite = $Bowl
onready var top_shape : Area2D = $Bowl/Top/CollisionShape2D
onready var right_shape : Area2D = $Bowl/Right/CollisionShape2D
onready var bottom_shape : Area2D = $Bowl/Bottom/CollisionShape2D
onready var left_shape : Area2D = $Bowl/Left/CollisionShape2D
onready var bowl_empty : Sprite = $BowlEmpty

var allow_stirring := false

# Stirring variables
var loop = []
const k = 4
var pressed = false
var max_value = pow(2, k) - 1
enum {TOP=1, RIGHT=2, BOTTOM=4, LEFT=8} 
const clockwise = [[1, 2, 4, 8], [2, 4, 8, 1], [4, 8, 1, 2], [8, 1, 2, 4]]
const counter_clockwise = [[1, 8, 4, 2], [8, 4, 2, 1], [4, 2, 1, 8], [2, 1, 8, 4]]
var spin_count : int = 0
var velocity : float = 0.0
export var VELOCITY_FACTOR : float = 1.1	# Increase velocity when stirring
export var MAX_VELOCITY : float = 7.0		# The maximum velocity that can be achieved
export var VELOCITY_DECAY : float = 0.01	# Decay velocity when no stirring
export var VELOCITY_THRESHOLD : float = 0.1	# Less than the threshold will clamp velocity to 0

# Timing variables
export var goal_lower : float = 3.0
export var goal_upper : float = 6.0
var done : bool = false
var win : bool = false


func _init():
	type = "Cauldron"
	minigame_path = "res://scenes/skillchecks/cauldron/CauldronSkillCheck.tscn"


func _ready():
	connect("new_ingredient", self, "_on_new_ingredient")
	connect("no_ingredients", self, "_on_no_ingredients")
	connect("multiple_ingredients", self, "_on_multiple_ingredients")
	set_disabled(true) # The Cauldron is empty to start


func set_disabled(new_value:bool):
	top_shape.set_disabled(new_value)
	right_shape.set_disabled(new_value)
	left_shape.set_disabled(new_value)
	bottom_shape.set_disabled(new_value)
	if new_value: # if bowl is disabled
		bowl.hide()
		bowl_empty.show()
	else:
		bowl.show()
		bowl_empty.hide()


func _on_new_ingredient():
	if NewIngredientSound.is_playing():
		NewIngredientSound.stop()
	NewIngredientSound.play(0.0)


func _on_no_ingredients():
	CookingSound.stop()


func _on_multiple_ingredients():
	CookingSound.play()
	set_disabled(false) # The Cauldron is filled
	allow_stirring = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if allow_stirring:
		# Update velocity
		if not Input.is_mouse_button_pressed(BUTTON_LEFT):
			if abs(velocity) < VELOCITY_THRESHOLD:
				velocity = 0
			elif velocity >= VELOCITY_THRESHOLD:
				velocity -= VELOCITY_DECAY
			elif velocity <= -VELOCITY_THRESHOLD:
				velocity += VELOCITY_DECAY
		var current = bowl.get_rotation_degrees()
		bowl.set_rotation_degrees(current + (velocity))
		
		# Modulate sprite to show feedback for how fast the stirring is
		if not done:
			if abs(velocity) > goal_upper:
				# Too fast!!
				bowl.set_modulate(Color(0.0, 0.2, 1.0))
			elif abs(velocity) < goal_lower:
				# Too slow!
				bowl.set_modulate(Color(1.0, 0.2, 0.2))
			else:
				# Just right.
				bowl.set_modulate(Color(1.0, 1.0, 1.0))


func _input(event):
	# Detect pressed in order to use it in 
	if event is InputEventMouseButton: 
		if event.pressed == true:
			pressed = true
		else:
			pressed = false


func _on_Top_mouse_entered():
	_detect_stir(TOP)


func _on_Right_mouse_entered():
	_detect_stir(RIGHT)


func _on_Bottom_mouse_entered():
	_detect_stir(BOTTOM)


func _on_Left_mouse_entered():
	_detect_stir(LEFT)


func _detect_stir(AREA):
	# Occurs when one of the 4 areas is entered by the mouse
	if done:
		return
	if pressed == true:
		loop.append(AREA)
		if loop.size() == k:
			print(loop)
			if _sum(loop) == max_value:
				_clockwise(loop)
				_counter_clockwise(loop) 
				loop.clear()
			else:
				loop.clear()


func _clockwise(array):
	for combo in clockwise:
		if combo == array:
			if spin_count < 1:
				spin_count = 0
			spin_count += 1
			_acceleration(VELOCITY_FACTOR)
			print("Clockwise")
	if StirSound.is_playing():
		StirSound.stop()
	StirSound.play(0.1)


func _counter_clockwise(array):
	for combo in counter_clockwise:
		if combo == array:
			if spin_count > 1:
				spin_count = 0
			spin_count -= 1
			_acceleration(-VELOCITY_FACTOR)
			print("Counter Clockwise")
	if StirSound.is_playing():
		StirSound.stop()
	StirSound.play(0.1)


func _acceleration(factor:float):
	if velocity < MAX_VELOCITY and velocity > -MAX_VELOCITY:
		velocity = velocity + factor
		#velocity = (DEL_VELOCITY * (1 + DEL_VELOCITY/100.0))


func _sum(array):
	var sum = 0
	for i in array:
		sum += i
	return sum

