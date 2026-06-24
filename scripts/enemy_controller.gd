extends CharacterBody3D
class_name EnemyController

enum EnemyState { CHASE, TELEGRAPH, ACTIVE, RECOVERY, DEAD }

@export var target_path: NodePath
@export var target_group: StringName = &"player"

@export_group("Movement")
@export var move_speed: float = 3.4
@export var rotation_speed: float = 12.0

@export_group("Attack")
@export var attack_range: float = 1.45
@export var attack_radius: float = 0.75
@export var attack_damage: float = 12.0
@export var attack_telegraph_time: float = 0.45
@export var attack_active_time: float = 0.14
@export var attack_recovery_time: float = 0.45
@export var attack_cooldown: float = 0.15

@export_group("Collision")
@export_flags_3d_physics var player_collision_mask: int = 2

@export_group("Hit Stop")
@export var hit_stop_path: NodePath

@export_group("Camera Shake")
@export var camera_follow_path: NodePath

@export_group("Hit VFX")
@export var hit_vfx_scene: PackedScene = preload("res://scenes/HitVfx.tscn")
@export var enemy_hit_vfx_scale: float = 1.05
@export var hit_vfx_lifetime: float = 0.22
@export var hit_vfx_vertical_offset: float = 0.85

@onready var health: Health = $Health
@onready var attack_hitbox: CombatHitbox = $AttackHitbox
@onready var attack_telegraph: Node3D = get_node_or_null("AttackTelegraph") as Node3D

var _target: Node3D
var _state: int = EnemyState.CHASE
var _state_time_remaining: float = 0.0
var _attack_cooldown_remaining: float = 0.0
var _attack_direction: Vector3 = Vector3.FORWARD
var _attack_damaged_targets: Array[Node] = []
var _ai_enabled: bool = true
var _hit_stop
var _camera_follow: CameraFollow

func _ready() -> void:
	_resolve_hit_stop()
	_resolve_camera_follow()
	_resolve_target()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()

func _physics_process(delta: float) -> void:
	if not _ai_enabled:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if health.is_dead():
		_enter_dead_state()
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if _target == null or not is_instance_valid(_target):
		_resolve_target()
		if _target == null:
			return

	_attack_cooldown_remaining = maxf(0.0, _attack_cooldown_remaining - delta)

	match _state:
		EnemyState.CHASE:
			_update_chase(delta)
		EnemyState.TELEGRAPH:
			_update_telegraph(delta)
		EnemyState.ACTIVE:
			_update_active_attack(delta)
		EnemyState.RECOVERY:
			_update_recovery(delta)
		EnemyState.DEAD:
			velocity = Vector3.ZERO

	velocity.y = 0.0
	move_and_slide()

func _update_chase(delta: float) -> void:
	var to_target := _get_flat_to_target()

	if to_target.length_squared() <= 0.001:
		velocity = Vector3.ZERO
		return

	var direction := to_target.normalized()
	_rotate_toward(direction, delta)

	var distance := to_target.length()
	if distance > _get_attack_start_range():
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		if _attack_cooldown_remaining <= 0.0:
			_start_attack(direction)

func _update_telegraph(delta: float) -> void:
	velocity = Vector3.ZERO
	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_enter_active_attack()

func _update_active_attack(delta: float) -> void:
	velocity = Vector3.ZERO
	_strike_active_attack_targets()
	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_enter_recovery()

func _update_recovery(delta: float) -> void:
	velocity = Vector3.ZERO
	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_state = EnemyState.CHASE

func _resolve_target() -> void:
	if target_path != NodePath(""):
		_target = get_node_or_null(target_path) as Node3D

	if _target == null:
		_target = get_tree().get_first_node_in_group(target_group) as Node3D

func _rotate_toward(direction: Vector3, delta: float) -> void:
	var target_yaw := atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, 1.0 - exp(-rotation_speed * delta))

func _face_direction(direction: Vector3) -> void:
	if direction.length_squared() <= 0.001:
		return

	rotation.y = atan2(-direction.x, -direction.z)

func _start_attack(direction: Vector3) -> void:
	_attack_direction = direction.normalized()
	if _attack_direction.length_squared() <= 0.001:
		_attack_direction = -global_transform.basis.z.normalized()

	_face_direction(_attack_direction)
	_state = EnemyState.TELEGRAPH
	_state_time_remaining = maxf(0.0, attack_telegraph_time)
	_attack_damaged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_show_attack_telegraph()

	if _state_time_remaining <= 0.0:
		_enter_active_attack()

func _enter_active_attack() -> void:
	_state = EnemyState.ACTIVE
	_state_time_remaining = maxf(0.0, attack_active_time)
	_hide_attack_telegraph()
	_set_attack_hitbox_enabled(true)
	_strike_active_attack_targets()

	if _state_time_remaining <= 0.0:
		_enter_recovery()

