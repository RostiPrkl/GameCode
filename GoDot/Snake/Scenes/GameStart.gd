extends Control


func _ready():
	show()
	get_tree().set_pause(true)
	while !Input.is_action_pressed("start"): await get_tree().process_frame
	hide()
	get_tree().set_pause(false)


func _process(delta):
	pass
