extends Label


func _ready():
	Settings.score_changed.connect(_on_score_changed)


func _process(delta):
	pass


func _on_score_changed(score: int):
	text = str(score)
