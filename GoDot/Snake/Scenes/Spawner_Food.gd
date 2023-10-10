extends Node2D

var food = Food.new()
@onready var snake = %Snake as Snake

func _ready():
	spawn_food()


func _process(delta):
	queue_redraw()
	
	if food.get_rect().intersects(snake.head.get_rect()):
		snake.grow()
		spawn_food()	

func _draw():
	draw_rect(food.get_rect(), food.color)
	
	
func spawn_food() -> void:
	var is_on_occupied = true
	
	while is_on_occupied:
		var random_pos = Vector2()
		random_pos.x = randi_range(0, Settings.GRID_SIZE.x - Settings.CELL_SIZE.x)
		random_pos.y = randi_range(0, Settings.GRID_SIZE.y - Settings.CELL_SIZE.y)
		food.pos = random_pos.snapped(Settings.CELL_SIZE)
		
		for minisnake in snake.tail:
			if food.get_rect().intersects(minisnake.get_rect()):
				is_on_occupied = true
				break
			else:
				is_on_occupied = false
