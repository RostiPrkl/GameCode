extends Node

var asteroid_scene = preload("res://Scenes/asteroid_001.tscn")

var timeline = []
var elapsed_time = 0.0
var previous_second = 0


func _init(node):
	timeline.append({"timestamp": 1, "wave": get_asteroid_wave()})
	
	
func process(node, delta):
	elapsed_time += delta
	if elapsed_time -previous_second > 1.0:
		previous_second += 1
		for event in timeline:
			if event.timestamp <= elapsed_time and not event.has("processed"):
				process_wave(node, event.wave)
	
	
func process_wave(node, wave):
	for item in wave:
		var enemy = item.enemy.instantiate()
		enemy.init(node, item.spawn, item.timeline)
		node.add_child(enemy)
	
	
func get_asteroid_wave():
	var wave =[]
	for i in 11:
		wave.append({
			"enemy": asteroid_scene,
			"spawn": {
				"health" : 40.0,
				"coords": Vector3(Utils.get_random_x_in_viewport(10), 0, GameManager.boundary.top - i * 2),
				"scale": Utils.get_random_vector3_in_range(1, 5),
				"direction": Vector3(0, 0, randf_range(2, 10)),
			},
			"timeline": []
		})
	return wave
