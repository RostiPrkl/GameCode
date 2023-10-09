extends CharacterBody2D

var movement_speed = 100

func _ready():
	pass

func _process(_delta):
	var direction = Vector2.RIGHT
	velocity = direction * movement_speed
	move_and_slide()
