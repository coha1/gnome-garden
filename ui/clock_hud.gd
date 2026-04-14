class_name ClockHud
extends Control


@onready var clock_label: Label = $ClockLabel


func _process(_delta: float) -> void:
	clock_label.text = DayNightCycle.get_clock_string()
