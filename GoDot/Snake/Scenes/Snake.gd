class_name Snake extends Node2D

@onready var audio_stream_player = $AudioStreamPlayer
var hurt_sound = preload("res://Assets/Audio/hurt.wav")
var grow_sound = preload("res://Assets/Audio/pickUp.wav")

var head = Minisnake.new()
var tail = [] as Array[Minisnake]

var current_dir = Vector2.RIGHT
var next_dir = Vector2.RIGHT
var tween_move: Tween

signal hit(minisnake_hit: Minisnake)


func _ready():
	head.size = Settings.CELL_SIZE
	head.color = Colors.GREEN
	tail.push_front(head)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	hit.connect(_on_hit)
	
	tween_move = create_tween().set_loops()
	tween_move.tween_callback(move).set_delay(.075)


func _process(delta):
	queue_redraw()


func _draw():
	for minisnake in tail:
		draw_rect(minisnake.get_rect(), minisnake.color)


func _input(event):
	if event.is_action_pressed("move_left") and current_dir != Vector2.RIGHT:
		next_dir = Vector2.LEFT
	if event.is_action_pressed("move_right") and current_dir != Vector2.LEFT:
		next_dir = Vector2.RIGHT
	if event.is_action_pressed("move_up") and current_dir != Vector2.DOWN:
		next_dir = Vector2.UP
	if event.is_action_pressed("move_down") and current_dir != Vector2.UP:
		next_dir = Vector2.DOWN


func move():
	current_dir = next_dir
	var next_pos = head.current_pos + (current_dir * Settings.CELL_SIZE)
	next_pos.x = fposmod(next_pos.x, Settings.GRID_SIZE.x)
	next_pos.y = fposmod(next_pos.y, Settings.GRID_SIZE.y)
	head.current_pos = next_pos
	
	for i in range(1, tail.size()):
		tail[i].current_pos = tail[i-1].previous_pos
		
	for i in range(1, tail.size()):
		if head.get_rect().intersects(tail[i].get_rect()):
			hit.emit(tail[i])
			Settings.gameover.emit()
			break


func grow():
	var minisnake = Minisnake.new()
	var last_minisnake = tail.back() as Minisnake
	audio_stream_player.set_stream(grow_sound)
	audio_stream_player.set_pitch_scale(randf_range(0.8, 1.6))
	audio_stream_player.play()
	minisnake.current_pos = last_minisnake.current_pos
	minisnake.color = Colors.DARK_GREEN
	minisnake.size = Settings.CELL_SIZE
	tail.push_back(minisnake)
	
	Settings.score += 1
	print(Settings.score)


func _on_hit(mini: Minisnake):
	tween_move.kill()
	
	await get_tree().process_frame
	
	audio_stream_player.set_stream(hurt_sound)
	audio_stream_player.play()
	
	for minisnake in tail:
		minisnake.go_to_previous_pos()
