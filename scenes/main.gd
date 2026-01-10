extends Node

# Consider reworking this to be the adjustable impulse, and to increase speed:
# - Increase impulse + gravity
# - Try -1500 w/ Gravity Scale 4.0 to test
## **Currently unused as we are instead simulating with physics**
@export var flip_time = 2.0

## Controls how hard the coin flips up - suggest adjusting gravity accordingly
@export var flip_impulse = -750

## Chance for the coin to land on heads, 0 for tails, 1 for heads
@export var heads_chance = .3

## Cash granted on a heads flip
@export var coin_value = 1.0

const COIN_FRAME_HEADS = 0
const COIN_FRAME_TAILS = 5

var is_coin_flipping = false
var is_heads = false

var streak = 0

@export var total_cash = 0.0

@export var coin_chance_upgrade_costs = [25, 50, 100, 200, 500]
@export var coin_chance_upgrade_values = [.35, .40, .45, .50, .55]
var coin_chance_upgrade_index = 0

@export var coin_value_upgrade_costs = [10, 20, 40, 80, 160]
@export var coin_value_upgrade_values = [2, 3, 4, 5, 10]
var coin_value_upgrade_index = 0

@export var auto_flipper_purchased = false
@export var auto_flipper_enabled = false
@export var auto_flipper_upgrade_cost = 100

@export var bonus_coin_spawn_scene: PackedScene
@export var bonus_coin_cash_value = 10
var active_bonus_coin: RigidBody2D = null

@export var volume = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_hud()
	$BonusCoinSpawnTimer.start()
	$MainMusic.play()
	$PauseMenu.set_volume(volume)
	$HUD/AutoFlipProgressBar.value = 0
	$DancingDude/AnimatedSprite2D.play("dance")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func flip_coin() -> void:
	if is_coin_flipping:
		return
		
	is_coin_flipping = true
	is_heads = randi_range(0, 99) <= (heads_chance * 100)
	print("chance: " + str(heads_chance), ", value: " + str(coin_value), ", result: " + str(is_heads))
	
	$Coin.apply_central_impulse(Vector2(0, flip_impulse))
	$Coin/FlipSound.play()
	$Coin/AnimatedSprite2D.play()


func _on_coin_land(_body: Node) -> void:
	if not is_coin_flipping:
		return
	
	$Coin/AnimatedSprite2D.stop()
	
	if is_heads:
		$Coin/AnimatedSprite2D.frame = COIN_FRAME_HEADS
		$Coin/HeadsSound.play()
		streak += 1
		total_cash += coin_value
	else:
		$Coin/AnimatedSprite2D.frame = COIN_FRAME_TAILS
		$Coin/TailsSound.play()
		streak = 0
		
	update_hud()
	is_coin_flipping = false
	

func update_hud() -> void:
	$HUD.update_total_cash(total_cash)
	$HUD.update_coin_chance(int(heads_chance * 100))
	$HUD.update_coin_value(coin_value)
	$HUD.update_streak(streak)
	$HUD.update_coin_value_upgrade_cost(coin_value_upgrade_costs[coin_value_upgrade_index])
	$HUD.update_coin_chance_upgrade_cost(coin_chance_upgrade_costs[coin_chance_upgrade_index])
	
	var should_enable = total_cash >= coin_value_upgrade_costs[coin_value_upgrade_index]
	$HUD.set_coin_value_upgrade_button_enabled(should_enable)
	
	should_enable = total_cash >= coin_chance_upgrade_costs[coin_chance_upgrade_index]
	$HUD.set_coin_chance_upgrade_button_enabled(should_enable)
	
	$HUD.update_coin_auto_flip_purchased(auto_flipper_purchased)
	$HUD.update_coin_auto_flip_upgrade_cost(auto_flipper_upgrade_cost, auto_flipper_purchased)
	should_enable = total_cash >= auto_flipper_upgrade_cost
	$HUD.set_coin_auto_flip_upgrade_button_enabled(should_enable && not auto_flipper_purchased)
	$HUD.set_auto_flipper_checkbox_visible(auto_flipper_purchased)

