class_name Lifecycle
extends Node

signal enemy_destroyed(source_node)
signal laser_hit(enemy, laser)

var spawn = {}
var elapsed_time = 0.0
var current_dir
var current_rotation
var speed
var max_health = 0.0
var health = 0.0
var timeline = []


func init(root_node, enemy, _spawn):
	spawn = _spawn
	enemy.translate(spawn.coords)
	enemy.scale_object_local(spawn.scale)
	current_dir = spawn.direction
	speed = current_dir.length()
	current_rotation = spawn.rotation
	health = spawn.health
	max_health = health
	connect("enemy_destroyed", Callable(root_node, "_on_enemy_destroyed"))
	connect("laser_hit", Callable(root_node, "_on_show_hit_effect"))
	

func process(enemy, delta):
	elapsed_time += delta
	enemy.global_position.x += current_dir.x * delta
	enemy.global_position.z += current_dir.z * delta
	
	if current_rotation != Vector3.ZERO:
		enemy.rotate_x(current_rotation.x * delta)
		enemy.rotate_x(current_rotation.y * delta)
		enemy.rotate_x(current_rotation.z * delta)
	
	if elapsed_time > 60 and not GameManager.is_in_boundary(enemy):
		enemy.queue_free()
		
		
func process_hit(enemy, area):
	health -= area.damage
	laser_hit.emit(enemy, area)
	if health <= 0:
		explode(enemy)
		
		
func explode(enemy):
	enemy_destroyed.emit(enemy)
