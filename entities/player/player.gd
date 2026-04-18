class_name Player
extends CharacterBody3D


## Ground movement speed in units per second
@export var move_speed: float = 3.5

## Fixed overhead camera pitch — negative tilts down toward the player
@export var camera_pitch_degrees: float = -45.0


@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var interaction_area: Area3D = $InteractionArea
@onready var visual_pivot: Node3D = $Node3D

var _highlighted: Node3D = null


func _ready() -> void:
	add_to_group("player")
	spring_arm.rotation = Vector3(deg_to_rad(camera_pitch_degrees), 0.0, 0.0)
	print(get_path(), ": Player ready")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	_apply_movement()
	_update_highlight()
	move_and_slide()


func _apply_movement() -> void:
	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_forward", "move_back")
	)

	if input_dir == Vector2.ZERO:
		velocity.x = 0.0
		velocity.z = 0.0
		return

	# spring_arm.rotation.y is the camera yaw in world space (CharacterBody3D never
	# rotates on Y, so local == world). Stays 0 for the fixed north camera, but
	# cutscene code can rotate the arm and movement will adapt automatically.
	var cam_yaw := spring_arm.rotation.y
	var forward := Vector3(-sin(cam_yaw), 0.0, -cos(cam_yaw))
	var right   := Vector3( cos(cam_yaw), 0.0, -sin(cam_yaw))
	var move_dir := (right * input_dir.x + forward * -input_dir.y).normalized()

	velocity.x = move_dir.x * move_speed
	velocity.z = move_dir.z * move_speed

	visual_pivot.rotation.y = atan2(-move_dir.x, -move_dir.z)


func _update_highlight() -> void:
	var nearest: Node3D = null
	for area: Area3D in interaction_area.get_overlapping_areas():
		if area.is_in_group("interactable"):
			nearest = area.get_parent()
			break

	if nearest == _highlighted:
		return

	if _highlighted != null and _highlighted.has_method("set_highlighted"):
		_highlighted.set_highlighted(false)

	_highlighted = nearest

	if _highlighted != null and _highlighted.has_method("set_highlighted"):
		_highlighted.set_highlighted(true)


func _try_interact() -> void:
	for area: Area3D in interaction_area.get_overlapping_areas():
		if area.is_in_group("interactable"):
			area.get_parent().interact()
			return
