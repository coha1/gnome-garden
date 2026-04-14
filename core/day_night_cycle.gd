extends Node


## Duration of one full in-game day in real seconds
@export var day_duration_seconds: float = 1440.0

## Current time of day — 0.0 = midnight, 0.25 = 6 AM, 0.5 = noon, 0.75 = 6 PM
var time_of_day: float = 0.27  # Start just after 6 AM


signal day_ended


func _ready() -> void:
	print(get_path(), ": DayNightCycle ready — day lasts ", day_duration_seconds, "s")


func _process(delta: float) -> void:
	time_of_day += delta / day_duration_seconds

	if time_of_day >= 1.0:
		time_of_day -= 1.0
		day_ended.emit()
		print(get_path(), ": day ended")


func get_clock_string() -> String:
	var total_minutes: int = int(time_of_day * 1440.0)
	var hour: int = total_minutes / 60
	var minute: int = total_minutes % 60
	var period: String = "AM" if hour < 12 else "PM"
	var display_hour: int = hour % 12
	if display_hour == 0:
		display_hour = 12
	return "%d:%02d %s" % [display_hour, minute, period]


## Returns a sky/ambient color for the current time of day
func get_sky_color() -> Color:
	var midnight := Color(0.02, 0.02, 0.10)
	var dawn    := Color(0.85, 0.45, 0.20)
	var day     := Color(0.38, 0.62, 1.00)
	var dusk    := Color(0.75, 0.30, 0.15)

	if time_of_day < 0.25:
		return midnight.lerp(dawn, time_of_day / 0.25)
	elif time_of_day < 0.5:
		return dawn.lerp(day, (time_of_day - 0.25) / 0.25)
	elif time_of_day < 0.75:
		return day.lerp(dusk, (time_of_day - 0.5) / 0.25)
	else:
		return dusk.lerp(midnight, (time_of_day - 0.75) / 0.25)


## Returns directional light energy — 0 at night, peaks at noon
func get_light_energy() -> float:
	return clampf(sin((time_of_day - 0.25) * TAU) * 1.3, 0.0, 1.2)


## Returns ambient light energy — dim at night, bright midday
func get_ambient_energy() -> float:
	return clampf(sin((time_of_day - 0.25) * TAU) * 0.6 + 0.35, 0.05, 0.9)
