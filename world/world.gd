class_name World
extends Node3D


@onready var sun_light: DirectionalLight3D = $SunLight
@onready var world_environment: WorldEnvironment = $WorldEnvironment


func _process(_delta: float) -> void:
	_update_lighting()


func _update_lighting() -> void:
	var sky_color := DayNightCycle.get_sky_color()

	# Rotate sun across the sky — rises in "east" (+X), sets in "west" (-X)
	var sun_angle := (DayNightCycle.time_of_day - 0.25) * TAU
	sun_light.rotation.x = -sin(sun_angle) * (PI * 0.45) - 0.2
	sun_light.rotation.z = cos(sun_angle) * 0.3

	sun_light.light_energy = DayNightCycle.get_light_energy()
	sun_light.light_color = sky_color.lerp(Color.WHITE, 0.6)

	var env := world_environment.environment
	env.background_color = sky_color
	env.ambient_light_color = sky_color
	env.ambient_light_energy = DayNightCycle.get_ambient_energy()
