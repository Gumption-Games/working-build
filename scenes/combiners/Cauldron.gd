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
onready var c_arrow : Label = $Clockwise
onready var cc_arrow : Label = $CounterClockwise

export var skip_stirring := false
var allow_stirring := false

# Stirring variables
var loop = []
const k = 4
var pressed = false
var max_value = pow(2, k) - 1
enum {TOP=1, RIGHT=2, BOTTOM=4, LEFT=8} 
const clockwise = [[1, 2, 4, 8], [2, 4, 8, 1], [4, 8, 1, 2], [8, 1, 2, 4]]
const counter_clockwise = [[1, 8, 4, 2], [8, 4, 2, 1], [4, 2, 1, 8], [2, 1, 8, 4]]
export var stir_direction : int = 1
var spin_count : int = 0
var velocity : float = 0.0
export var VELOCITY_FACTOR : float = 1.0	# Increase velocity when stirring
export var MAX_VELOCITY : float = 8.0		# The maximum velocity that can be achieved
export var VELOCITY_DECAY : float = 0.10	# Decay velocity when no stirring
export var VELOCITY_THRESHOLD : float = 0.1	# Less than the threshold will clamp velocity to 0
export var goal_lower : float = VELOCITY_THRESHOLD # 3.0
export var goal_upper : float = 6.0
var accum : float = 0.0

enum OUTCOME { NONE, BURNED, DONE }
var mixture_state

# Progress Bar variables
onready var progressbar : ProgressBar = $ProgressBar
signal progress_max_changed(new_value)
signal progress_changed(new_value)
signal depleted
export var progress_max : int = 100	setget set_max_progress
onready var progress = 30 setget set_progress

# Progress Bar functions
func set_max_progress(value):
	progress_max = value
	progress_max = max(1, value)
	emit_signal("progress_max_changed", progress_max)
	
func set_progress(value):
	progress = value
	progress = clamp(progress, 0, progress_max)
	emit_signal("progress_changed", progress)
	
	if progress == 100:
		mixture_state = OUTCOME.DONE
	if progress == 0:
		mixture_state = OUTCOME.BURNED
		#emit_signal("depleted")
		
# Balance Bar variables
onready var balancebar : VSlider = $BalanceBar
signal balance_min_changed(new_value)
signal balance_max_changed(new_value)
signal balance_changed(new_value)
export var balance_min : int = 0#-MAX_VELOCITY setget set_min_balance
export var balance_max : int = MAX_VELOCITY setget set_max_balance
onready var balance : float = 0

# Balance Bar functions
func set_min_balance(value):
	balance_min = value
	balance_min = 0 
	#balance_min = min(0, value)
	emit_signal("balance_min_changed", balance_min)
	
func set_max_balance(value):
	balance_max = value
	balance_max = max(1, value)
	emit_signal("balance_max_changed", balance_max)
	
func set_balance(value):
	balance = value
	balance = clamp(balance, 0, MAX_VELOCITY)
	emit_signal("balance_changed", balance)
	
func update_balance(value):
	balance += value
	balance = min(balance, abs(velocity))
	balance = clamp(balance, 0, MAX_VELOCITY)
	emit_signal("balance_changed", balance)
	
# SweetSpot Bar variables
onready var sweetspotbar : VSlider = $BalanceBar/SweetSpot
signal sweetspot_min_changed(new_value)
signal sweetspot_max_changed(new_value)
signal sweetspot_changed(new_value)
export var sweetspot_min : int = 0#-MAX_VELOCITY setget set_min_sweetspot
export var sweetspot_max : int = MAX_VELOCITY setget set_max_sweetspot
onready var sweetspot : float = 0.0
onready var new_sweetspot : float = 0.0
var sweetspotFactor : int = 0

# SweetSpot Bar functions
func set_min_sweetspot(value):
	sweetspot_min = value
	sweetspot_min = 0
	print("this is the sweetspot min", sweetspot_min)
	#sweetspot_min = min(0, value)
	emit_signal("sweetspot_min_changed", sweetspot_min)
	
func set_max_sweetspot(value):
	sweetspot_max = value
	sweetspot_max = max(1, value)
	emit_signal("sweetspot_max_changed", sweetspot_max)
	
func set_sweetspot(value):
	sweetspot = value
	sweetspot = clamp(sweetspot, 1, MAX_VELOCITY)
	emit_signal("sweetspot_changed", sweetspot)

func update_sweetspot(value):
	sweetspot += value 
	if value > 0: 
		sweetspot = min(sweetspot, new_sweetspot) 
	else: 
		sweetspot = max(sweetspot, new_sweetspot)
		
	sweetspot = clamp(sweetspot, 1, MAX_VELOCITY)
	emit_signal("sweetspot_changed", sweetspot)
		
func _init():
	type = "Cauldron"


