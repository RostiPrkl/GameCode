extends Area3D

@onready var laser_trail = $laser_trail


@export var damage = 5.0
@export var speed = 65

var current_direction


func init(weapon):
	position = weapon.global_position
	position.y = 0
	var direction_node = weapon.get_children()[0]
	current_direction = direction_node.position
	var direction_angle = Vector2(current_direction.x, current_direction.z).angle_to(Vector2.UP)
	rotate_y(direction_angle)


func _process(delta):
	translate(Vector3(0, 0, -speed * delta))
	laser_trail.add_new_point(GameManager.to_2D(global_position))
	if !GameManager.is_in_boundary(self):
		queue_free()
	

