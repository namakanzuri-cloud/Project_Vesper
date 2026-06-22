extends Camera3D
class_name CameraFollow

@export var target_path: NodePath
@export var target_group: StringName = &"player"
@export var offset: Vector3 = Vector3(0.0, 8.5, 8.5)
@export var follow_sharpness: float = 12.0
@export var look_height: float = 1.1

var _target: Node3D

func _ready() -> void:
	_resolve_target()
	if _target != null:
		global_position = _target.global_position + offset
		look_at(_target.global_position + Vector3.UP * look_height, Vector3.UP)

func _process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_resolve_target()
		if _target == null:
			return

	var desired_position := _target.global_position + offset
	global_position = global_position.lerp(desired_position, 1.0 - exp(-follow_sharpness * delta))
	look_at(_target.global_position + Vector3.UP * look_height, Vector3.UP)

func _resolve_target() -> void:
	if target_path != NodePath(""):
		_target = get_node_or_null(target_path) as Node3D

	if _target == null:
		_target = get_tree().get_first_node_in_group(target_group) as Node3D
