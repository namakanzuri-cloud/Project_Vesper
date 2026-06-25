extends Node3D
class_name HitVfx

enum HitKind { LIGHT, HEAVY, ENEMY, PARRY, JUST_DODGE, RIPOSTE, VESPER_COUNTER, VESPER_ART }

@export var hit_kind: HitKind = HitKind.LIGHT
@export var effect_scale: float = 1.0
@export var lifetime: float = 0.22

var _start_usec: int = 0
var _materials: Array[StandardMaterial3D] = []
var _parts: Array[Dictionary] = []
var _visual_root: Node3D

func configure(kind: int, scale: float, custom_lifetime: float) -> void:
	hit_kind = kind
	effect_scale = maxf(0.01, scale)
	if custom_lifetime > 0.0:
		lifetime = custom_lifetime

func _ready() -> void:
	add_to_group(&"hit_vfx")
	_start_usec = Time.get_ticks_usec()
	_build_visual()
	_update_visual(0.0)
	set_process(true)

func _process(_delta: float) -> void:
	var elapsed := float(Time.get_ticks_usec() - _start_usec) / 1000000.0
	var progress := elapsed / maxf(lifetime, 0.001)
	if progress >= 1.0:
		queue_free()
		return

	_update_visual(clampf(progress, 0.0, 1.0))

func _build_visual() -> void:
	_visual_root = Node3D.new()
	_visual_root.scale = Vector3.ONE * effect_scale
	add_child(_visual_root)

	match hit_kind:
		HitKind.HEAVY:
			_build_heavy_hit()
		HitKind.ENEMY:
			_build_enemy_hit()
		HitKind.PARRY:
			_build_parry_hit()
		HitKind.JUST_DODGE:
			_build_just_dodge_hit()
		HitKind.RIPOSTE:
			_build_riposte_hit()
		HitKind.VESPER_COUNTER:
			_build_vesper_counter_hit()
		HitKind.VESPER_ART:
			_build_vesper_art_hit()
		_:
			_build_light_hit()

func _build_light_hit() -> void:
	var blue := _make_material(Color(0.55, 0.9, 1.0, 0.82), 0.9)
	var white := _make_material(Color(1.0, 1.0, 0.75, 0.72), 0.75)

	_add_disc(blue, Vector3.ZERO, Vector3(0.16, 1.0, 0.16), Vector3(0.62, 1.0, 0.62))
	_add_sphere(white, Vector3.UP * 0.03, Vector3.ONE * 0.35, Vector3.ONE * 0.08)
	_add_bar(white, 0.0, Vector3(0.16, 0.45, 0.45), Vector3(1.0, 1.0, 1.0))
	_add_bar(white, PI * 0.5, Vector3(0.16, 0.45, 0.45), Vector3(1.0, 1.0, 1.0))

func _build_heavy_hit() -> void:
	var gold := _make_material(Color(1.0, 0.62, 0.14, 0.86), 1.15)
	var pale := _make_material(Color(1.0, 0.95, 0.48, 0.78), 0.9)

	_add_disc(gold, Vector3.ZERO, Vector3(0.2, 1.0, 0.2), Vector3(0.92, 1.0, 0.92))
	_add_sphere(pale, Vector3.UP * 0.04, Vector3.ONE * 0.48, Vector3.ONE * 0.12)
	_add_bar(pale, 0.0, Vector3(0.18, 0.55, 0.55), Vector3(1.25, 1.0, 1.25))
	_add_bar(pale, PI * 0.5, Vector3(0.18, 0.55, 0.55), Vector3(1.25, 1.0, 1.25))
	_add_sparks(gold, 8, 0.28, 0.72, 0.1)

