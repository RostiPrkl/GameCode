extends Node

var current_level


func load_level(level):
	current_level = load("res://Levels/" + level + ".gd").new()
	return current_level
