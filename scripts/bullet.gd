extends Area2D

# Dollar Horde - Bullet
var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var damage: float = 10.0
var is_crit: bool = false
var lifetime: float = 2.0

@onready var trail: GPUParticles2D = $Trail

func _ready() -> void:
	rotation = direction.angle()
	trail.emitting = true
	if is_crit:
		# Crit bullets are bigger and golden
		scale = Vector2(1.5, 1.5)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
		# Impact effect
		var impact := CPUParticles2D.new()
		impact.emitting = true
		impact.one_shot = true
		impact.explosiveness = 1.0
		impact.amount = 8
		impact.lifetime = 0.3
		impact.direction = -direction
		impact.spread = 60.0
		impact.initial_velocity_min = 50.0
		impact.initial_velocity_max = 100.0
		impact.scale_amount_min = 2.0
		impact.scale_amount_max = 4.0
		impact.color = Color(1, 0.8, 0.2) if is_crit else Color(1, 1, 0.5)
		get_parent().add_child(impact)
		impact.global_position = global_position
		# Auto-free impact
		await get_tree().create_timer(0.5).timeout
		if is_instance_valid(impact):
			impact.queue_free()
		# SFX
		SoundManager.play_sfx("hit", 0.1, -8.0)
		queue_free()
