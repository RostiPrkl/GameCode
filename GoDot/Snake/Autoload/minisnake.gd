class_name Minisnake

var current_pos = Vector2() : set = _set_current_pos
var previous_pos = Vector2()
var size = Vector2()
var color = Color()


func get_rect() -> Rect2:
	return Rect2(current_pos, size)
	

func go_to_previous_pos():
	current_pos = previous_pos


func _set_current_pos(new_pos: Vector2):
	previous_pos = current_pos
	current_pos = new_pos
