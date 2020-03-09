extends "res://scenes/skillchecks/SkillCheck.gd"

const EASY = 1
const MED = 2
const HARD = 3

const CircleNode = preload("./CircleNode.tscn")
var rng = RandomNumberGenerator.new()

var difficulty = EASY
var path = []
var generated_path = []
var pressed = false
var positions
var failed = false
var score = 0
var lives = 3
var flash_delay = 0.4

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

var node_ids = {}

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
	$ChalkIcon.position = chalk_start_point
	print(ProjectSettings.get_setting("display/window/size/height"))

	randomize()
	
	# Instance all required nodes for current difficulty
	_calculate_positions()
	for idx in nodes[difficulty]:
		var new_node = CircleNode.instance()
		new_node.idx = idx
		new_node.position = positions[idx]
		new_node.connect("node_entered", self, "_detect_connection")
		node_ids[idx] = new_node
		add_child(new_node)


func _input(event):
	if $ChalkIcon.dragging and event is InputEventMouseMotion:
		$Chalk.add_point(event.position)


func _wait(time):
	yield(get_tree().create_timer(time), "timeout")


func _detect_connection(NODE):
	if $ChalkIcon.dragging and not NODE in path:
		path.append(NODE)
		if path == generated_path:
			print('WINNER')
		elif len(path) > path_length[difficulty]:
			failed = true
		print(path)


func _calculate_positions():
	var centre = Vector2()
	positions = Dictionary()
	centre.x = ProjectSettings.get_setting("display/window/size/width")/2
	centre.y = ProjectSettings.get_setting("display/window/size/height")/2
	
	var width
	var spacing = 50
	if difficulty == EASY:
		width = 3
		spacing = 65
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


func _generate_path():
	var pool = nodes[difficulty].duplicate()
	var new_node = pool[randi() % pool.size()] # Grab a random starting node
	generated_path = [ new_node ]

	while len(generated_path) < path_length[difficulty]:
		pool = neighbors[new_node].duplicate() # Pick from last node's neighbours
		
		while generated_path.has(new_node) or not new_node in nodes[difficulty]:
			# Pick random item and remove from pool
			var rand_idx = randi() % pool.size()
			new_node = pool[rand_idx]
			pool.remove(rand_idx)
			
			# If the path corners itself, we must return early
			if pool.empty():
				print(generated_path)
				print("Cornered!")
				return
		
		# If a suitable node is found, add to generated path
		generated_path.append(new_node)
	print(generated_path)


func _get_nodes_by_id(needed: Array):
	var nodes_dict = {}
	var children = get_children()
	print(get_child_count())
	for node in children:
		print(node.get("type"))
		if node.get("type") != "CircleNode":
			continue
		if node.idx in needed:
			nodes_dict[node.idx] = node
	return nodes_dict


func _get_outcome():
	return path == generated_path


func _update_scores(success):
	if success:
		_win_state()
		print("Winner! Score = %d"%score)
	else:
		_fail_state()
		print("Loser! %d lives left."%lives)


func _win_state():
	score += 1
	$ChalkIcon.disabled = true
	yield(_flash_all('G', flash_delay*2), "completed")
	$Button.disabled = false


func _fail_state():
	lives -= 1
	# flash for failure
	for i in range(3):
		yield(_flash_all('R', flash_delay), "completed")
	yield(get_tree().create_timer(0.5), "timeout")
	_show_path_hint()


func _show_path_hint():
#	var hint_nodes = _get_nodes_by_id(generated_path)
#	print(hint_nodes)
	for idx in generated_path:
		yield(node_ids[idx].flash('B', flash_delay), "completed")


func _flash_all(c, delay):
	for node in node_ids.values():
		node.flash(c, delay)
	yield(get_tree().create_timer(2*delay), "timeout")


func _on_Start():
	$Button.disabled = true
	_generate_path()
	_show_path_hint()
	$ChalkIcon.disabled = false


func reset():
	var success = _get_outcome()
	OS.delay_msec(400)
	$Chalk.clear_points()
	$ChalkIcon.position = chalk_start_point
	_update_scores(success)
	path.clear()
