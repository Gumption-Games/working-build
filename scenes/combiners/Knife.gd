class_name Knife extends Combiner

var CutPointScene := preload("res://scenes/combiners/CutPoint.tscn")

# Play with these values to change the game
export var hit_area_width := 10
export var hit_area_speed : float = 1.0
export var amplitude_factor : float = 1.5
export var num_cuts : int = 3
export var cutpoint_width : float = 4.0

var sine_x : float = -PI/2.0 # see hitarea.pos formula in _process()
const SPEED : int = 30

onready var label := $Label
onready var arm := $CelestialWheel/Arm
onready var hitarea := $CelestialWheel/Arm/HitArea
onready var hitshape := $CelestialWheel/Arm/HitArea/CollisionShape2D
#onready var ingredient_pos : Vector2 = $Ingredient.position
#onready var ingredient_size : Vector2 = $Ingredient.get_rect().size
onready var center := Vector2(0, 0) 
#onready var top_left := Vector2(ingredient_pos.x-ingredient_size.x/2, ingredient_pos.y-ingredient_size.y/2)
#onready var peak := Vector2(ingredient_pos.x-(ingredient_size.x/amplitude_factor), ingredient_pos.y-(ingredient_size.y/amplitude_factor))

var go := false
var finished := false
var accum : float = 0.0
var l = []

func _ready():
	for i in range(5):
		l.append(int(rand_range(0, 60)))
	# Determine possible cutting points
	for i in l:
		var cutpoint = CutPointScene.instance()
		add_child(cutpoint)
		var angle2 = i * (360/60)
		#var dot2 = CutPointScene.instance()
		cutpoint.name = 'dot2_%d' % (i+1)
		#dot2.rect_size = Vector2(2,2)
		var cutpoint_rect_pivot_offset = Vector2(1,1)
		cutpoint.width = 8.0
		cutpoint.height = 8.0
		cutpoint.position = (center-cutpoint_rect_pivot_offset) + Vector2(cos(deg2rad(angle2)), sin(deg2rad(angle2))) * 100
		#dot2.color = Color('#ffffff')
		cutpoint.shape.set_extents(Vector2(cutpoint.width, cutpoint.height))
		#add_child(dot2)
	
	# Sweeping arm
	#var arm = ColorRect.new()
	arm.name = 'arm'
	#arm.rect_size = Vector2(3, 90)
	print(arm.rect_size)
	arm.rect_pivot_offset = Vector2(20, 168)
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(3, 90)
	hitshape.set_shape(shape)
	
	#arm.rect_position = (center-arm.rect_pivot_offset)
	#var hit_area_rect_pivot_offset = Vector2(1.5, 190)
	#hitarea.position = (center)
	#arm.color = Color('#00bbff')
	#add_child(arm)
	
	# TODO: Set the texture of $Ingredient to whatever we are cutting
	
	# Create the Cut Points
#	for i in range(top_left.x+ingredient_size.x/(num_cuts+1), top_left.x+ingredient_size.x, ingredient_size.x/(num_cuts+1)):
#		var cutpoint = CutPointScene.instance()
#		add_child(cutpoint)
#		cutpoint.position = Vector2(i, ingredient_pos.y)
#		cutpoint.width = cutpoint_width
#		cutpoint.height = ingredient_size.y/2
#		cutpoint.shape.set_extents(Vector2(cutpoint.width, cutpoint.height))
	
	# Initialize the HitArea and its collision shape
	#hitarea.position = Vector2(arm.rect_position.x, arm.rect_position.y)

	
	# Initialize the Label
	label.text = "Click when the boxes\nline up to cut"

func _process(delta):
	
	if finished:
		return
	
	if go: # Wait for user input before beginning
		# Now check to see if we're done
		accum += delta
		arm.rect_rotation = int(SPEED * accum) % 360
		finished = true
		for child in get_children():
			print(child)
			if child is CutPoint:
				if child.cut==false:
					finished = false
					break
		if finished:
			label.text = "well done."
		
		# Move the HitArea on a sine wave
		sine_x += hit_area_speed * delta
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
			# Cut!
			var hits = hitarea.get_overlapping_areas()
			var got_a_hit := false
			if hits: # if we got a cut
				for hit in hits:
					if hit is CutPoint:
						hit.cut = true
						print("Cut!")
						label.text = "nice !"
						got_a_hit = true
			if not got_a_hit:
				print("Nope!")
				label.text = "miss"
