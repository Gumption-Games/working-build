class_name CauldronSkillCheck extends SkillCheck

onready var top : Area2D = $Bowl/Top
onready var right : Area2D = $Bowl/Right
onready var bottom : Area2D = $Bowl/Bottom
onready var left : Area2D = $Bowl/Left
onready var sprite : Sprite = $Bowl
onready var label : Label = $Label
onready var timer : Timer = $Timer
onready var dietimer : Timer = $DieTimer
onready var exittimer: Timer = $ExitTimer
onready var StirSound := $StirSound

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

export var goal_lower : float = 3.0
export var goal_upper : float = 6.0
var done : bool = false
var win : bool = false

func _ready():
	$Label.text = "Stir!\n" + str(timer.wait_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Update velocity
	#print(velocity)
	if not Input.is_mouse_button_pressed(BUTTON_LEFT):
		if abs(velocity) < VELOCITY_THRESHOLD:
			velocity = 0
		elif velocity >= VELOCITY_THRESHOLD:
			velocity -= VELOCITY_DECAY
		elif velocity <= -VELOCITY_THRESHOLD:
			velocity += VELOCITY_DECAY
	var current = sprite.get_rotation_degrees()
	sprite.set_rotation_degrees(current + (velocity))
	
	# Update label to display the timer's time left
	if not done:
		if timer.is_stopped():
			label.text = "Stir!\n" + str(timer.wait_time)
		else:
			label.text = "Stir!\n" + str(int(timer.get_time_left()))
	
	# Modulate sprite to show feedback for how fast the stirring is
	if not done:
		if abs(velocity) > goal_upper:
			# Too fast!!
			if dietimer.is_stopped():
				dietimer.start()
			sprite.set_modulate(Color(0.0, 0.2, 1.0))
		elif abs(velocity) < goal_lower:
			# Too slow!
			if dietimer.is_stopped():
				dietimer.start()
			sprite.set_modulate(Color(1.0, 0.2, 0.2))
		else:
			# Just right.
			dietimer.stop()
			dietimer.wait_time = 5.0
			sprite.set_modulate(Color(1.0, 1.0, 1.0))
	
func _input(event):
	if event is InputEventMouseButton: 
		if event.pressed == true:
			pressed = true
		else:
			pressed = false

func _on_Top_mouse_entered():
	on_area_entered(TOP)

func _on_Right_mouse_entered():
	on_area_entered(RIGHT)

func _on_Bottom_mouse_entered():
	on_area_entered(BOTTOM)

func _on_Left_mouse_entered():
	on_area_entered(LEFT)

func _sum(array):
	var sum = 0
	for i in array:
		sum += i
	return sum

func _acceleration(factor:float):
	if velocity < MAX_VELOCITY and velocity > -MAX_VELOCITY:
		velocity = velocity + factor
		#velocity = (DEL_VELOCITY * (1 + DEL_VELOCITY/100.0))

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

func on_area_entered(pos):
	# Occurs when one of the 4 areas is entered by the mouse
	
	if done:
		return
	
	if pressed == true:
		if timer.is_stopped():
			timer.start()
		
		loop.append(pos)
		if loop.size() == k:
			print(loop)
			if _sum(loop) == max_value:
				_clockwise(loop)
				_counter_clockwise(loop) 
				loop.clear()
			else:
				loop.clear()

func _on_Timer_timeout():
	# Win!
	done = true
	win = true
	timer.stop()
	dietimer.stop()
	label.text = "Done!\n" + str(int(timer.get_time_left()))
	exittimer.start()

func _on_DieTimer_timeout():
	# Fail!
	done = true
	win = false
	timer.stop()
	dietimer.stop()
	label.text = "Fail!\n" + str(int(timer.get_time_left()))
	exittimer.start()

func _on_ExitTimer_timeout():
	return_result(win)