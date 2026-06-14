extends CharacterBody2D

# Dollar Horde - Player
signal health_changed(current: float, maximum: float)
signal died

@export var move_speed: float = 150.0
@export var max_hp: float = 100.0
@export var hp: float = 100.0
@export var damage_mult: float = 1.0
@export var fire_rate_mult: float = 1.0
@export var pickup_range_mult: float = 1.0
@export var armor: int = 0
@export var regen_rate: float = 0.0
@export var crit_chance: float = 0.05

var invincible_timer: float = 0.0
var regen_timer: float = 0.0
var weapon_timer: float = 0.0
var weapon_cooldown: float = 0.8
var joystick_vector: Vector2 = Vector2.ZERO
var facing: float = 0.0  # radians
var multishot_count: int = 1  # Number of bullets per shot (upgrade)

@onready var sprite: Node2D = $SpriteRoot
@onready var hitbox: CollisionShape2D = $Hitbox
@onready var pickup_area: Area2D = $PickupArea
@onready var weapon_origin: Marker2D = $WeaponOrigin
@onready var particles: GPUParticles2D = $HitParticles
@onready var trail: GPUParticles2D = $TrailParticles

func _ready() -> void:
	GameManager.player = self
	health_changed.emit(hp, max_hp)
	multishot_count = 1  # Initialize multishot

func _physics_process(delta: float) -> void:
	if GameManager.is_game_over:
		return

	# Movement
	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("move_left"): input_dir.x -= 1
	if Input.is_action_pressed("move_right"): input_dir.x += 1
	if Input.is_action_pressed("move_up"): input_dir.y -= 1
	if Input.is_action_pressed("move_down"): input_dir.y += 1

	if joystick_vector != Vector2.ZERO:
		input_dir = joystick_vector

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		facing = input_dir.angle()

	velocity = input_dir * move_speed
	move_and_slide()

	# Check collision with enemies
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider.is_in_group("enemies"):
			take_damage(collider.damage)
			# Knockback
			var kb_dir: Vector2 = (global_position - collider.global_position).normalized()
			position += kb_dir * 15.0

	# Clamp to arena
	var arena_size := Vector2(2000, 2000)
	position.x = clampf(position.x, 0, arena_size.x)
	position.y = clampf(position.y, 0, arena_size.y)

	# Invincibility frames
	if invincible_timer > 0:
		invincible_timer -= delta
		sprite.modulate.a = 0.4 if fmod(invincible_timer, 0.08) > 0.04 else 0.8
	else:
		sprite.modulate.a = 1.0

	# Regen
	if regen_rate > 0:
		regen_timer += delta
		if regen_timer >= 5.0:
			regen_timer = 0.0
			heal(regen_rate)

	# Auto-attack
	weapon_timer += delta
	if weapon_timer >= weapon_cooldown / fire_rate_mult:
		weapon_timer = 0.0
		fire_weapon()

	# Trail
	if velocity.length() > 10:
		trail.emitting = true
		trail.rotation = facing + PI
	else:
		trail.emitting = false

func take_damage(amount: float) -> void:
	if invincible_timer > 0:
		return
	var actual := maxf(amount - float(armor), 1.0)
	hp -= actual
	health_changed.emit(hp, max_hp)
	invincible_timer = 0.5
	# Hit particles
	particles.emitting = true
	# Screen shake (stronger on desktop, gentler on mobile)
	var shake_strength := 3.0 if not OS.has_feature("android") else 2.0
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("add_shake"):
		cam.add_shake(0.15, shake_strength)
	# SFX
	SoundManager.play_sfx("player_hurt", 0.05, -3.0)

func heal(amount: float) -> void:
	hp = minf(hp + amount, max_hp)
	health_changed.emit(hp, max_hp)

func die() -> void:
	GameManager.game_over()
	died.emit()
	SoundManager.play_sfx("game_over", 0.0, -3.0)
	SoundManager.stop_music()
	visible = false
	set_physics_process(false)

func fire_weapon() -> void:
	var nearest_enemy := find_nearest_enemy()
	if not nearest_enemy:
		return

	var bullet_scene := preload("res://scenes/Bullet.tscn")
	var base_dir := (nearest_enemy.global_position - global_position).normalized()

	# Fire multiple shots if multishot upgrade (spread pattern)
	var shot_count := multishot_count
	for i in range(shot_count):
		# Calculate spread offset
		var offset := 0.0
		if shot_count > 1:
			offset = float(i - shot_count/2) * 0.15  # ~15 degree spread

		var dir := base_dir.rotated(offset)
		var bullet := bullet_scene.instantiate()
		bullet.global_position = weapon_origin.global_position
		bullet.direction = dir
		bullet.damage = 10.0 * damage_mult
		bullet.is_crit = randf() < crit_chance
		if bullet.is_crit:
			bullet.damage *= 2.0
		get_parent().add_child(bullet)

	# One SFX for the volley
	SoundManager.play_sfx("shoot", 0.08, -6.0)

func find_nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
	var nearest: Node2D = null
	var nearest_dist := INF
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var d := global_position.distance_to(e.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = e
	return nearest

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("xp_gems"):
		GameManager.add_xp(body.xp_value)
		body.collect()

func _get_camera() -> Camera2D:
	return get_viewport().get_camera_2d()
