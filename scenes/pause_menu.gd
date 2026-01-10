extends Control

signal unpause_game
signal volume_change

func _ready() -> void:
	hide()
	get_tree().paused = false
	
func set_volume(volume: float) -> void:
	$VolumeSlider.value = volume * 100.0

func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	show()


func _on_close_pause_button_pressed() -> void:
	hide()
	get_tree().paused = false
	unpause_game.emit()


func _on_volume_slider_value_changed(value: float) -> void:
	volume_change.emit(value)