func _enter_recovery() -> void:
	_state = EnemyState.RECOVERY
	_state_time_remaining = maxf(0.0, attack_recovery_time)
	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining, attack_cooldown)
	_attack_damaged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()

	if _state_time_remaining <= 0.0:
		_state = EnemyState.CHASE

func _strike_active_attack_targets() -> void:
	attack_hitbox.global_position = global_position + _attack_direction * attack_range
	attack_hitbox.radius = attack_radius
	attack_hitbox.target_group = &"player"
	attack_hitbox.collision_mask = player_collision_mask
	attack_hitbox.refresh_debug_visual()

	var damaged := attack_hitbox.strike(attack_damage, self, _attack_damaged_targets)
	for target in damaged:
		if not _attack_damaged_targets.has(target):
			_attack_damaged_targets.append(target)
			_spawn_hit_vfx_for_target(target)

	if not damaged.is_empty():
		_request_enemy_hit_stop()
		_request_enemy_camera_shake()

func _spawn_hit_vfx_for_target(target: Node) -> void:
	if hit_vfx_scene == null:
		return

	var target_3d := target as Node3D
	if target_3d == null:
		return

	var hit_vfx := hit_vfx_scene.instantiate() as HitVfx
	if hit_vfx == null:
		return

	hit_vfx.configure(HitVfx.HitKind.ENEMY, enemy_hit_vfx_scale, hit_vfx_lifetime)

	var parent := get_tree().current_scene
	if parent == null:
		parent = get_parent()
	if parent == null:
		hit_vfx.queue_free()
		return

	parent.add_child(hit_vfx)
	hit_vfx.global_position = target_3d.global_position + Vector3.UP * hit_vfx_vertical_offset

func _show_attack_telegraph() -> void:
	if attack_telegraph == null:
		return

	var telegraph_position := global_position + _attack_direction * attack_range
	telegraph_position.y = global_position.y + 0.03
	attack_telegraph.global_position = telegraph_position
	attack_telegraph.scale = Vector3(attack_radius, 1.0, attack_radius)
	attack_telegraph.visible = true

func _hide_attack_telegraph() -> void:
	if attack_telegraph == null:
		return

	attack_telegraph.visible = false

func _set_attack_hitbox_enabled(value: bool) -> void:
	if attack_hitbox == null:
		return

	attack_hitbox.set_enabled(value)

func _resolve_hit_stop() -> void:
	if hit_stop_path != NodePath(""):
		_hit_stop = get_node_or_null(hit_stop_path)

	if _hit_stop == null:
		_hit_stop = get_tree().get_first_node_in_group(&"hit_stop")

func _request_enemy_hit_stop() -> void:
	if _hit_stop == null or not is_instance_valid(_hit_stop):
		_resolve_hit_stop()

	if _hit_stop == null:
		return

	_hit_stop.request_enemy_attack_hit_stop()

func _resolve_camera_follow() -> void:
	if camera_follow_path != NodePath(""):
		_camera_follow = get_node_or_null(camera_follow_path) as CameraFollow

	if _camera_follow == null:
		_camera_follow = get_viewport().get_camera_3d() as CameraFollow

func _request_enemy_camera_shake() -> void:
	if _camera_follow == null or not is_instance_valid(_camera_follow):
		_resolve_camera_follow()

	if _camera_follow == null:
		return

	_camera_follow.request_enemy_attack_shake()

func _enter_dead_state() -> void:
	if _state == EnemyState.DEAD:
		return

	_state = EnemyState.DEAD
	_state_time_remaining = 0.0
	_attack_damaged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()

func _get_attack_start_range() -> float:
	return attack_range + attack_radius

func _get_flat_to_target() -> Vector3:
	if _target == null:
		return Vector3.ZERO

	var to_target := _target.global_position - global_position
	to_target.y = 0.0
	return to_target

func set_ai_enabled(value: bool) -> void:
	_ai_enabled = value
	if not _ai_enabled:
		velocity = Vector3.ZERO
		_state_time_remaining = 0.0
		_attack_cooldown_remaining = 0.0
		_attack_damaged_targets.clear()
		_set_attack_hitbox_enabled(false)
		_hide_attack_telegraph()
		if health.is_dead():
			_state = EnemyState.DEAD

func reset_combat_state() -> void:
	_ai_enabled = true
	velocity = Vector3.ZERO
	_state = EnemyState.CHASE
	_state_time_remaining = 0.0
	_attack_cooldown_remaining = 0.0
	_attack_direction = Vector3.FORWARD
	_attack_damaged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	_resolve_target()
