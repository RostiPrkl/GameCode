extends Area2D

var speed: int = 1500;
var direction: Vector2 = Vector2.UP


func _process(delta):
	position += direction * speed * delta
