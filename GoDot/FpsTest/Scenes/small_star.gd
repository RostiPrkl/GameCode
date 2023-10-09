extends Node3D


var vertical_speed


func init(x, y, z, size):
	translate(Vector3(x, y, z))
	scale = Vector3(size, size, size)
	vertical_speed = (50 + (y * 0.5) / 10.0)
