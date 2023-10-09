extends Marker2D

@export var enemy_scene: PackedScene
@onready var spawn_timer = $SpawnTimer

var current_enemy_node = null
var has_enemy_died = false


func _ready():
	spawn_enemy()
	
	var level = get_tree().get_nodes_in_group("base_level")[0]     
	level.respawn_enemies.connect(on_respawn_enemy)
	
	
func spawn_enemy():
	current_enemy_node = enemy_scene.instantiate()
	get_parent().add_child.call_deferred(current_enemy_node)
	current_enemy_node.global_position = global_position
	
	if !current_enemy_node.died.is_connected(change_state):
		current_enemy_node.died.connect(change_state, CONNECT_DEFERRED)
	

func change_state():
	has_enemy_died = true


func on_respawn_enemy():
	if has_enemy_died:
		has_enemy_died = false
		
		await get_tree().create_timer(.2).timeout
		spawn_enemy()
