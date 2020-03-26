class_name Chalk extends Combiner

const EASY = 1
const MED = 2
const HARD = 3

const CircleNode = preload("./CircleNode.tscn")
const score_text = "Score: %d\nLives: %d"
onready var scores := $HUD/Scores
onready var start_button := $HUD/Button
onready var chalk_icon := $UI/ChalkIcon
onready var chalk_line := $ChalkLine
onready var sprite := $Sprite
var rng = RandomNumberGenerator.new()

var difficulty = MED
var path = []
var generated_path = []
var cemented_lines = []
var pressed = false
var positions
var failed = false
var score = 0
var lives = 3
var flash_delay = 0.4
var delay_increment = 0.8
var centre = Vector2(0, 0)

var chalk_start_point = Vector2(40, 100)

var path_length = {
	EASY: 5,
	MED: 6,
	HARD: 8
}

var nodes = {
	EASY: [0, 1, 2, 5, 6, 7, 10, 11, 12],
	MED: [0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 15, 16, 17, 18],
	HARD: [0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 15, 16, 17, 18]
#	HARD: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
#			13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
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


func _init():
	type = "Circle"


func _ready():
#	$Sprite.hide()
	connect("correct_recipe_entered", self, "_on_correct_recipe_entered")
	if get_owner() == null:
		centre.x = ProjectSettings.get_setting("display/window/size/width")/2
		centre.y = ProjectSettings.get_setting("display/window/size/height")/2
		$HUD.position = centre
	else:
		chalk_line.global_position = Vector2(0, 0)

	chalk_icon.position = chalk_start_point
	print(centre*2)

	randomize()
	_calculate_positions()


func _input(event):
	if chalk_icon.dragging and event is InputEventMouseMotion:
		chalk_line.add_point(event.global_position)


func _wait(time):
	yield(get_tree().create_timer(time), "timeout")


func _detect_connection(NODE):
	if chalk_icon.dragging and not NODE in path:
		path.append(NODE)
		if path == generated_path:
			print('WINNER')
		elif len(path) > path_length[difficulty]:
			failed = true
		print(path)


func _calculate_positions():
	positions = Dictionary()
	
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


func _instance_nodes():
	# Instance all required nodes for current difficulty
	for idx in nodes[difficulty]:
		var new_node = CircleNode.instance()
		new_node.z_index = 3
		new_node.idx = idx
		new_node.position = positions[idx]
		new_node.connect("node_entered", self, "_detect_connection")
		node_ids[idx] = new_node
		add_child(new_node)


func _on_correct_recipe_entered():
	sprite.hide()
	_instance_nodes()
	$HUD.show()


func _generate_path():
	var pool = nodes[difficulty].duplicate()
	var new_node = pool[randi() % pool.size()] # Grab a random starting node
	generated_path = [ new_node ]

	while len(generated_path) < path_length[difficulty]:
		pool = neighbors[new_node].duplicate() # Pick from last node's neighbours
		
		while generated_path.has(new_node) or not new_node in nodes[difficulty]:
			# If the path corners itself, we must return early
			if pool.empty():
				print(generated_path)
				print("Cornered!")
				if len(generated_path) < path_length[difficulty]-1:
					return true
				return

			# Pick random item and remove from pool
			var rand_idx = randi() % pool.size()
			new_node = pool[rand_idx]
			pool.remove(rand_idx)
		
		# If a suitable node is found, add to generated path
		generated_path.append(new_node)
	print(generated_path)


func _get_nodes_by_id(needed: Array):
	var nodes_dict = {}
	var children = get_children()
	print(get_child_count())
	for node in children:
		if node.get("type") != "CircleNode":
			continue
		if node.idx in needed:
			nodes_dict[node.idx] = node
	return nodes_dict


func _get_outcome(): # TODO: find a more efficient way to do this check
	var result = path==generated_path
	var path_minus_first = generated_path.duplicate()
	path_minus_first.pop_front()

	return result or path == path_minus_first


func _update_scores(success):
	if success:
		_win_state()
	else:
		_fail_state()
	scores.set_text(score_text%[score, lives])


func _win_state():
	score += 1
	flash_delay *= delay_increment
	chalk_icon.disabled = true
#	yield(_flash_all('G', 1.0), "completed")
	_cement_line()
	start_button.set_text("Next")
	start_button.disabled = false
	if score >= 3:
		_end_game(true)


func _cement_line():
	var new_line = Line2D.new()
	add_child(new_line)
	new_line.z_index = 1

	for idx in generated_path:
		var point = node_ids[idx].position
		new_line.add_point(point)
	new_line.default_color = Color(0.6, 0.6, 0.8, 0.8)
	cemented_lines.append(new_line)


func _fail_state():
	lives -= 1
	if lives <= 0:
		_end_game(false)
		return
	# flash for failure
	for i in range(3):
		yield(_flash_all('R', 0.4), "completed")
	yield(get_tree().create_timer(0.5), "timeout")
	_show_path_hint()


func _end_game(win):
	chalk_icon.disabled = true
	$UI/Fail.visible = true
#	yield(, "timeout")
	lives = 3
	score = 0
	scores.set_text(score_text%[score, lives])
#	start_button.set_text("Try Again")
	start_button.disabled = false
	for line in cemented_lines:
		line.queue_free()

	minigame_result(win)
	clear_scene()


func _show_path_hint():
#	var hint_nodes = _get_nodes_by_id(generated_path)
#	print(hint_nodes)
	chalk_icon.hide() # Disable chalk while path is shown
	for idx in generated_path:
		yield(node_ids[idx].flash('B', flash_delay), "completed")

	# Move chalk to starting node
	chalk_icon.position = node_ids[generated_path[0]].global_position
	print(chalk_icon.position)
	chalk_icon.show()



func _flash_all(c, delay):
	for node in node_ids.values():
		node.flash(c, delay)
	yield(get_tree().create_timer(2*delay), "timeout")


func _on_Start():
#	print(chalk_icon.position)
#	chalk_icon.show()
#	chalk_icon.position.x += 100
	$UI/Fail.visible = false
	start_button.disabled = true
	
	while _generate_path():
		pass
	_show_path_hint()
	chalk_icon.disabled = false


func reset():
	var success = _get_outcome()
	OS.delay_msec(400)
	chalk_line.clear_points()
#	chalk_icon.position = chalk_start_point
	chalk_icon.hide()
	_update_scores(success)
	path.clear()


func clear_scene():
	for idx in nodes[difficulty]:
		node_ids[idx].queue_free()
	node_ids = {}
	sprite.show()
	$HUD.hide()
	result_name = null
