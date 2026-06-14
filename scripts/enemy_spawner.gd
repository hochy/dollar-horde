extends Node2D

# Dollar Horde - Enemy Spawner
var spawn_timer: float = 0.0
var base_spawn_interval: float = 2.5
var spawn_radius_min: float = 350.0
var spawn_radius_max: float = 500.0

var enemy_scene := preload("res://scenes/Enemy.tscn")

func _physics_process(delta: float) -> void:
	if GameManager.is_game_over or not GameManager.player:
		return

	spawn_timer += delta

	# Much slower spawning early, aggressive late
	# Wave 1: 2.5s, Wave 5: 1.5s, Wave 10: 0.8s
	var wave_reduction := clampf(float(GameManager.wave) * 0.3, 0, 2.0)
	var interval := maxf(base_spawn_interval - wave_reduction, 0.4 + (6.0 / float(GameManager.wave + 1)))

	if spawn_timer >= interval:
		spawn_timer = 0.0
		spawn_enemies()

func spawn_enemies() -> void:
	# Scale number of enemies - more density with higher waves
	var count := 1
	if GameManager.wave >= 5:
		count = 2
	if GameManager.wave >= 10:
		count = 3
	if GameManager.wave >= 15:
		count = 4

	for i in range(count):
		var enemy := enemy_scene.instantiate()
		_scale_enemy_for_wave(enemy)
		_place_enemy(enemy, i, count)
		get_parent().add_child(enemy)

func _scale_enemy_for_wave(enemy: Node2D) -> void:
	var wave: int = int(max(GameManager.wave, 1))

	# HP: Gentle early scaling, steeper late
	# Wave 1: 15 HP, Wave 5: 25 HP, Wave 10: 45 HP
	var hp_mult: float = 1.0 + (wave * 2.5)
	if wave > 10:
		hp_mult += float(wave - 10) * 4.0
	enemy.hp = 15.0 * hp_mult / 10.0
	enemy.max_hp = enemy.hp

	# Damage: Linear scaling
	# Wave 1: 8, Wave 5: 14, Wave 10: 22
	enemy.damage = 6.0 + wave * 2.0

	# Speed: Linear but capped
	# Wave 1: 50, Wave 5: 70, Wave 10: 90, Wave 15+: 100
	enemy.move_speed = minf(50.0 + wave * 4.0, 100.0)

	# XP: Increases but caps at 20
	enemy.xp_value = int(min(3 + float(wave) * 2, 20))

func _place_enemy(enemy: Node2D, index: int, total: int) -> void:
	# Stagger spawn positions to avoid overlap
	var angle_offset := float(index) / float(total) * TAU
	var angle := randf() * TAU + angle_offset * 0.5
	var radius := randf_range(spawn_radius_min, spawn_radius_max)
	var offset := Vector2(cos(angle), sin(angle)) * radius
	enemy.global_position = GameManager.player.global_position + offset
