extends CPUParticles3D

var elapsed_time = 0.0


func init(x, z):
	translate(Vector3(x, 4.5, z))
	emitting = true
	restart()


func _process(delta):
	elapsed_time += delta
	if elapsed_time > 0.5:
		emitting = false
		queue_free()
