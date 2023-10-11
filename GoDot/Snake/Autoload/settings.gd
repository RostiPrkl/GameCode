extends Node

const GRID_SIZE = Vector2(800,480)
const CELL_SIZE = Vector2(16,16)
const GRID = Vector2(GRID_SIZE.x / CELL_SIZE.x, GRID_SIZE.y / CELL_SIZE.y)

var score = 0: set = _set_score

signal gamestart()
signal score_changed(new_score: int)
signal gameover()


func repeat(value: float, length: float) -> float:
	return fposmod(value, length)


func _ready():
	await get_tree().process_frame
	gamestart.emit()


func _set_score(new_score: int):
	score = new_score
	score_changed.emit(score)


func restart():
	score = 0
	get_tree().reload_current_scene()
	
	
func _input(event):
	if event.is_action_pressed("pause"):
		await get_tree().process_frame
		get_tree().set_pause(true)
		print("pause")
