class_name Food

var pos = Vector2()
var size = Settings.CELL_SIZE
var color = Colors.ALT_RED


func get_rect() -> Rect2:
	return Rect2(pos, size)
