extends CharacterBody2D

# Dollar Horde - Enemy
signal killed(xp_value: int)

@export var move_speed: float = 60.0
@export var hp: float = 20.0
@export var damage: float = 10.0
@export var xp_value: int = 3

var wobble_timer: float = 0.0
var base_scale: Vector2 = Vector2.ONE

@onready var sprite: Node2D = $SpriteRoot
@onready var death_particles: GPUParticles2D = $DeathParticles

func _ready() -> void:
	wobble_timer = randf() * TAU
	base_scale = Vector2.ONE * (0.8 + randf() * 0.4)

func _physics_process(delta: float) -> void:
	if GameManager.is_game_over or not GameManager.player:
		return

	# Move toward player
	var dir := (GameManager.player.global_position - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()

	# Wobble animation
	wobble_timer += delta * 5.0
	var wobble := sin(wobble_timer) * 0.1
	sprite.scale = base_scale * (1.0 + wobble)

	# Face player
	if dir != Vector2.ZERO:
		sprite.rotation = dir.angle()

func take_damage(amount: float) -> void:
	hp -= amount
	# Flash
	sprite.modulate = Color.WHITE
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.5, 0.3, 0.3, 1), 0.05)
	tween.tween_property(sprite, "modulate", Color(1, 0.2, 0.2, 1), 0.1)

	if hp <= 0:
		die()

func die() -> void:
	GameManager.enemies_killed += 1
	# Death particles
	death_particles.emitting = true
	# Drop XP
	drop_xp_gem()
	# SFX
	SoundManager.play_sfx("enemy_death", 0.1, -4.0)
	# Hide immediately but let particles play
	visible = false
	set_physics_process(false)
	# Free after particles finish
	await get_tree().create_timer(0.5).timeout
	queue_free()

func drop_xp_gem() -> void:
	var gem_scene := preload("res://scenes/XpGem.tscn")
	var gem := gem_scene.instantiate()
	gem.global_position = global_position
	gem.xp_value = xp_value
	get_parent().add_child(gem)
