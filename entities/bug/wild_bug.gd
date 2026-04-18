class_name WildBug
extends CharacterBody3D


## Wandering speed in units per second
@export var wander_speed: float = 0.7

## How often to pick a new random direction in seconds
@export var direction_change_interval: float = 2.5

## How long the heart stays visible after an interaction
@export var heart_display_duration: float = 2.0

## Number of feedings required to reach full bond
@export var bond_threshold: int = 3

## Distance at which the bug stops trailing the player
@export var follow_trail_distance: float = 1.8

## Wander speed multiplier applied when following
@export var follow_speed_multiplier: float = 1.5

## Assign the player node in the editor for follow behaviour
@export var player: Player


var bond_level: int = 0
var is_bonded: bool = false

var _wander_direction: Vector3 = Vector3.ZERO
var _direction_timer: float = 0.0
var _heart_timer: float = 0.0
var _is_highlighted: bool = false


@onready var heart_label: Label3D = $HeartLabel
@onready var interact_zone: Area3D = $InteractZone
@onready var interaction_prompt: InteractionPrompt = $InteractionPrompt


func _ready() -> void:
	if player == null:
		var found: Array[Node] = get_tree().get_nodes_in_group("player")
		if found.size() > 0:
			player = found[0] as Player
	heart_label.visible = false
	interact_zone.add_to_group("interactable")
	interaction_prompt.set_text("▼\nFeed")
	interaction_prompt.set_active(true)
	_pick_new_direction()
	print(get_path(), ": WildBug ready")


func set_highlighted(on: bool) -> void:
	_is_highlighted = on
	interaction_prompt.visible = on


func interact() -> void:
	if is_bonded:
		_show_heart()
		return

	if not Inventory.consume_veggie():
		Notifications.notify("You don't have any veggies to give.")
		return

	bond_level += 1
	_show_heart()
	print(get_path(), ": fed — bond ", bond_level, "/", bond_threshold)

	if bond_level >= bond_threshold:
		_become_bonded()


func _process(delta: float) -> void:
	if _heart_timer <= 0.0:
		return
	_heart_timer -= delta
	if _heart_timer <= 0.0:
		heart_label.visible = false


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	if is_bonded:
		_move_toward_player()
	else:
		_wander(delta)

	move_and_slide()


# ---- Private ----

func _wander(delta: float) -> void:
	_direction_timer += delta
	if _direction_timer >= direction_change_interval:
		_direction_timer = 0.0
		_pick_new_direction()

	velocity.x = _wander_direction.x * wander_speed
	velocity.z = _wander_direction.z * wander_speed

	if _wander_direction.length() > 0.1:
		rotation.y = atan2(-_wander_direction.x, -_wander_direction.z)


func _move_toward_player() -> void:
	if player == null:
		velocity.x = 0.0
		velocity.z = 0.0
		return

	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0.0
	var dist: float = to_player.length()

	if dist <= follow_trail_distance:
		velocity.x = 0.0
		velocity.z = 0.0
		return

	var dir: Vector3 = to_player.normalized()
	var speed: float = wander_speed * follow_speed_multiplier
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	rotation.y = atan2(-dir.x, -dir.z)


func _become_bonded() -> void:
	is_bonded = true
	interaction_prompt.set_text("▼\nPet")
	print(get_path(), ": bonded — now following player")


func _show_heart() -> void:
	_heart_timer = heart_display_duration
	heart_label.visible = true


func _pick_new_direction() -> void:
	var angle: float = randf() * TAU
	_wander_direction = Vector3(cos(angle), 0.0, sin(angle))
