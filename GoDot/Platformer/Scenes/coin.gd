extends Node2D

@onready var area_2d = $Area2D
@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $Area2D/CollisionShape2D


func _ready():
	animated_sprite_2d.play("default")
	area_2d.area_entered.connect(on_area_entered)


func on_area_entered(_Node):
	animation_player.play("pick_up")
	var base = get_tree().get_nodes_in_group("base_level")[0]
	base.coin_collector()
	queue_free()
