extends Node2D

@onready var area_2d = $Area2D
@onready var animated_sprite_2d = $AnimatedSprite2D

signal level_clear

func _ready():
	area_2d.connect("area_entered", on_area_entered)
	animated_sprite_2d.play("default")
	
func on_area_entered(_node):
	emit_signal("level_clear")
