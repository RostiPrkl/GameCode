class_name Enemy
extends Area3D

var lifecycle = Lifecycle.new()


func init(root_node, spawn, timeline):
	lifecycle.init(root_node, self, spawn)
	

func _process(delta):
	lifecycle.process(self, delta)
	
	
func explode():
	lifecycle.explode(self)


func _on_area_entered(area):
	if area.is_in_group("laser"):
		lifecycle.process_hit(self, area)
		area.queue_free()
