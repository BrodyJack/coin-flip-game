extends Node

# Currently unused as we are instead simulating with physics
# Consider reworking this to be the adjustable impulse, and to increase speed:
# - Increase impulse + gravity
# - Try -1500 w/ Gravity Scale 4.0 to test
@export var flip_time = 2.0

# 
@export var heads_chance = .3

const COIN_FRAME_HEADS = 0
const COIN_FRAME_TAILS = 5

var is_coin_flipping = false
var is_heads = false

var streak = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

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
	else:
		$Coin/AnimatedSprite2D.frame = COIN_FRAME_TAILS
		$Coin/TailsSound.play()
		streak = 0
		
	$HUD.update_streak(streak)
	print("heads!" if is_heads else "tails")
	is_coin_flipping = false
	
