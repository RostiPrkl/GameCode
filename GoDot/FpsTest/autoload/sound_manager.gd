extends Node

@onready var laser_sound = $LaserSound
@onready var explosion_sound = $ExplosionSound
@onready var rock_hit_sound = $RockHitSound
@onready var enemy_hit_sound = $EnemyHitSound


func fire_laser():
	laser_sound.play()

func explosion_short():
	explosion_sound.play()
	
func rock_hit():
	rock_hit_sound.play()
	
func enemy_hit():
	enemy_hit_sound.play()
	