func _on_hud_coin_value_upgrade() -> void:
	var current_upgrade_cost = coin_value_upgrade_costs[coin_value_upgrade_index]
	var next_coin_value = coin_value_upgrade_values[coin_value_upgrade_index]
	if total_cash < current_upgrade_cost:
		return
		
	$HUD.play_upgrade_sound()
	
	total_cash -= current_upgrade_cost
	coin_value = next_coin_value
	coin_value_upgrade_index += 1
	
	update_hud()


func _on_hud_coin_chance_upgrade() -> void:
	var current_upgrade_cost = coin_chance_upgrade_costs[coin_chance_upgrade_index]
	var next_coin_chance = coin_chance_upgrade_values[coin_chance_upgrade_index]
	if total_cash < current_upgrade_cost:
		return
		
	$HUD.play_upgrade_sound()
	
	total_cash -= current_upgrade_cost
	heads_chance = next_coin_chance
	coin_chance_upgrade_index += 1
	
	update_hud()


func _on_main_music_finished() -> void:
	$MainMusic.play()


func _on_hud_coin_auto_flip_upgrade() -> void:
	if total_cash < auto_flipper_upgrade_cost:
		return
		
	$HUD.play_upgrade_sound()
	
	total_cash -= auto_flipper_upgrade_cost
	auto_flipper_purchased = true
	
	update_hud()


func _on_hud_auto_flip_status(toggled_on: bool) -> void:
	auto_flipper_enabled = toggled_on
	
	if auto_flipper_enabled:
		flip_coin()
		$AutoFlipTimer.start()
		$HUD/AutoFlipProgressBar.max_value = $AutoFlipTimer.wait_time
		$HUD/AutoFlipProgressBar/ProgressBarTimer.wait_time = $AutoFlipTimer.wait_time
		$HUD/AutoFlipProgressBar/ProgressBarTimer.start()
	else:
		$AutoFlipTimer.stop()
		$HUD/AutoFlipProgressBar/ProgressBarTimer.stop()
		$HUD/AutoFlipProgressBar.value = 0.01
	
	


func _on_auto_flip_timer_timeout() -> void:
	if auto_flipper_enabled:
		flip_coin()


func _on_bonus_coin_spawn_timer_timeout() -> void:
	var bonus_coin = bonus_coin_spawn_scene.instantiate()
	
	var spawn_loc = $BonusCoinSpawner/CoinSpawnLocation
	spawn_loc.progress_ratio = randf()
	
	bonus_coin.position = spawn_loc.position
	bonus_coin.gravity_scale = randf_range(0.5, 1.5)
	# Make it a little easier to click if moving quickly
	if bonus_coin.gravity_scale > 1.0:
		bonus_coin.get_node("CollisionShape2D").scale *= 1.5
		
	bonus_coin.set_is_bonus_coin(true)
	var anim = bonus_coin.get_node("AnimatedSprite2D")
	anim.speed_scale = 0.5
	anim.play()
	
	bonus_coin.bonus_coin_clicked.connect(_on_coin_bonus_coin_clicked)
	
	add_child(bonus_coin)
	active_bonus_coin = bonus_coin
	


func _on_coin_bonus_coin_clicked() -> void:
	# Prevent duplicate clicks
	if active_bonus_coin.freeze == true:
		return
		
	active_bonus_coin.freeze = true
	print("click_bonus_coin_signal_received")
	total_cash += bonus_coin_cash_value
	active_bonus_coin.get_node("HeadsSound").finished.connect(_free_up_bonus_coin)
	active_bonus_coin.get_node("HeadsSound").play()
	update_hud()
	
func _free_up_bonus_coin() -> void:
	active_bonus_coin.queue_free()
	active_bonus_coin = null


func _on_hud_pause_game() -> void:
	$PauseMenu._on_pause_button_pressed()
	$HUD.hide()


func _on_pause_menu_unpause_game() -> void:
	$HUD.show()


func _on_pause_menu_volume_change(value: float) -> void:
	$MainMusic.volume_linear = value / 100.0
