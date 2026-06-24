extends Camera3D
class_name CameraFollow

@export var target_path: NodePath
@export var target_group: StringName = &"player"
@export var offset: Vector3 = Vector3(0.0, 8.5, 8.5)
@export var follow_sharpness: float = 12.0
@export var look_height: float = 1.1

@export_group("Shake")
@export var light_attack_shake_strength: float = 0.08
@export var light_attack_shake_duration: float = 0.08
@export var heavy_attack_shake_strength: float = 0.13
@export var heavy_attack_shake_duration: float = 0.11
@export var enemy_attack_shake_strength: float = 0.12
@export var enemy_attack_shake_duration: float = 0.10
@export var shake_decay: float = 1.7
@export var max_shake_strength: float = 0.22

var _target: Node3D
var _follow_position: Vector3 = Vector3.ZERO
var _shake_strength: float = 0.0
var _shake_duration: float = 0.0
var _shake_started_at_usec: int = 0
var _shake_ends_at_usec: int = 0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_resolve_target()
	if _target != null:
		reset_follow()

func _process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_resolve_target()
		if _target == null:
			return

	var desired_position := _target.global_position + offset
	_follow_position = _follow_position.lerp(desired_position, 1.0 - exp(-follow_sharpness * delta))
	global_position = _follow_position
	look_at(_target.global_position + Vector3.UP * look_height, Vector3.UP)
	global_position = _follow_position + _get_shake_offset()

func request_light_attack_shake() -> void:
	request_shake(light_attack_shake_strength, light_attack_shake_duration)

func request_heavy_attack_shake() -> void:
	request_shake(heavy_attack_shake_strength, heavy_attack_shake_duration)

func request_enemy_attack_shake() -> void:
	request_shake(enemy_attack_shake_strength, enemy_attack_shake_duration)

func request_shake(strength: float, duration: float) -> void:
	if strength <= 0.0 or duration <= 0.0:
		return

	var now_usec := Time.get_ticks_usec()
	if _is_shaking(now_usec) and strength < _shake_strength:
		return

	_shake_strength = minf(strength, max_shake_strength)
	_shake_duration = duration
	_shake_started_at_usec = now_usec
	_shake_ends_at_usec = now_usec + int(duration * 1000000.0)

func cancel_shake() -> void:
	_shake_strength = 0.0
	_shake_duration = 0.0
	_shake_started_at_usec = 0
	_shake_ends_at_usec = 0

func reset_follow() -> void:
	cancel_shake()
	_resolve_target()
	if _target == null:
		return

	_follow_position = _target.global_position + offset
	global_position = _follow_position
	look_at(_target.global_position + Vector3.UP * look_height, Vector3.UP)

func _resolve_target() -> void:
	if target_path != NodePath(""):
		_target = get_node_or_null(target_path) as Node3D

	if _target == null:
		_target = get_tree().get_first_node_in_group(target_group) as Node3D

func _get_shake_offset() -> Vector3:
	var now_usec := Time.get_ticks_usec()
	if not _is_shaking(now_usec):
		cancel_shake()
		return Vector3.ZERO

	var elapsed := float(now_usec - _shake_started_at_usec) / 1000000.0
	var progress := clampf(elapsed / maxf(_shake_duration, 0.001), 0.0, 1.0)
	var decay := pow(1.0 - progress, maxf(shake_decay, 0.01))
	var amplitude := _shake_strength * decay
	var local_offset := Vector2(
		_rng.randf_range(-amplitude, amplitude),
		_rng.randf_range(-amplitude, amplitude)
	)

	return global_transform.basis.x * local_offset.x + global_transform.basis.y * local_offset.y

func _is_shaking(now_usec: int) -> bool:
	return _shake_ends_at_usec > 0 and now_usec < _shake_ends_at_usec
