extends Node


func is_valid_node(node):
	return node and is_instance_valid(node)
	
	
func get_random_x_in_viewport(padding = 0.0):
	return randf_range(GameManager.boundary.left + padding, GameManager.boundary.right - padding)
	
	
func get_random_vector3_in_range(from, to):
	return Vector3(randf_range(from, to), randf_range(from, to), randf_range(from, to))
	
	
func get_all_children(in_node, array = []):
	array.push_back(in_node)
	for child in in_node.get_children():
		array = get_all_children(child, array)
	return array
