extends CharacterBody3D

@onready var weapons_node = $Weapons
@onready var shield_node = $Shield
@onready var shield_collision = $Shield/CollisionShape3D


signal player_destroyed()
signal update_hud()

const SPEED = 120.0
const BOOST = 250.0
const MAX_TILT = 0.7

var weapons = []
var tilt = 0.0
var tilt_dir = 0.0
var boost_active = false
var max_hull_integrity= 100.0
var hull_integrity = max_hull_integrity
var max_shield = 100.0
var shield = max_shield


func init():
	for weapon in weapons_node.get_children():
		if weapon.name == "Laser1":
			weapon.active = true
		elif weapon.name == "Laser2":
			weapon.active = true
		weapons.append(weapon)
		
func _input(event):
	boost_active = true if Input.is_action_pressed("boost") else false

func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var speed = BOOST if boost_active else SPEED
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	if velocity.x > 0:
		tilt_dir = 1.0
	elif velocity.x < 0:
		tilt_dir = -1.0
	else:
		if tilt > 0:
			tilt_dir = -1.0
		elif tilt < 0:
			tilt_dir = 1.0
		else:
			tilt_dir = 0
			
	var saved_tilt = tilt
	tilt += tilt_dir * delta
	if saved_tilt > 0 and tilt < 0 or saved_tilt < 0 and tilt > 0:
		tilt = 0
		tilt_dir = 0
	if tilt > -MAX_TILT and tilt < MAX_TILT:
		rotation.z = -tilt
	else:
		tilt = clampf(tilt, -MAX_TILT, MAX_TILT)

	move_and_slide()
	
	
func shield_hit(value):
	shield -= value
	
	
func remove_shield():
	shield = 0
	shield_collision.set_deferred("disabled", true)
	shield_node.visible = false
	
	
func process_hit(area, enemy_impact):
	var value = get_health(area, enemy_impact)
	if shield > 0:
		shield_hit(value)
		update_hud.emit()
		if shield <= 0:
			value = -shield
			remove_shield()
	if shield <= 0:
		hull_integrity -= value
		update_hud.emit()
		if hull_integrity <= 0:
			player_destroyed.emit()
	if enemy_impact:
		if hull_integrity > 0:
			area.explode()
		else:
			area.queue_free()
	

func get_health(area, enemy_impact):
	return area.lifecycle.health if enemy_impact else area.health


func _on_area_3d_area_entered(area):
	var projectile_impact = area.is_in_group("enemy_projectile")
	var enemy_impact = area.is_in_group("enemy")
	if projectile_impact or enemy_impact:
		process_hit(area, enemy_impact)
	

func _on_shield_area_entered(area):
	var projectile_impact = area.is_in_group("enemy_projectile")
	var enemy_impact = area.is_in_group("enemy")
	if projectile_impact or enemy_impact:
		process_hit(area, enemy_impact)