func _ready():
	connect("new_ingredient", self, "_on_new_ingredient")
	connect("no_ingredients", self, "_on_no_ingredients")
	connect("multiple_ingredients", self, "_on_multiple_ingredients")
	connect("correct_recipe_entered", self, "_on_correct_recipe_entered")
	set_disabled(true) # The Cauldron is empty to start
	label.hide()
	emit_signal("progress_max_changed", progress_max)
	emit_signal("progress_changed", progress)
	emit_signal("balance_min_changed", balance_min)
	emit_signal("balance_max_changed", balance_max)
	emit_signal("sweetspot_min_changed", sweetspot_min)
	emit_signal("sweetspot_max_changed", sweetspot_max)


func set_disabled(new_value:bool):
	top_shape.set_disabled(new_value)
	right_shape.set_disabled(new_value)
	left_shape.set_disabled(new_value)
	bottom_shape.set_disabled(new_value)
	allow_stirring = false
	if new_value: # if bowl is disabled
		bowl.hide()
		bowl_empty.show()
		progressbar.hide()
		balancebar.hide()
		set_progress(50)
		set_balance(0)
		set_sweetspot(rand_range(1, MAX_VELOCITY))
		velocity = 0
		c_arrow.hide()
		cc_arrow.hide()
	else: # bowl is holding something; show it
		bowl.show()
		bowl_empty.hide() 

func _on_new_ingredient():
	if NewIngredientSound.is_playing():
		NewIngredientSound.stop()
	NewIngredientSound.play(0.0)
	set_disabled(false) # The Cauldron is filled

func _on_no_ingredients():
	CookingSound.stop()
	set_disabled(true)

func _on_multiple_ingredients():
	CookingSound.play()
	set_disabled(false) # The Cauldron is filled

func _on_correct_recipe_entered():
	allow_stirring = true
	progressbar.show()
	balancebar.show()
	c_arrow.show()
	mixture_state = OUTCOME.NONE

func _flip_direction(check_direction):
	if check_direction == 1:
		c_arrow.show()
		cc_arrow.hide()
	else:
		c_arrow.hide()
		cc_arrow.show()
	return check_direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	accum += delta
	if accum >= 5:
		if accum >= 20 and progressbar.value > 90:
			accum = 0
			stir_direction = _flip_direction(-stir_direction)
		else:
			sweetspotFactor = [-1, 1][rand_range(0, 2)]
			new_sweetspot = stir_direction * sweetspotFactor + sweetspot
		
	if allow_stirring: # TODO: switch to using an enum state machine
		
		if mixture_state == OUTCOME.DONE:
			balancebar.hide()
			progressbar.hide()
			label.text = "Success!"
			label.show()
			
		elif mixture_state == OUTCOME.BURNED:
			balancebar.hide()
			progressbar.hide()
			label.text = "Fail!"
			label.show()

		else: # We're still stirring...
			if abs(sweetspotFactor) > 0:
				update_sweetspot(stir_direction * sweetspotFactor * delta)
			#if abs(velocity) > 0:
			#	update_balance(velocity * delta)
			#else:
			update_balance(stir_direction * velocity * delta)
			
			#if velocity >= goal_lower and velocity <= goal_upper: 
			if ((stir_direction * velocity) - 1) >= sweetspotbar.value:
				set_progress((progress - 5*delta))
				if (stir_direction * velocity) < 0:
					label.text = "Wrong Way"
				else:
					label.text = "Too Fast"
				label.show()
			elif ((stir_direction * velocity) + 1) <= sweetspotbar.value:
				set_progress((progress - 5*delta))
				if (stir_direction * velocity) < 0:
					label.text = "Wrong Way"
				else:
					label.text = "Too Slow"
				label.show()
			else:
				set_progress((progress + 5*delta))
				label.text = "Perfect!"
			# Decay velocity
			if not Input.is_mouse_button_pressed(BUTTON_LEFT):
				if abs(velocity) < VELOCITY_THRESHOLD:
					velocity = 0
				elif velocity >= VELOCITY_THRESHOLD:
					velocity -= delta
				elif velocity <= -VELOCITY_THRESHOLD:
					velocity += delta
			var current = bowl.get_rotation_degrees()
			bowl.set_rotation_degrees(current + (velocity))
	
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
			if _sum(loop) == max_value:
				_clockwise(loop)
				_counter_clockwise(loop)
				loop.clear()
				
				if StirSound.is_playing():
					StirSound.stop()
				StirSound.play(0.1)
				
			else:
				loop.clear()

func _clockwise(array):
	for combo in clockwise:
		if combo == array:
			_acceleration(VELOCITY_FACTOR)

func _counter_clockwise(array):
	for combo in counter_clockwise:
		if combo == array:
			_acceleration(-VELOCITY_FACTOR)

func _acceleration(factor:float):
	if velocity < MAX_VELOCITY and velocity > -MAX_VELOCITY:
		velocity = velocity + factor

func _sum(array):
	var sum = 0
	for i in array:
		sum += i
	return sum
	
func _on_Cauldron_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if mixture_state == OUTCOME.DONE or skip_stirring:
			minigame_result(true)
			reset_cauldron()
		elif mixture_state == OUTCOME.BURNED:
			minigame_result(false)
			reset_cauldron()

func reset_cauldron():
	set_disabled(true)
	label.set_modulate(Color(Color.white))
	bowl.set_modulate(Color(Color.white))
	label.hide()
	result_name = null
