extends Node2D

@onready var snake = %Snake

var hit_spot = Rect2(Vector2.ZERO, Settings.CELL_SIZE)
var hit_color = Color.TRANSPARENT


func _ready():
	snake.hit.connect(_on_snake_hit)


func _process(delta):
	queue_redraw()


func _draw():
	draw_rect(hit_spot, hit_color)
	
	
func _on_snake_hit(minisnake_hit: Minisnake):
	hit_spot.position = Vector2(minisnake_hit.current_pos)
	hit_color = Colors.DARK_RED
	
	var tween_pulse = create_tween().set_trans(Tween.TRANS_CIRC).set_loops()
	tween_pulse.tween_property(self, "hit_color", Colors.DARK_RED, .8).set_ease(Tween.EASE_OUT_IN)
	tween_pulse.tween_property(self, "hit_color", Color.TRANSPARENT, .9).set_ease(Tween.EASE_IN).set_delay(.6)
