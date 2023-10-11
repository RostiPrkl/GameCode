extends Label

var tween : Tween


func _ready():
	text = str(" ")
	
	Settings.score_changed.connect(_on_score_changed)
	Settings.gameover.connect(_on_gameover)
	

func _process(delta):
	pass


func _on_score_changed(score: int):
	text = str(score)
	
	if tween and tween.is_running: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 1, .25).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0, 3).set_ease(Tween.EASE_IN)
	

func _on_gameover():
	if tween and tween.is_running: tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 1, .25).set_ease(Tween.EASE_OUT)
	
	
