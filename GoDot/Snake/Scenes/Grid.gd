extends Node2D


func _draw():
	draw_rect(Rect2(0,0, Settings.GRID_SIZE.x, Settings.GRID_SIZE.y), Colors.BLACK)
	
	for i in Settings.GRID.x:
		var from = Vector2(i * Settings.CELL_SIZE.x ,0)
		var to = Vector2(from.x, Settings.GRID_SIZE.y)
		
		draw_line(from, to, Colors.DARK_GREEN_ALT)
		
	for i in Settings.GRID.y:
		var from = Vector2(0, Settings.CELL_SIZE.y * i)
		var to = Vector2(Settings.GRID_SIZE.x, from.y)
		
		draw_line(from, to, Colors.DARK_GREEN_ALT)
