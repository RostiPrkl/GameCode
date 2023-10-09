extends CharacterBody2D

const GRAVITY = 500
var turning = false
var direction = Vector2.ZERO
var start_direction = Vector2.RIGHT

signal died

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var goal_detector = $GoalDetector
@onready var hit_box = $HitBox

var max_speed = 25


func _ready():
	direction = start_direction
	goal_detector.area_entered.connect(on_goal_entered)
	hit_box.area_entered.connect(on_hit_box_entered)


func _process(delta):
	animated_sprite_2d.play("run")
	velocity.x = (direction * max_speed).x
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	move_and_slide()
	
	animated_sprite_2d.flip_h = true if direction.x > 0 else false


func on_goal_entered(_node):
	direction *= -1


func on_hit_box_entered(_node):
	died.emit()
	queue_free()
	
