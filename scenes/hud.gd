extends CanvasLayer

signal flip_coin

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("spacebar_flip"):
		flip_coin.emit()

func _on_flip_button_pressed() -> void:
	flip_coin.emit()


func update_streak(streak) -> void:
	$StreakLabel.text = "Streak: " + str(streak)
