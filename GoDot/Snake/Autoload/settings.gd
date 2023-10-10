extends Node

const GRID_SIZE = Vector2(800,480)
const CELL_SIZE = Vector2(16,16)

const GRID = Vector2(GRID_SIZE.x / CELL_SIZE.x, GRID_SIZE.y / CELL_SIZE.y)

var score = 0: set = _set_score
signal score_changed(new_score: int)


func repeat(value: float, length: float) -> float:
	return fposmod(value, length)


func _set_score(new_score: int):
	score = new_score
	score_changed.emit(score)
