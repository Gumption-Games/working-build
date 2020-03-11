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
onready var label : Label = $Label
onready var cook_timer : Timer = $CookTimer
onready var sitting_timer : Timer = $SittingTimer
onready var burn_timer : Timer = $BurnTimer

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
export var VELOCITY_DECAY : float = 0.10	# Decay velocity when no stirring
export var VELOCITY_THRESHOLD : float = 0.1	# Less than the threshold will clamp velocity to 0
export var goal_lower : float = VELOCITY_THRESHOLD # 3.0
export var goal_upper : float = 6.0

enum OUTCOME { NONE, BURNED, DONE }
var mixture_state

signal max_changed(new_value)
signal changed(new_value)
signal depleted
signal balance_changed(new_value)
onready var progressbar : ProgressBar = $ProgressBar
onready var balancebar : HSlider = $BalanceBar
onready var balance : float = 0
export var progress_max : int = 100	setget set_max# This may be changed to starting progress
onready var progress = 20 setget set_current

func set_balance(value):
	balance = value
	balance = clamp(balance, -10, 10)
	emit_signal("balance_changed", balance)

func set_max(value):
	progress_max = value
	progress_max = max(1, value)
	emit_signal("max_changed", progress_max)
	
func set_current(value):
	progress = value
	progress = clamp(progress, 0, progress_max)
	emit_signal("changed", progress)
	
	if progress == 0:
		emit_signal("depleted")
		

func _init():
	type = "Cauldron"
	minigame_path = "res://scenes/skillchecks/cauldron/CauldronSkillCheck.tscn"

func _ready():
	connect("new_ingredient", self, "_on_new_ingredient")
	connect("no_ingredients", self, "_on_no_ingredients")
	connect("multiple_ingredients", self, "_on_multiple_ingredients")
	connect("correct_recipe_entered", self, "_on_correct_recipe_entered")
	set_disabled(true) # The Cauldron is empty to start
	label.hide()
	progressbar.hide()
	balancebar.hide()
	emit_signal("max_changed", progress_max)
	emit_signal("changed", progress)


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


func _on_correct_recipe_entered():
	allow_stirring = true
	cook_timer.start()
	label.text = str(int(cook_timer.get_time_left()))
	label.show()
	progressbar.show()
	balancebar.show()
	mixture_state = OUTCOME.NONE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if allow_stirring: # TODO: switch to using an enum state machine
		
		if mixture_state == OUTCOME.DONE:
			label.text = "Done!"
		elif mixture_state == OUTCOME.BURNED:
			label.text = "Burned!"
		else: # We're still stirring...
			if abs(velocity) > 0:
				set_balance(velocity)
			else:
				set_balance(0)
			
			if velocity >= goal_lower and velocity <= goal_upper: 
				set_current((progress + 5*delta))
			else:
				set_current((progress - 5*delta))
			# Decay velocity
			if not Input.is_mouse_button_pressed(BUTTON_LEFT):
				if abs(velocity) < VELOCITY_THRESHOLD:
					velocity = 0
				elif velocity >= VELOCITY_THRESHOLD:
					velocity -= VELOCITY_DECAY
				elif velocity <= -VELOCITY_THRESHOLD:
					velocity += VELOCITY_DECAY
			var current = bowl.get_rotation_degrees()
			bowl.set_rotation_degrees(current + (velocity))
			
			label.text = str(int(cook_timer.get_time_left()))
#			if not sitting_timer.is_stopped():
#				if fmod(sitting_timer.get_time_left(), 0.5) == 0:
#					label.set_modulate(Color(Color.red))
#				else:
#					label.set_modulate(Color(Color.white))
			
			if abs(velocity) < goal_lower and sitting_timer.is_stopped() and burn_timer.is_stopped():
				# Make it start to burn
				sitting_timer.start()
				print("Burning!")
		
#		if not done:
#			if abs(velocity) > goal_upper:
#				# Too fast!!
#				bowl.set_modulate(Color(0.0, 0.2, 1.0))
#			elif abs(velocity) < goal_lower:
#				# Too slow!
#				bowl.set_modulate(Color(1.0, 0.2, 0.2))
#			else:
#				# Just right.
#				bowl.set_modulate(Color(1.0, 1.0, 1.0))


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
	if mixture_state != OUTCOME.NONE:
		return
	if pressed == true:
		loop.append(AREA)
		if loop.size() == k:
			print(loop)
			if _sum(loop) == max_value:
				_clockwise(loop)
				_counter_clockwise(loop) 
				loop.clear()
				
				# I'm stirring, it won't burn!
				burn_timer.stop()
				sitting_timer.stop()
				label.set_modulate(Color(Color.white))
				if StirSound.is_playing():
					StirSound.stop()
				StirSound.play(0.1)
				
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


func _counter_clockwise(array):
	for combo in counter_clockwise:
		if combo == array:
			if spin_count > 1:
				spin_count = 0
			spin_count -= 1
			_acceleration(-VELOCITY_FACTOR)
			print("Counter Clockwise")


func _acceleration(factor:float):
	if velocity < MAX_VELOCITY and velocity > -MAX_VELOCITY:
		velocity = velocity + factor
		#velocity = (DEL_VELOCITY * (1 + DEL_VELOCITY/100.0))


func _sum(array):
	var sum = 0
	for i in array:
		sum += i
	return sum


func _on_CookTimer_timeout():
	# Yay! We stirred it without it burning.
	mixture_state = OUTCOME.DONE
	sitting_timer.stop()
	burn_timer.stop()
	

func _on_SittingTimer_timeout():
	# The mixture has sat for too long, and it will start to burn
	burn_timer.start()
	label.set_modulate(Color(Color.orange))


func _on_BurnTimer_timeout():
	# The mixture has burned!
	mixture_state = OUTCOME.BURNED
	label.set_modulate(Color(Color.red))
	bowl.set_modulate(Color(0.8, 0.8, 0.8))


func _on_Cauldron_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if mixture_state == OUTCOME.DONE:
			minigame_result(true)
			reset_cauldron()
		elif mixture_state == OUTCOME.BURNED:
			minigame_result(false)
			reset_cauldron()
		else:
			print("Not done yet...")


func reset_cauldron():
	cook_timer.stop()
	sitting_timer.stop()
	burn_timer.stop()
	set_disabled(true)
	label.set_modulate(Color(Color.white))
	bowl.set_modulate(Color(Color.white))
	label.hide()
	result_name = null


