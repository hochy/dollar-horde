extends Control

# Dollar Horde - Main Menu
@onready var play_btn: Button = $VBoxContainer/PlayBtn
@onready var quit_btn: Button = $VBoxContainer/QuitBtn
@onready var title_label: Label = $VBoxContainer/Title
@onready var subtitle_label: Label = $VBoxContainer/Subtitle

func _ready() -> void:
	# Style title
	title_label.add_theme_color_override("font_color", Color(0.2, 0.6, 1, 1))
	title_label.add_theme_font_size_override("font_size", 32)

	# Style subtitle
	subtitle_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6, 1))
	subtitle_label.add_theme_font_size_override("font_size", 14)

	# Style play button
	_style_button(play_btn, Color(0.2, 0.7, 0.3, 1))
	play_btn.add_theme_font_size_override("font_size", 20)

	# Style quit button
	_style_button(quit_btn, Color(0.5, 0.2, 0.2, 1))

	play_btn.pressed.connect(_on_play)
	quit_btn.pressed.connect(_on_quit)

func _style_button(btn: Button, color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.corner_radius_top_left = 8
	normal.corner_radius_top_right = 8
	normal.corner_radius_bottom_left = 8
	normal.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = color.lightened(0.25)
	hover.corner_radius_top_left = 8
	hover.corner_radius_top_right = 8
	hover.corner_radius_bottom_left = 8
	hover.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = color.darkened(0.2)
	pressed.corner_radius_top_left = 8
	pressed.corner_radius_top_right = 8
	pressed.corner_radius_bottom_left = 8
	pressed.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("pressed", pressed)

	btn.add_theme_color_override("font_color", Color.WHITE)

func _on_play() -> void:
	SoundManager.play_sfx("button_click", 0.05, -4.0)
	GameManager.reset()
	SoundManager.play_music()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_quit() -> void:
	SoundManager.play_sfx("button_click", 0.05, -4.0)
	get_tree().quit()
