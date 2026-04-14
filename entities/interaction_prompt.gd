class_name InteractionPrompt
extends Node3D


@onready var label: Label3D = $Label3D

var _base_y: float


func _ready() -> void:
	_base_y = position.y
	visible = false


func _process(_delta: float) -> void:
	if not visible:
		return
	position.y = _base_y + sin(Time.get_ticks_msec() * 0.004) * 0.1


func set_text(text: String) -> void:
	label.text = text


## active=true: warm yellow (interactable). active=false: muted gray (informational).
func set_active(active: bool) -> void:
	label.modulate = Color(1.0, 0.95, 0.3, 1.0) if active else Color(0.6, 0.6, 0.6, 0.75)
