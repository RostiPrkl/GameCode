extends Node2D

@onready var tile_map = $TileMap


func _ready():
	tile_map.get_used_cells_by_id(0)
	print(tile_map)


