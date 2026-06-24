extends Node3D
class_name CombatHitbox

@export var radius: float = 0.85
@export var vertical_offset: float = 0.35
@export var target_group: StringName = &"enemy"
@export_flags_3d_physics var collision_mask: int = 1
@export var enabled: bool = true
@export var debug_visual_path: NodePath
@export var debug_visible_when_enabled: bool = false

var _debug_visual: Node3D

func _ready() -> void:
	if debug_visual_path != NodePath(""):
		_debug_visual = get_node_or_null(debug_visual_path) as Node3D

	refresh_debug_visual()

func set_enabled(value: bool) -> void:
	enabled = value
	refresh_debug_visual()

func refresh_debug_visual() -> void:
	if _debug_visual == null:
		return

	_debug_visual.visible = debug_visible_when_enabled and enabled
	_debug_visual.position = Vector3.UP * vertical_offset
	_debug_visual.scale = Vector3.ONE * radius

func get_targets(source: Node = null, ignored_targets: Array[Node] = []) -> Array[Node]:
	if not enabled:
		return []

	var sphere := SphereShape3D.new()
	sphere.radius = radius

	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = sphere

	var hit_transform := global_transform
	hit_transform.origin += Vector3.UP * vertical_offset
	query.transform = hit_transform
	query.collision_mask = collision_mask
	query.collide_with_areas = false
	query.collide_with_bodies = true

	if source is CollisionObject3D:
		query.exclude = [(source as CollisionObject3D).get_rid()]

	var hits := get_world_3d().direct_space_state.intersect_shape(query, 16)
	var targets: Array[Node] = []

	for hit in hits:
		var collider := hit.get("collider") as Node
		var target := _find_target_root(collider)
		if target == null or target == source or targets.has(target) or ignored_targets.has(target):
			continue

		targets.append(target)

	return targets

func strike(damage: float, source: Node = null, ignored_targets: Array[Node] = []) -> Array[Node]:
	var damaged: Array[Node] = []

	for target in get_targets(source, ignored_targets):
		var health := target.get_node_or_null("Health")
		if health != null and health.has_method("take_damage"):
			var did_damage := health.take_damage(damage) as bool
			if did_damage:
				damaged.append(target)

	return damaged

func _find_target_root(node: Node) -> Node:
	var current := node
	while current != null:
		if current.is_in_group(target_group) and current.get_node_or_null("Health") != null:
			return current
		current = current.get_parent()

	return null
