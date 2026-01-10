extends MarginContainer

signal start_game_clicked
signal options_clicked

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Coin.freeze = true
	$Coin/AnimatedSprite2D.speed_scale = 0.5
	$Coin/AnimatedSprite2D.play()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_start_game_pressed() -> void:
	print("Start button pressed...")
	get_tree().change_scene_to_file("res://scenes/main.tscn")
