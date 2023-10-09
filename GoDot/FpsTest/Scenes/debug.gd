extends Label

@export var show_debug = true

var FPS = 0
var draw_calls = 0
var frame_time = 0
var VRAM = 0
var small_star_count = 0
var enemy_count = 0
var bullet_count = 0
var player


func init(_player):
	player = _player


func _process(delta):
	if not show_debug:
		text = ""
		return
		
	FPS = Engine.get_frames_per_second()
	draw_calls = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	frame_time = delta
	VRAM = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED) / 1024.0 / 1024.0
	small_star_count = get_tree().get_nodes_in_group("small_star").size()
	enemy_count = get_tree().get_nodes_in_group("enemy").size()
	bullet_count = get_tree().get_nodes_in_group("laser").size()
	
	var data = \
	"FPS: " + str(FPS) + "\n" + \
	"Draw calls: " + str(draw_calls) + "\n" + \
	"Frame time: " + str("%0.2f" % frame_time) + "\n" + \
	"VRAM: " + str("%0.2f" % VRAM + " mb") + "\n" + \
	"Stars: " + str(small_star_count) + "\n" + \
	"Enemies: " + str(enemy_count) + "\n" + \
	"Projectiles: " + str(bullet_count) + "\n"
	
	
	if Utils.is_valid_node(player):
		data += \
		"Position " + str(player.global_position) + "\n" + \
		"Rotation " + str(player.rotation)
		
	text = data
