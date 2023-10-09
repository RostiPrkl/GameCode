extends CharacterBody2D

var speed: int = 500
var can_laser: bool = true
var can_grenade: bool = true

signal player_laser(pos, direction)
signal player_grenade(pos, direction)

func _process(_delta):
	
	var movement = Input.get_vector("left", "right", "up", "down")
	velocity = movement * speed
	move_and_slide()
	
	look_at(get_global_mouse_position())
	var player_dir = (get_global_mouse_position() - position).normalized()
	
	var laser_input = Input.is_action_just_pressed("primary action")
	if laser_input && can_laser:
		var laser_markers = $LaserStartPositions.get_children()
		var selected_laser = laser_markers[randi() % laser_markers.size()]
		player_laser.emit(selected_laser.global_position, player_dir)
		can_laser = false
		$TimerLaser.start()
		
	var grenade_input = Input.is_action_just_pressed("secondary action")
	var grenade_marker = $GrenadeStartPosition.get_children()[0]
	var grenade_dir = (get_global_mouse_position() - position).normalized()
	if grenade_input && can_grenade:
		player_grenade.emit(grenade_marker.global_position, player_dir)
		can_grenade = false
		$TimerGrenade.start()
	
	
func _on_timer_timeout():
	can_laser = true
	

func _on_timer_grenade_timeout():
	can_grenade = true
