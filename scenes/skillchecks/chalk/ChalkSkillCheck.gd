extends "res://scenes/skillchecks/SkillCheck.gd"

const EASY = 1
const MED = 2
const HARD = 3

var difficulty
var rng = RandomNumberGenerator.new()
var current = null
var path = []
var generated_path = []
var pressed = false
var positions

var CircleNode = preload("./CircleNode.tscn")
var chalk_start_point = Vector2(40, 100)

var path_length = {
	EASY: 4,
	MED: 6,
	HARD: 9
}

var nodes = {
	EASY: [0, 1, 2, 5, 6, 7, 10, 11, 12],
	MED: [0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 15, 16, 17, 18],
	HARD: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
			13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
}

const neighbors = {
    0: [1, 5, 6],
    1: [0, 2, 5, 6, 7],
    2: [1, 3, 6, 7, 8],
    3: [2, 4, 7, 8, 9],
    4: [3, 8, 9],
    5: [0, 1, 6, 10, 11],
    6: [0, 1, 2, 5, 7, 10, 11, 12],
    7: [1, 2, 3, 6, 8, 11, 12, 13],
    8: [2, 3, 4, 7, 9, 12, 13, 14],
    9: [3, 4, 8, 13, 14],
    10: [5, 6, 11, 15, 16],
    11: [5, 6, 7, 10, 12, 15, 16, 17],
    12: [6, 7, 8, 11, 13, 16, 17, 18],
    13: [7, 8, 9, 12, 14, 17, 18, 19],
    14: [8, 9, 13, 18, 19],
    15: [10, 11, 16, 20, 21],
    16: [10, 11, 12, 15, 17, 20, 21, 22],
    17: [11, 12, 13, 16, 18, 21, 22, 23],
    18: [12, 13, 14, 17, 19, 22, 23, 24],
    19: [13, 14, 18, 23, 24],
    20: [15, 16, 21],
    21: [15, 16, 17, 20, 22],
    22: [16, 17, 18, 21, 23],
    23: [17, 18, 19, 22, 24],
    24: [18, 19, 23]
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$Chalk/ChalkIcon.position = chalk_start_point
	print(ProjectSettings.get_setting("display/window/size/height"))
	
	difficulty = EASY
	rng.randomize()
	generate_path()
	
	# Instance all required nodes for current difficulty
	_calculate_positions()
	for idx in nodes[difficulty]:
		var new_node = CircleNode.instance()
		new_node.idx = idx
		new_node.position = positions[idx]
		new_node.connect("node_entered", self, "_detect_connection")
		add_child(new_node)

func _test_signals(idx):
	print("Entered ", idx)


func _input(event):
	# Detect pressed in order to use it in 
	if event is InputEventMouseButton: 
		if event.pressed == true:
			pressed = true
		else:
			pressed = false
			path.clear()
	if $Chalk/ChalkIcon.dragging and event is InputEventMouseMotion:
		$Chalk.add_point(event.position)


func _detect_connection(NODE):
#	if pressed == true:
	if $Chalk/ChalkIcon.dragging:
		path.append(NODE)
		if path == generated_path:
			print('WINNER')
		for i in range(path.size()):
			if path[i] != generated_path[i]:
				print('incorrect')
		print(path)
		
###NeW

func _calculate_positions():
	var centre = Vector2()
	positions = Dictionary()
	centre.x = ProjectSettings.get_setting("display/window/size/width")/2
	centre.y = ProjectSettings.get_setting("display/window/size/height")/2
	
	var width
	var spacing = 50
	if difficulty == EASY:
		width = 3
	elif difficulty == MED:
		width = 4
	elif difficulty == HARD:
		width = 5
	var used = nodes[difficulty]
	var row_ends = []
	for i in range(width): row_ends.append(used[i*width-1])
	centre.y -= (width-1)*spacing
	for idx in used:
		positions[idx] = centre
		if not idx in row_ends:
			centre.x += spacing
			centre.y += spacing
		else: # End of the row
			centre.x -= width*spacing
			centre.y -= (width-2) * spacing

func generate_path():
	var pool = nodes[difficulty]
	var new_node = pool[randi() % pool.size()] # Grab a random starting node
	generated_path = [ new_node ]

	while len(generated_path) < path_length[difficulty]:
		print(generated_path)
		pool = neighbors[new_node] # Pick from last node's neighbours
		
		while generated_path.has(new_node):
			# Pick random item and remove from pool
			var rand_idx = randi() % pool.size()
			new_node = pool[rand_idx]
			pool.remove(rand_idx)
			
			# If the path corners itself, we must return early
			if pool.empty():
				print("Cornered!")
				return generated_path
		
		# If a suitable node is found, add to generated path
		generated_path.append(new_node)
	
	# Suitable path generated; print
	print(generated_path)