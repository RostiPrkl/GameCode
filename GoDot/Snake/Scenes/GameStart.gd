extends Control


func _ready():
	show()
	while !Input.is_action_pressed("start"): await get_tree().process_frame
	hide()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_play_button_pressed():
	pass