func _build_enemy_hit() -> void:
	var red := _make_material(Color(1.0, 0.12, 0.08, 0.84), 1.0)
	var magenta := _make_material(Color(1.0, 0.18, 0.45, 0.74), 0.85)

	_add_disc(red, Vector3.ZERO, Vector3(0.18, 1.0, 0.18), Vector3(0.72, 1.0, 0.72))
	_add_sphere(red, Vector3.UP * 0.04, Vector3.ONE * 0.38, Vector3.ONE * 0.08)
	_add_bar(magenta, PI * 0.25, Vector3(0.16, 0.5, 0.5), Vector3(1.1, 1.0, 1.1))
	_add_bar(magenta, PI * 0.75, Vector3(0.16, 0.5, 0.5), Vector3(1.1, 1.0, 1.1))
	_add_sparks(red, 5, 0.22, 0.58, 0.22)

func _build_parry_hit() -> void:
	var cyan := _make_material(Color(0.2, 1.0, 0.95, 0.9), 1.35)
	var white := _make_material(Color(1.0, 1.0, 0.82, 0.84), 1.1)

	_add_disc(cyan, Vector3.ZERO, Vector3(0.24, 1.0, 0.24), Vector3(1.18, 1.0, 1.18))
	_add_sphere(white, Vector3.UP * 0.05, Vector3.ONE * 0.5, Vector3.ONE * 0.1)
	_add_bar(white, 0.0, Vector3(0.18, 0.62, 0.62), Vector3(1.45, 1.0, 1.45))
	_add_bar(white, PI * 0.5, Vector3(0.18, 0.62, 0.62), Vector3(1.45, 1.0, 1.45))
	_add_sparks(cyan, 10, 0.24, 0.86, 0.0)

func _build_just_dodge_hit() -> void:
	var mint := _make_material(Color(0.55, 1.0, 0.72, 0.82), 1.0)
	var gold := _make_material(Color(1.0, 0.9, 0.32, 0.72), 0.8)

	_add_disc(mint, Vector3.ZERO, Vector3(0.28, 1.0, 0.28), Vector3(1.28, 1.0, 1.28))
	_add_disc(gold, Vector3.UP * 0.04, Vector3(0.18, 1.0, 0.18), Vector3(0.82, 1.0, 0.82))
	_add_sparks(mint, 8, 0.22, 0.72, 0.18)

func _build_riposte_hit() -> void:
	var teal := _make_material(Color(0.18, 1.0, 0.82, 0.9), 1.45)
	var white := _make_material(Color(1.0, 1.0, 0.82, 0.82), 1.05)

	_add_disc(teal, Vector3.ZERO, Vector3(0.24, 1.0, 0.24), Vector3(1.34, 1.0, 1.34))
	_add_sphere(white, Vector3.UP * 0.05, Vector3.ONE * 0.52, Vector3.ONE * 0.1)
	_add_bar(white, PI * 0.125, Vector3(0.18, 0.6, 0.6), Vector3(1.55, 1.0, 1.55))
	_add_bar(white, PI * 0.625, Vector3(0.18, 0.6, 0.6), Vector3(1.55, 1.0, 1.55))
	_add_sparks(teal, 12, 0.26, 0.92, 0.08)

func _build_vesper_counter_hit() -> void:
	var gold := _make_material(Color(1.0, 0.82, 0.18, 0.92), 1.65)
	var violet := _make_material(Color(0.72, 0.45, 1.0, 0.78), 1.15)
	var white := _make_material(Color(1.0, 1.0, 0.9, 0.86), 1.2)

	_add_disc(gold, Vector3.ZERO, Vector3(0.3, 1.0, 0.3), Vector3(1.72, 1.0, 1.72))
	_add_disc(violet, Vector3.UP * 0.05, Vector3(0.2, 1.0, 0.2), Vector3(1.18, 1.0, 1.18))
	_add_sphere(white, Vector3.UP * 0.07, Vector3.ONE * 0.62, Vector3.ONE * 0.12)
	_add_bar(white, 0.0, Vector3(0.2, 0.72, 0.72), Vector3(1.85, 1.0, 1.85))
	_add_bar(white, PI * 0.5, Vector3(0.2, 0.72, 0.72), Vector3(1.85, 1.0, 1.85))
	_add_sparks(gold, 16, 0.3, 1.12, 0.0)

