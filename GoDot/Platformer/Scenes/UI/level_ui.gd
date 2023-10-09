extends CanvasLayer

@onready var coin_label = $MarginContainer/HBoxContainer/CoinLabel


func _ready():
	var base = get_tree().get_nodes_in_group("base_level")
	coin_label.text = str("0")
	base[0].connect("coin_total_changed", on_coin_total_changed)
		
	
	
func on_coin_total_changed(total_coins, collected_coins):
	coin_label.text = str(collected_coins )
