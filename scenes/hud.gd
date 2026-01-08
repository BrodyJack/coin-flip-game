extends CanvasLayer

signal flip_coin
signal coin_value_upgrade
signal coin_chance_upgrade

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("spacebar_flip"):
		flip_coin.emit()
		
func update_streak(streak) -> void:
	$StreakLabel.text = "Streak: " + str(streak)
	
func update_total_cash(total_cash) -> void:
	$CashAmountLabel.text = str(total_cash)

func update_coin_value(coin_value) -> void:
	$CoinValueUpgradeBox/PerFlipAmountLabel.text = str(coin_value)
	
func update_coin_value_upgrade_cost(upgrade_cost) -> void:
	$CoinValueUpgradeBox/UpgradeCostAmountLabel.text = str(upgrade_cost)
	
func set_coin_value_upgrade_button_enabled(should_enable) -> void:
	$CoinValueUpgradeBox/UpgradeButton.disabled = not should_enable

func update_coin_chance(coin_chance) -> void:
	$CoinChanceUpgradeBox/PerFlipChanceLabel.text = str(coin_chance) + "%"

	
func update_coin_chance_upgrade_cost(upgrade_cost) -> void:
	$CoinChanceUpgradeBox/UpgradeCostAmountLabel.text = str(upgrade_cost)

func set_coin_chance_upgrade_button_enabled(should_enable) -> void:
	$CoinChanceUpgradeBox/UpgradeButton.disabled = not should_enable
	
func play_upgrade_sound() -> void:
	$UpgradeButtonSound.play()

func _on_flip_button_pressed() -> void:
	flip_coin.emit()


func _on_coin_value_upgrade_button_pressed() -> void:
	coin_value_upgrade.emit()


func _on_coin_chance_upgrade_button_pressed() -> void:
	coin_chance_upgrade.emit()
