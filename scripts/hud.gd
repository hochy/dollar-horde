extends CanvasLayer

# Dollar Horde - HUD
@onready var hp_bar: ProgressBar = $MarginContainer/VBoxContainer/HpBar
@onready var hp_label: Label = $MarginContainer/VBoxContainer/HpLabel
@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/XpBar
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var timer_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/TimerLabel
@onready var wave_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/WaveLabel
@onready var kill_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/KillLabel

@onready var level_up_panel: Panel = $LevelUpPanel
@onready var level_up_title: Label = $LevelUpPanel/VBoxContainer/Title
@onready var upgrade_container: VBoxContainer = $LevelUpPanel/VBoxContainer/UpgradeContainer
@onready var game_over_panel: Panel = $GameOverPanel
@onready var game_over_stats: Label = $GameOverPanel/VBoxContainer/Stats
@onready var restart_btn: Button = $GameOverPanel/VBoxContainer/RestartBtn
@onready var menu_btn: Button = $GameOverPanel/VBoxContainer/MenuBtn

func _ready() -> void:
	# Style the HP bar
	var hp_style := StyleBoxFlat.new()
	hp_style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	hp_style.corner_radius_top_left = 4
	hp_style.corner_radius_top_right = 4
	hp_style.corner_radius_bottom_left = 4
	hp_style.corner_radius_bottom_right = 4
	hp_bar.add_theme_stylebox_override("background", hp_style)

	var hp_fill := StyleBoxFlat.new()
	hp_fill.bg_color = Color(0.9, 0.2, 0.2, 1)
	hp_fill.corner_radius_top_left = 4
	hp_fill.corner_radius_top_right = 4
	hp_fill.corner_radius_bottom_left = 4
	hp_fill.corner_radius_bottom_right = 4
	hp_bar.add_theme_stylebox_override("fill", hp_fill)

	# Style XP bar
	var xp_style := StyleBoxFlat.new()
	xp_style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	xp_style.corner_radius_top_left = 3
	xp_style.corner_radius_top_right = 3
	xp_style.corner_radius_bottom_left = 3
	xp_style.corner_radius_bottom_right = 3
	xp_bar.add_theme_stylebox_override("background", xp_style)

	var xp_fill := StyleBoxFlat.new()
	xp_fill.bg_color = Color(0.2, 0.8, 0.3, 1)
	xp_fill.corner_radius_top_left = 3
	xp_fill.corner_radius_top_right = 3
	xp_fill.corner_radius_bottom_left = 3
	xp_fill.corner_radius_bottom_right = 3
	xp_bar.add_theme_stylebox_override("fill", xp_fill)

	# Style labels
	var font_color := Color(0.9, 0.9, 0.95, 1)
	hp_label.add_theme_color_override("font_color", font_color)
	level_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	timer_label.add_theme_color_override("font_color", font_color)
	wave_label.add_theme_color_override("font_color", Color(0.6, 0.8, 1, 1))
	kill_label.add_theme_color_override("font_color", font_color)

	# Style level-up panel
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.3, 0.6, 1, 0.5)
	level_up_panel.add_theme_stylebox_override("panel", panel_style)

	# Style game over panel
	var go_style := StyleBoxFlat.new()
	go_style.bg_color = Color(0.08, 0.05, 0.05, 0.95)
	go_style.corner_radius_top_left = 12
	go_style.corner_radius_top_right = 12
	go_style.corner_radius_bottom_left = 12
	go_style.corner_radius_bottom_right = 12
	go_style.border_width_left = 2
	go_style.border_width_top = 2
	go_style.border_width_right = 2
	go_style.border_width_bottom = 2
	go_style.border_color = Color(0.8, 0.2, 0.2, 0.5)
	game_over_panel.add_theme_stylebox_override("panel", go_style)

	# Style buttons
	_style_button(restart_btn, Color(0.2, 0.6, 1, 1))
	_style_button(menu_btn, Color(0.4, 0.4, 0.5, 1))

	# Connect signals
	GameManager.level_up.connect(_on_level_up)
	GameManager.player_died.connect(_on_player_died)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.xp_gained.connect(_on_xp_gained)

	await get_tree().process_frame
	if GameManager.player:
		GameManager.player.health_changed.connect(_on_health_changed)

	level_up_panel.visible = false
	game_over_panel.visible = false
	_update_display()

