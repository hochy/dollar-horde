extends Control

# Dollar Horde - Virtual Joystick (touch controls)
signal joystick_input(direction: Vector2)

@onready var knob: ColorRect = $Knob
@onready var bg: ColorRect = $Bg

var is_touching: bool = false
var touch_index: int = -1
var center_pos: Vector2
var max_distance: float = 50.0

func _ready() -> void:
	center_pos = bg.global_position + bg.size / 2.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			var local := make_canvas_position_local(event.position)
			if bg.get_rect().has_point(local):
				is_touching = true
				touch_index = event.index
				_update_knob(event.position)
		elif event.index == touch_index:
			is_touching = false
			touch_index = -1
			knob.global_position = center_pos - knob.size / 2.0
			joystick_input.emit(Vector2.ZERO)
			if GameManager.player:
				GameManager.player.joystick_vector = Vector2.ZERO

	elif event is InputEventScreenDrag and event.index == touch_index and is_touching:
		_update_knob(event.position)

func _update_knob(touch_pos: Vector2) -> void:
	var diff := touch_pos - center_pos
	var dist := diff.length()
	if dist > max_distance:
		diff = diff.normalized() * max_distance

	var direction := diff / max_distance
	knob.global_position = center_pos + diff - knob.size / 2.0

	joystick_input.emit(direction)
	if GameManager.player:
		GameManager.player.joystick_vector = direction
