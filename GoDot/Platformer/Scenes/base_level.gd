extends Node

@onready var player_call = $Player
@onready var enemies = $Enemies
@onready var flag = $WinCondition/Flag

signal coin_total_changed
signal respawn_enemies

var player_scene = preload("res://Scenes/player.tscn")
var spawn_position = Vector2.ZERO
var player_node = null
var total_coins = 0
var collected_coins = 0
var level_manager = LevelManager


func _ready():
	spawn_position = player_call.global_position
	register_player(player_call)

	total_coins = (get_tree().get_nodes_in_group("coin").size())
	
	flag = get_tree().get_nodes_in_group("flag")[0]
	player_scene.connect("level_clear", on_flag_collision)
	
	
	#flag.connect("level_clear", on_level_cleard)
	
	
func coin_collector():
	collected_coins += 1
	#DEBUGprint(total_coins, " - ", collected_coins)
	emit_signal("coin_total_changed", total_coins, collected_coins)


func register_player(player):
	player_node = player
	player_node.connect("died", on_player_died, CONNECT_DEFERRED)


func create_player():
	var player_instance = player_scene.instantiate()
	add_child(player_instance)
	player_instance.global_position = spawn_position
	register_player(player_instance)
	
	
func on_player_died():
	player_node.queue_free()
	respawn_enemies.emit()
	create_player()
	
	
#func on_level_clear():
#	if $flag != null:
#		level_manager.increment_level()
#	else:
#		print("Error: 'flag' node is null")


func on_flag_collision(body: Area2D) -> void:
	if flag != null:
		level_manager.increment_level()
		flag.queue_free()
	else:
		print("Error: 'flag' node is null")
	