func _style_button(btn: Button, color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.corner_radius_top_left = 6
	normal.corner_radius_top_right = 6
	normal.corner_radius_bottom_left = 6
	normal.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = color.lightened(0.2)
	hover.corner_radius_top_left = 6
	hover.corner_radius_top_right = 6
	hover.corner_radius_bottom_left = 6
	hover.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = color.darkened(0.2)
	pressed.corner_radius_top_left = 6
	pressed.corner_radius_top_right = 6
	pressed.corner_radius_bottom_left = 6
	pressed.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("pressed", pressed)

	btn.add_theme_color_override("font_color", Color.WHITE)

func _process(_delta: float) -> void:
	if not GameManager.is_game_over and not GameManager.is_paused:
		var minutes := int(GameManager.time_elapsed) / 60
		var seconds := int(GameManager.time_elapsed) % 60
		timer_label.text = "%d:%02d" % [minutes, seconds]
		kill_label.text = "Kills: %d" % GameManager.enemies_killed
		xp_bar.value = (float(GameManager.xp) / float(GameManager.xp_to_next)) * 100.0
		level_label.text = "Lv %d" % GameManager.level

func _on_health_changed(current: float, maximum: float) -> void:
	hp_bar.value = (current / maximum) * 100.0
	hp_label.text = "HP: %d/%d" % [int(current), int(maximum)]

func _on_xp_gained(_amount: int) -> void:
	xp_bar.value = (float(GameManager.xp) / float(GameManager.xp_to_next)) * 100.0

func _on_level_up(new_level: int) -> void:
	_show_level_up_screen()
	SoundManager.play_sfx("level_up", 0.0, 0.0)

func _on_wave_changed(wave: int) -> void:
	wave_label.text = "Wave %d" % wave

func _on_player_died() -> void:
	game_over_panel.visible = true
	var minutes := int(GameManager.time_elapsed) / 60
	var seconds := int(GameManager.time_elapsed) % 60
	game_over_stats.text = "Survived: %d:%02d\\nKills: %d\\nLevel: %d\\nWave: %d" % [
		minutes, seconds, GameManager.enemies_killed, GameManager.level, GameManager.wave
	]
	get_tree().paused = true

func _show_level_up_screen() -> void:
	level_up_panel.visible = true
	GameManager.is_paused = true
	get_tree().paused = true

	for child in upgrade_container.get_children():
		child.queue_free()

	var upgrades := GameManager.get_random_upgrades(3)
	for upgrade in upgrades:
		var btn := Button.new()
		btn.text = "%s\n%s" % [upgrade["name"], upgrade["desc"]]
		btn.custom_minimum_size.y = 60
		btn.pressed.connect(_on_upgrade_selected.bind(upgrade))
		upgrade_container.add_child(btn)
		
		# Color-code by upgrade type: damage=red, speed=blue, range=green, XP=orange, magnet=purple, health=pink, multishot=yellow, crit=gold
		var upgrade_color := Color(0.2, 0.5, 0.9, 1)
		var upgrade_key: String = upgrade.get("key", "")
		match upgrade_key:
			"damage": upgrade_color = Color(0.9, 0.3, 0.3, 1)  # Red
			"speed": upgrade_color = Color(0.3, 0.5, 0.9, 1)   # Blue
			"range": upgrade_color = Color(0.3, 0.8, 0.4, 1)   # Green
			"xp_drop": upgrade_color = Color(0.9, 0.6, 0.2, 1)  # Orange
			"magnet": upgrade_color = Color(0.7, 0.4, 0.9, 1)   # Purple
			"health": upgrade_color = Color(0.9, 0.5, 0.7, 1)   # Pink
			"multishot": upgrade_color = Color(0.8, 0.8, 0.3, 1) # Yellow
			"crit": upgrade_color = Color(0.9, 0.8, 0.3, 1)    # Gold
		_style_button(btn, upgrade_color)

	level_up_title.text = "Level %d!" % GameManager.level

func _on_upgrade_selected(upgrade: Dictionary) -> void:
	SoundManager.play_sfx("button_click", 0.05, -4.0)
	GameManager.apply_upgrade(upgrade)
	level_up_panel.visible = false
	GameManager.is_paused = false
	get_tree().paused = false

func _update_display() -> void:
	if GameManager.player:
		hp_bar.value = (GameManager.player.hp / GameManager.player.max_hp) * 100.0
		hp_label.text = "HP: %d/%d" % [int(GameManager.player.hp), int(GameManager.player.max_hp)]
	else:
		hp_bar.value = 100.0
		hp_label.text = "HP: 100/100"
	xp_bar.value = 0.0
	level_label.text = "Lv 1"
	wave_label.text = "Wave 1"

func _on_restart_btn_pressed() -> void:
	SoundManager.play_sfx("button_click", 0.05, -4.0)
	get_tree().paused = false
	GameManager.reset()
	get_tree().reload_current_scene()

func _on_menu_btn_pressed() -> void:
	SoundManager.play_sfx("button_click", 0.05, -4.0)
	get_tree().paused = false
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
