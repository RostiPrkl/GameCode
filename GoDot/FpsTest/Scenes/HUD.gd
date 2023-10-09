extends CanvasLayer

@onready var player_hull_bar = $Player/GridContainer/HullBar
@onready var player_shield_bar = $Player/GridContainer/ShieldBar


func set_player_values(player):
	tween_property(player_hull_bar, "value", player.hull_integrity)
	tween_property(player_shield_bar, "value", player.shield)
	
	
func tween_property(element, property, value):
	if value != element.get(property):
		var tween = get_tree().create_tween()
		tween.tween_property(element, "value", value, 1)
