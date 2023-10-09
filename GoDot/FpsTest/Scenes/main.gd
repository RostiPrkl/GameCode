extends Node3D

@onready var debug = $Debug
@onready var player = $Player
@onready var hud = $HUD
@onready var camera = $Camera3D

var fire_switch = 0.2
var fire_cooldown = 0.0

var current_level
var level_loaded = false

func _ready():
	GameManager.set_boundary(
		$Boundary/LeftWall.position.x,
		$Boundary/RightWall.position.x,
		$Boundary/UpWall.position.z,
		$Boundary/DownWall.position.z
	)
	
	GameManager.set_camera(camera)
	GameManager.spwan_stars(self)
	player.connect("player_destroyed", Callable(self, "_on_player_destroyed"))
	player.connect("update_hud", Callable(self, "_on_update_hud"))
	player.init()
	GameManager.set_player(player)
	debug.init(player)


func _process(delta):
	if level_loaded:
		GameManager.process_background(self, delta)
		GameManager.process_debris(delta)
		if Input.is_action_pressed("fire") and fire_cooldown <= 0:
			fire_laser()
		fire_cooldown -= delta
	else:
		current_level = LevelManager.load_level("tutorial")
		current_level.init(self)
		level_loaded = true
	
	
func fire_laser():
	if Utils.is_valid_node(player):
		fire_cooldown = fire_switch
		GameManager.fire_player_weapon(self)


func _on_player_destroyed():
	GameManager.create_explosion(self, player, 50, 50)
	

func _on_enemy_destroyed(enemy):
	GameManager.create_explosion(self, enemy, 40, 40)
	
	
func _on_show_hit_effect(enemy, laser):
	GameManager.create_hit_effect(self, enemy, laser)
	
	
func _on_update_hud():
	hud.set_player_values(player)
