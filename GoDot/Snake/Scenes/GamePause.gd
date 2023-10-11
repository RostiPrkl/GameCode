extends Control


func _ready():
	hide()
	
	
func _process(delta):
	if get_tree().paused == false:
		hide()
	else:
		show()


func _input(event):
	if event.is_action_pressed("pause"):
		await get_tree().process_frame
		get_tree().set_pause(false)
		hide()
		print("unpause")
		
