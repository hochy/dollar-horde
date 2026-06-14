extends Node

# Dollar Horde - Game Manager

signal xp_gained(amount: int)
signal level_up(new_level: int)
signal player_died
signal wave_changed(wave: int)

const XP_BASE := 12
const XP_SCALE := 1.35  # Gentler exponential curve

var player: CharacterBody2D
var xp: int = 0
var level: int = 1
var xp_to_next: int = 12
var wave: int = 1
var enemies_killed: int = 0
var time_elapsed: float = 0.0
var is_game_over: bool = false
var is_paused: bool = false
var weapons: Array = []

# Upgrades available
# Upgrades available (with keys for color-coding)
var all_upgrades: Array = [
	{"name": "Speed Boost", "desc": "Move 15% faster", "stat": "speed", "value": 0.15, "key": "speed"},
	{"name": "Max HP Up", "desc": "+20 max health", "stat": "max_hp", "value": 20, "key": "health"},
	{"name": "Damage Up", "desc": "+10% damage", "stat": "damage", "value": 0.10, "key": "damage"},
	{"name": "Fire Rate Up", "desc": "+10% fire rate", "stat": "fire_rate", "value": 0.10, "key": "damage"},
	{"name": "Pickup Range", "desc": "+30% pickup range", "stat": "pickup_range", "value": 0.30, "key": "magnet"},
	{"name": "Armor", "desc": "-1 damage taken", "stat": "armor", "value": 1, "key": "health"},
	{"name": "Regen", "desc": "+1 HP every 5s", "stat": "regen", "value": 1.0, "key": "health"},
	{"name": "Crit Chance", "desc": "+5% crit chance", "stat": "crit", "value": 0.05, "key": "crit"},
	{"name": "Multi-Shot", "desc": "Fire 2 projectiles", "stat": "multishot", "value": 1, "key": "multishot"},
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if is_game_over or is_paused or not player:
		return
	time_elapsed += delta
	# Waves every 30 seconds
	var new_wave := int(time_elapsed / 30.0) + 1
	if new_wave != wave:
		wave = new_wave
		wave_changed.emit(wave)
		SoundManager.play_sfx("wave_start", 0.0, -2.0)

func add_xp(amount: int) -> void:
	xp += amount
	xp_gained.emit(amount)
	while xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next = int(XP_BASE * pow(XP_SCALE, level - 1))
		level_up.emit(level)

func get_random_upgrades(count: int = 3) -> Array:
	var available := all_upgrades.duplicate(true)
	available.shuffle()
	return available.slice(0, count)

func apply_upgrade(upgrade: Dictionary) -> void:
	if not player:
		return
	match upgrade["stat"]:
		"speed":
			player.move_speed *= (1.0 + upgrade["value"])
		"max_hp":
			player.max_hp += int(upgrade["value"])
			player.hp = min(player.hp + int(upgrade["value"]), player.max_hp)
		"damage":
			player.damage_mult *= (1.0 + upgrade["value"])
		"fire_rate":
			player.fire_rate_mult *= (1.0 + upgrade["value"])
		"pickup_range":
			player.pickup_range_mult *= (1.0 + upgrade["value"])
		"armor":
			player.armor += int(upgrade["value"])
		"regen":
			player.regen_rate += upgrade["value"]
		"crit":
			player.crit_chance += upgrade["value"]
		"multishot":
			# Weapon multiplicity - fire multiple bullets per shot
			player.multishot_count = (player.multishot_count if player.has("multishot_count") else 1) + int(upgrade["value"])

func reset() -> void:
	xp = 0
	level = 1
	xp_to_next = XP_BASE
	wave = 1
	enemies_killed = 0
	time_elapsed = 0.0
	is_game_over = false
	is_paused = false
	weapons.clear()

func game_over() -> void:
	is_game_over = true
	player_died.emit()