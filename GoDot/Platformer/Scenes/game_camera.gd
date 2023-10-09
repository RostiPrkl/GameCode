extends Camera2D

var target_position = Vector2.ZERO

@export var background_color: Color


func _ready():
	make_current()
	RenderingServer.set_default_clear_color(background_color)


func _process(delta):
	acquire_target()
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * 10))
	#global_position = lerp(target_position, global_position, pow(2,-25 * delta))
	
	
func acquire_target():
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var player = player_nodes[0] as Node2D
		target_position = player.global_position
