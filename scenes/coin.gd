extends RigidBody2D

signal bonus_coin_clicked

@export var is_bonus_coin = false

func set_is_bonus_coin(val) -> void:
	is_bonus_coin = val 

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("mouse_click_left") && is_bonus_coin:
		bonus_coin_clicked.emit()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if is_bonus_coin:
		queue_free()
