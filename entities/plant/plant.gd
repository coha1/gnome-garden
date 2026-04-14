class_name Plant
extends StaticBody3D


## Scale the visual root reaches after full growth
@export var grown_scale: Vector3 = Vector3(1.8, 1.8, 1.8)

## Seconds to reach full size after watering
@export var grow_duration: float = 10.0

## Prompt text when plant is ready to water
@export var prompt_text: String = "▼\nWater"


# ---- Appearance constants ----
# Unwatered sprout: desaturated, olive/brownish-green — looks a little dry
const COLOR_STEM_SPROUT  := Color(0.38, 0.44, 0.22, 1.0)
const COLOR_HEAD_SPROUT  := Color(0.52, 0.56, 0.26, 1.0)

# Watered and growing: deep, saturated green — visibly healthy
const COLOR_STEM_GROW    := Color(0.10, 0.40, 0.07, 1.0)
const COLOR_HEAD_GROW    := Color(0.08, 0.52, 0.10, 1.0)

# Ripe: stem stays deep green, head turns bright purple
const COLOR_HEAD_RIPE    := Color(0.68, 0.10, 0.90, 1.0)


var is_watered: bool = false
var is_grown: bool = false
var grow_elapsed: float = 0.0

var _is_highlighted: bool = false

var _mat_stem_sprout: StandardMaterial3D
var _mat_stem_grow: StandardMaterial3D
var _mat_head_sprout: StandardMaterial3D
var _mat_head_grow: StandardMaterial3D
var _mat_head_ripe: StandardMaterial3D


@onready var visual_root: Node3D = $VisualRoot
@onready var stem_mesh: MeshInstance3D = $VisualRoot/Stem
@onready var head_mesh: MeshInstance3D = $VisualRoot/Head
@onready var interact_zone: Area3D = $InteractZone
@onready var interaction_prompt: InteractionPrompt = $InteractionPrompt


func _ready() -> void:
	_mat_stem_sprout = _make_mat(COLOR_STEM_SPROUT)
	_mat_stem_grow   = _make_mat(COLOR_STEM_GROW)
	_mat_head_sprout = _make_mat(COLOR_HEAD_SPROUT)
	_mat_head_grow   = _make_mat(COLOR_HEAD_GROW)
	_mat_head_ripe   = _make_mat(COLOR_HEAD_RIPE)

	interact_zone.add_to_group("interactable")
	_apply_appearance()
	print(get_path(), ": Plant ready")


func _process(delta: float) -> void:
	if not is_watered or is_grown:
		return

	grow_elapsed += delta
	var t := minf(grow_elapsed / grow_duration, 1.0)
	visual_root.scale = Vector3.ONE.lerp(grown_scale, t)

	if grow_elapsed >= grow_duration:
		is_grown = true
		_on_state_changed()


func interact() -> void:
	if is_grown:
		_harvest()
	elif not is_watered:
		_water()
	# no-op while actively growing


func set_highlighted(on: bool) -> void:
	_is_highlighted = on
	_refresh_prompt()


# ---- Private ----

func _water() -> void:
	is_watered = true
	grow_elapsed = 0.0
	_on_state_changed()
	print(get_path(), ": watered — growing over ", grow_duration, "s")


func _harvest() -> void:
	is_watered = false
	is_grown = false
	grow_elapsed = 0.0
	visual_root.scale = Vector3.ONE
	_on_state_changed()
	print(get_path(), ": harvested — ready to water again")


func _on_state_changed() -> void:
	_apply_appearance()
	_refresh_prompt()


func _apply_appearance() -> void:
	if is_grown:
		stem_mesh.set_surface_override_material(0, _mat_stem_grow)
		head_mesh.set_surface_override_material(0, _mat_head_ripe)
	elif is_watered:
		stem_mesh.set_surface_override_material(0, _mat_stem_grow)
		head_mesh.set_surface_override_material(0, _mat_head_grow)
	else:
		stem_mesh.set_surface_override_material(0, _mat_stem_sprout)
		head_mesh.set_surface_override_material(0, _mat_head_sprout)


func _refresh_prompt() -> void:
	interaction_prompt.visible = _is_highlighted
	if is_watered and not is_grown:
		interaction_prompt.set_text("Growing...")
		interaction_prompt.set_active(false)
	elif is_grown:
		interaction_prompt.set_text("▼\nHarvest")
		interaction_prompt.set_active(true)
	else:
		interaction_prompt.set_text(prompt_text)
		interaction_prompt.set_active(true)


func _make_mat(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	return mat
