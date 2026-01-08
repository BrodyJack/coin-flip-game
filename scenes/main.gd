extends Node

# Consider reworking this to be the adjustable impulse, and to increase speed:
# - Increase impulse + gravity
# - Try -1500 w/ Gravity Scale 4.0 to test
## **Currently unused as we are instead simulating with physics**
@export var flip_time = 2.0

## Chance for the coin to land on heads, 0 for tails, 1 for heads
@export var heads_chance = .3

## Cash granted on a heads flip
@export var coin_value = 1.0

const COIN_FRAME_HEADS = 0
const COIN_FRAME_TAILS = 5

var is_coin_flipping = false
var is_heads = false

var streak = 0
var total_cash = 0.0

@export var coin_chance_upgrade_costs = [25, 50, 100, 200, 500]
@export var coin_chance_upgrade_values = [.35, .40, .45, .50, .55]
var coin_chance_upgrade_index = 0

@export var coin_value_upgrade_costs = [10, 20, 40, 80, 160]
@export var coin_value_upgrade_values = [2, 3, 4, 5, 10]
var coin_value_upgrade_index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_hud()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func flip_coin() -> void:
	if is_coin_flipping:
		return
		
	is_coin_flipping = true
	is_heads = randi_range(0, 99) <= (heads_chance * 100)
	
	$Coin.apply_central_impulse(Vector2(0, -750))
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
	print("heads!" if is_heads else "tails")
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
