extends Control


func _ready():
	hide()
	Settings.gameover.connect(_on_gameover)
	
	
func _on_gameover():
	await get_tree().create_timer(1.0).timeout
	show()
	
	
	while !Input.is_action_pressed("start"): await get_tree().process_frame
	Settings.restart()
	
