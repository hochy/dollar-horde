extends Node2D
# Dollar Horde - Game Root
# Handles mobile detection and touch control visibility

@onready var touch_controls: CanvasLayer = $TouchControls

func _ready() -> void:
	# Show touch controls on mobile/Android
	if OS.has_feature("android") or OS.has_feature("ios"):
		touch_controls.visible = true
	else:
		touch_controls.visible = false
		# For testing touch controls in editor
		# Press F1 to toggle visibility