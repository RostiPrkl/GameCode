extends CharacterBody2D

signal died

const GRAVITY = 1000

enum state {NORMAL, DASHING}

var max_speed_horizontal = 200
var horizontal_acceleration = 500
var jump_speed = 335
var jump_termination_multiplier = 3
var has_double_jump = false
var has_dash = false
var current_state = state.NORMAL
var state_status = true
var default_hurt_mask = 0

@onready var hurt_box = $HurtBox
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_timer = $CoyoteTimer
@onready var dash_area = $DashArea/CollisionShape2D

@export_flags_2d_physics var dash_hurt_mask


func _ready():
	hurt_box.connect("area_entered", on_hurt_box_entered)
	default_hurt_mask = hurt_box.collision_mask
	

func _process(delta):
	match current_state:
		state.NORMAL:
			process_normal(delta)
		state.DASHING:
			process_dashing(delta)
	state_status = false


func change_state(new_state):
	current_state = new_state
	state_status = true


func process_normal(delta):
	if state_status:
		dash_area.disabled = true
		hurt_box.collision_mask = default_hurt_mask
		
	var move_vector = get_movement_vector()
	velocity.x += (move_vector.x * horizontal_acceleration) * delta
	if move_vector.x == 0:
		velocity.x = lerp(0.0, velocity.x, pow(2, -20 * delta))
	velocity.x = clamp(velocity.x, -max_speed_horizontal, max_speed_horizontal)
	
	if move_vector.y < 0 && (is_on_floor() || !coyote_timer.is_stopped() || has_double_jump):
		velocity.y = move_vector.y * jump_speed
		if (!is_on_floor() && coyote_timer.is_stopped()):
			has_double_jump = false
		coyote_timer.stop()
		
	if velocity.y < 0 && !Input.is_action_pressed("jump"):
		velocity.y += (GRAVITY * jump_termination_multiplier) * delta
	else:
		velocity.y += GRAVITY * delta
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	if was_on_floor && ! is_on_floor():
		coyote_timer.start()
	
	if is_on_floor():
		has_double_jump = true
		has_dash = true
	
	if has_dash && Input.is_action_just_pressed("dash"):
		#OLDchange_state(state.DASHING)
		call_deferred("change_state", state.DASHING)
		has_dash = false
		
	update_animation()


func process_dashing(delta):
	
	animated_sprite_2d.play("dash")
	if state_status:
		dash_area.disabled = false
		hurt_box.collision_mask = dash_hurt_mask
		var velocity_modifier = 1
		if get_movement_vector().x != 0:
			velocity_modifier = sign(get_movement_vector().x)
		else:
			velocity_modifier = 1 if animated_sprite_2d.flip_h else -1
		velocity = Vector2((max_speed_horizontal * 3) * velocity_modifier, 0)
	
	move_and_slide()
	
	velocity.x = lerp(0.0, velocity.x, pow(2, -8 * delta))
	if abs(velocity.x) < (max_speed_horizontal / 2):
		call_deferred("change_state", state.NORMAL)


func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = -1 if Input.is_action_just_pressed("jump") else 0
	return Vector2(x_movement, y_movement)


func update_animation():
	var movement_vector = get_movement_vector()
	
	if !is_on_floor():
		animated_sprite_2d.play("jump")
	elif movement_vector.x != 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if movement_vector.x != 0:
		animated_sprite_2d.flip_h = true if movement_vector.x > 0 else false


func on_hurt_box_entered(_Node):
	#DEBUGprint("DIE")
	emit_signal("died")
