extends Area2D

# Dollar Horde - XP Gem
@export var xp_value: int = 3
var magnet_speed: float = 200.0
var is_magnetic: bool = false
var bob_timer: float = 0.0
var start_y: float = 0.0

@onready var collect_particles: GPUParticles2D = $CollectParticles

func _ready() -> void:
	bob_timer = randf() * TAU
	start_y = global_position.y
	# Scale by value
	var s := 0.8 + minf(xp_value, 10) * 0.04
	scale = Vector2(s, s)

func _physics_process(delta: float) -> void:
	if GameManager.is_game_over:
		return
	if not GameManager.player:
		return

	# Bob animation
	bob_timer += delta * 3.0
	position.y = start_y + sin(bob_timer) * 3.0

	# Pulse
	var pulse := 1.0 + sin(bob_timer * 2.0) * 0.1
	scale = Vector2(pulse, pulse) * (0.8 + minf(xp_value, 10) * 0.04)

	var dist := global_position.distance_to(GameManager.player.global_position)
	# Scale pickup range with player level for late-game
	var level_mult := 1.0 + (GameManager.level - 1) * 0.15  # 15% per level
	var pickup_range: float = 50.0 * GameManager.player.pickup_range_mult * level_mult

	if dist < pickup_range:
		is_magnetic = true

	if is_magnetic:
		var dir := (GameManager.player.global_position - global_position).normalized()
		global_position += dir * magnet_speed * delta
		magnet_speed += 400.0 * delta

func collect() -> void:
	collect_particles.emitting = true
	SoundManager.play_sfx("pickup", 0.12, -8.0)
	visible = false
	set_physics_process(false)
	await get_tree().create_timer(0.3).timeout
	queue_free()