func _build_vesper_art_hit() -> void:
	var azure := _make_material(Color(0.15, 0.78, 1.0, 0.92), 1.65)
	var rose := _make_material(Color(1.0, 0.25, 0.62, 0.82), 1.15)
	var white := _make_material(Color(1.0, 1.0, 0.94, 0.88), 1.2)

	_add_disc(azure, Vector3.ZERO, Vector3(0.32, 1.0, 0.32), Vector3(1.88, 1.0, 1.88))
	_add_disc(rose, Vector3.UP * 0.06, Vector3(0.18, 1.0, 0.18), Vector3(1.32, 1.0, 1.32))
	_add_sphere(white, Vector3.UP * 0.08, Vector3.ONE * 0.68, Vector3.ONE * 0.1)
	_add_bar(white, PI * 0.125, Vector3(0.22, 0.78, 0.78), Vector3(2.0, 1.0, 2.0))
	_add_bar(white, PI * 0.625, Vector3(0.22, 0.78, 0.78), Vector3(2.0, 1.0, 2.0))
	_add_sparks(azure, 18, 0.32, 1.22, 0.05)
	_add_sparks(rose, 10, 0.22, 0.94, 0.24)
func _add_disc(material: StandardMaterial3D, position: Vector3, start_scale: Vector3, end_scale: Vector3) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 1.0
	mesh.bottom_radius = 1.0
	mesh.height = 0.025
	mesh.radial_segments = 40
	_add_part(mesh, material, position, Vector3.ZERO, start_scale, end_scale)

func _add_sphere(material: StandardMaterial3D, position: Vector3, start_scale: Vector3, end_scale: Vector3) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 0.24
	mesh.height = 0.48
	mesh.radial_segments = 16
	mesh.rings = 8
	_add_part(mesh, material, position, Vector3.ZERO, start_scale, end_scale)

func _add_bar(material: StandardMaterial3D, y_rotation: float, start_scale: Vector3, end_scale: Vector3) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.78, 0.035, 0.09)
	_add_part(mesh, material, Vector3.UP * 0.04, Vector3(0.0, y_rotation, 0.0), start_scale, end_scale)

func _add_sparks(material: StandardMaterial3D, count: int, start_radius: float, end_radius: float, angle_offset: float) -> void:
	for index in range(count):
		var angle := TAU * float(index) / float(count) + angle_offset
		var direction := Vector3(sin(angle), 0.0, cos(angle))
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.08, 0.04, 0.42)
		_add_part(
			mesh,
			material,
			direction * start_radius + Vector3.UP * 0.06,
			Vector3(0.0, angle, 0.0),
			Vector3(0.6, 0.8, 0.6),
			Vector3(0.35, 0.8, 1.35),
			direction * end_radius + Vector3.UP * 0.06
		)

func _add_part(
	mesh: Mesh,
	material: StandardMaterial3D,
	position: Vector3,
	rotation_values: Vector3,
	start_scale: Vector3,
	end_scale: Vector3,
	end_position: Variant = null
) -> void:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.position = position
	instance.rotation = rotation_values
	instance.scale = start_scale
	instance.set_surface_override_material(0, material)
	_visual_root.add_child(instance)

	var final_position := position
	if end_position is Vector3:
		final_position = end_position

	_parts.append({
		"node": instance,
		"start_scale": start_scale,
		"end_scale": end_scale,
		"start_position": position,
		"end_position": final_position
	})

func _make_material(color: Color, emission_multiplier: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b, 1.0)
	material.emission_energy_multiplier = emission_multiplier
	_materials.append(material)
	return material

func _update_visual(progress: float) -> void:
	var expand := 1.0 - pow(1.0 - progress, 2.0)
	var fade := pow(1.0 - progress, 1.35)

	for part in _parts:
		var node := part["node"] as Node3D
		if node == null:
			continue

		node.scale = (part["start_scale"] as Vector3).lerp(part["end_scale"] as Vector3, expand)
		node.position = (part["start_position"] as Vector3).lerp(part["end_position"] as Vector3, expand)

	for material in _materials:
		var color := material.albedo_color
		color.a = fade
		material.albedo_color = color
