class_name WildBug
extends CharacterBody3D


## Wandering speed in units per second
@export var wander_speed: float = 0.7

## How often to pick a new random direction in seconds
@export var direction_change_interval: float = 2.5

## How long the heart stays visible after interaction
@export var heart_display_duration: float = 2.0

## Text shown in the interaction prompt when the player is in range
@export var prompt_text: String = "▼\nPet"


var wander_direction: Vector3 = Vector3.ZERO
var direction_timer: float = 0.0
var heart_timer: float = 0.0


@onready var heart_label: Label3D = $HeartLabel
@onready var interact_zone: Area3D = $InteractZone
@onready var interaction_prompt: InteractionPrompt = $InteractionPrompt


func _ready() -> void:
	heart_label.visible = false
	interact_zone.add_to_group("interactable")
	interaction_prompt.set_text(prompt_text)
	_pick_new_direction()
	print(get_path(), ": WildBug ready")


func set_highlighted(on: bool) -> void:
	interaction_prompt.visible = on


func _process(delta: float) -> void:
	if heart_timer <= 0.0:
		return
	heart_timer -= delta
	if heart_timer <= 0.0:
		heart_label.visible = false


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	direction_timer += delta
	if direction_timer >= direction_change_interval:
		direction_timer = 0.0
		_pick_new_direction()

	velocity.x = wander_direction.x * wander_speed
	velocity.z = wander_direction.z * wander_speed

	if wander_direction.length() > 0.1:
		rotation.y = atan2(-wander_direction.x, -wander_direction.z)

	move_and_slide()


func _pick_new_direction() -> void:
	var angle := randf() * TAU
	wander_direction = Vector3(cos(angle), 0.0, sin(angle))


func interact() -> void:
	heart_timer = heart_display_duration
	heart_label.visible = true
	print(get_path(), ": bug interacted — heart visible for ", heart_display_duration, "s")
