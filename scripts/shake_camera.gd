extends Camera2D
# Dollar Horde - Camera2D with player follow + screen shake

var shake_strength: float = 0.0
var shake_decay: float = 0.0
var _default_offset := Vector2.ZERO

# Reduced shake for better feel
var base_shake_strength: float = 2.5  # was 3.0
var android_shake_strength: float = 1.5  # was 2.0

func _ready() -> void:
	_default_offset = offset

func _physics_process(delta: float) -> void:
	# Follow player
	if GameManager.player:
		global_position = GameManager.player.global_position

	# Shake
	if shake_strength > 0:
		offset = _default_offset + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_strength -= shake_decay * delta
		if shake_strength <= 0:
			shake_strength = 0
			offset = _default_offset

func add_shake(duration: float, strength: float) -> void:
	shake_strength = strength
	shake_decay = strength / duration
	
	# Clamp to reduced values for better mobile feel
	var is_android := OS.has_feature("android")
	if is_android:
		shake_strength = min(shake_strength, android_shake_strength)
	else:
		shake_strength = min(shake_strength, base_shake_strength)
