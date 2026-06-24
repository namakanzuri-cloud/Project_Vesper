extends CharacterBody3D
class_name PlayerController

enum AttackPhase { NONE, WINDUP, ACTIVE, RECOVERY }

@export_group("Movement")
@export var move_speed: float = 6.0
@export var rotation_speed: float = 16.0
@export var camera_relative_movement: bool = true

@export_group("Dodge")
@export var dodge_speed: float = 15.0
@export var dodge_duration: float = 0.18
@export var dodge_stamina_cost: float = 24.0

@export_group("Light Attack")
@export var light_attack_damage: float = 18.0
@export var light_attack_range: float = 1.65
@export var light_attack_radius: float = 0.9
@export var light_attack_stamina_cost: float = 12.0
@export var light_attack_windup: float = 0.12
@export var light_attack_active: float = 0.14
@export var light_attack_recovery: float = 0.22

@export_group("Heavy Attack")
@export var heavy_attack_damage: float = 46.0
@export var heavy_attack_range: float = 2.05
@export var heavy_attack_radius: float = 1.05
@export var heavy_attack_stamina_cost: float = 30.0
@export var heavy_attack_windup: float = 0.38
@export var heavy_attack_active: float = 0.18
@export var heavy_attack_recovery: float = 0.55

@export_group("Attack Movement")
@export_range(0.0, 1.0, 0.05) var attack_windup_move_speed_multiplier: float = 0.35
@export_range(0.0, 1.0, 0.05) var attack_active_move_speed_multiplier: float = 0.2
@export_range(0.0, 1.0, 0.05) var attack_recovery_move_speed_multiplier: float = 0.45

@export_group("Debug")
@export var debug_attack_state_colors: bool = true
@export var debug_attack_hitbox: bool = true
@export var idle_body_color: Color = Color(0.2, 0.62, 1.0, 1.0)
@export var windup_body_color: Color = Color(1.0, 0.86, 0.18, 1.0)
@export var active_body_color: Color = Color(0.25, 1.0, 0.45, 1.0)
@export var recovery_body_color: Color = Color(0.85, 0.35, 1.0, 1.0)

@export_group("Collision")
@export_flags_3d_physics var enemy_collision_mask: int = 4

@export_group("Hit Stop")
@export var hit_stop_path: NodePath

@export_group("Camera Shake")
@export var camera_follow_path: NodePath

@export_group("Hit VFX")
@export var hit_vfx_scene: PackedScene = preload("res://scenes/HitVfx.tscn")
@export var light_hit_vfx_scale: float = 0.85
@export var heavy_hit_vfx_scale: float = 1.25
@export var hit_vfx_lifetime: float = 0.22
@export var hit_vfx_vertical_offset: float = 0.85

@onready var health: Health = $Health
@onready var stamina: Stamina = $Stamina
@onready var attack_hitbox: CombatHitbox = $AttackHitbox
@onready var body_mesh: MeshInstance3D = $Body

var _move_direction: Vector3 = Vector3.ZERO
var _last_facing: Vector3 = Vector3.FORWARD
var _dodge_direction: Vector3 = Vector3.ZERO
var _dodge_remaining: float = 0.0
var _attack_phase: int = AttackPhase.NONE
var _attack_phase_remaining: float = 0.0
var _current_attack_name: StringName = &""
var _current_attack_damage: float = 0.0
var _current_attack_range: float = 0.0
var _current_attack_radius: float = 0.0
var _current_attack_active: float = 0.0
var _current_attack_recovery: float = 0.0
var _attack_direction: Vector3 = Vector3.FORWARD
var _attack_damaged_targets: Array[Node] = []
var _body_material: StandardMaterial3D
var _controls_enabled: bool = true
var _hit_stop
var _camera_follow: CameraFollow

func _ready() -> void:
	_resolve_hit_stop()
	_resolve_camera_follow()
	_setup_body_material()
	_set_attack_hitbox_enabled(false)
	_apply_attack_debug_color()

func _physics_process(delta: float) -> void:
	if health.is_dead() or not _controls_enabled:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	_read_movement_input()
	_handle_actions()
	_update_attack_state(delta)
	_rotate_toward_facing(delta)
	_move_player(delta)

func _read_movement_input() -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward := Vector3.FORWARD
	var right := Vector3.RIGHT

	if camera_relative_movement:
		var camera := get_viewport().get_camera_3d()
		if camera != null:
			forward = -camera.global_transform.basis.z
			right = camera.global_transform.basis.x
			forward.y = 0.0
			right.y = 0.0
			forward = forward.normalized()
			right = right.normalized()

	_move_direction = (right * input_vector.x + forward * -input_vector.y).normalized()
	if not _is_attacking() and _move_direction.length_squared() > 0.001:
		_last_facing = _move_direction

func _handle_actions() -> void:
	if Input.is_action_just_pressed("dodge"):
		_try_dodge()

	if Input.is_action_just_pressed("light_attack"):
		_try_attack(
			&"light",
			light_attack_damage,
			light_attack_range,
			light_attack_radius,
			light_attack_stamina_cost,
			light_attack_windup,
			light_attack_active,
			light_attack_recovery
		)

	if Input.is_action_just_pressed("heavy_attack"):
		_try_attack(
			&"heavy",
			heavy_attack_damage,
			heavy_attack_range,
			heavy_attack_radius,
			heavy_attack_stamina_cost,
			heavy_attack_windup,
			heavy_attack_active,
			heavy_attack_recovery
		)

func _update_attack_state(delta: float) -> void:
	if not _is_attacking():
		return

	if _attack_phase == AttackPhase.ACTIVE:
		_strike_active_attack_targets()

	_attack_phase_remaining -= delta
	while _is_attacking() and _attack_phase_remaining <= 0.0:
		_advance_attack_phase()

func _advance_attack_phase() -> void:
	match _attack_phase:
		AttackPhase.WINDUP:
			_enter_attack_phase(AttackPhase.ACTIVE, _current_attack_active)
		AttackPhase.ACTIVE:
			_enter_attack_phase(AttackPhase.RECOVERY, _current_attack_recovery)
		AttackPhase.RECOVERY:
			_clear_attack_state()
		_:
			_clear_attack_state()

func _rotate_toward_facing(delta: float) -> void:
	if _last_facing.length_squared() <= 0.001:
		return

	var target_yaw := atan2(-_last_facing.x, -_last_facing.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, 1.0 - exp(-rotation_speed * delta))

func _move_player(delta: float) -> void:
	if _dodge_remaining > 0.0:
		_dodge_remaining = maxf(0.0, _dodge_remaining - delta)
		velocity.x = _dodge_direction.x * dodge_speed
		velocity.z = _dodge_direction.z * dodge_speed
	else:
		var speed_multiplier := _get_attack_move_speed_multiplier() if _is_attacking() else 1.0
		velocity.x = _move_direction.x * move_speed * speed_multiplier
		velocity.z = _move_direction.z * move_speed * speed_multiplier

	velocity.y = 0.0
	move_and_slide()

func _try_dodge() -> void:
	if _is_attacking() or _dodge_remaining > 0.0 or not stamina.try_spend(dodge_stamina_cost):
		return

	_dodge_direction = _move_direction if _move_direction.length_squared() > 0.001 else _last_facing
	_dodge_direction = _dodge_direction.normalized()
	_dodge_remaining = dodge_duration

func _try_attack(attack_name: StringName, damage: float, attack_range: float, attack_radius: float, stamina_cost: float, windup: float, active: float, recovery: float) -> void:
	if _is_attacking() or _dodge_remaining > 0.0 or not stamina.try_spend(stamina_cost):
		return

	_current_attack_name = attack_name
	_current_attack_damage = damage
	_current_attack_range = attack_range
	_current_attack_radius = attack_radius
	_current_attack_active = active
	_current_attack_recovery = recovery
	_attack_direction = _get_locked_attack_direction()
	_attack_damaged_targets.clear()
	_last_facing = _attack_direction
	rotation.y = atan2(-_attack_direction.x, -_attack_direction.z)

	_enter_attack_phase(AttackPhase.WINDUP, windup)
	if active <= 0.0 and windup <= 0.0 and recovery <= 0.0:
		_clear_attack_state()

func _enter_attack_phase(phase: int, duration: float) -> void:
	_attack_phase = phase
	_attack_phase_remaining = maxf(0.0, duration)
	_set_attack_hitbox_enabled(_attack_phase == AttackPhase.ACTIVE)
	_apply_attack_debug_color()

	if _attack_phase == AttackPhase.ACTIVE:
		_strike_active_attack_targets()

func _strike_active_attack_targets() -> void:
	attack_hitbox.global_position = global_position + _attack_direction * _current_attack_range
	attack_hitbox.radius = _current_attack_radius
	attack_hitbox.target_group = &"enemy"
	attack_hitbox.collision_mask = enemy_collision_mask
	attack_hitbox.refresh_debug_visual()

	var damaged := attack_hitbox.strike(_current_attack_damage, self, _attack_damaged_targets)
	for target in damaged:
		if not _attack_damaged_targets.has(target):
			_attack_damaged_targets.append(target)
			_spawn_hit_vfx_for_target(target)

	if not damaged.is_empty():
		_request_hit_stop_for_current_attack()
		_request_camera_shake_for_current_attack()

func _spawn_hit_vfx_for_target(target: Node) -> void:
	if hit_vfx_scene == null:
		return

	var target_3d := target as Node3D
	if target_3d == null:
		return

	var hit_vfx := hit_vfx_scene.instantiate() as HitVfx
	if hit_vfx == null:
		return

	var kind := HitVfx.HitKind.LIGHT
	var scale := light_hit_vfx_scale
	if _current_attack_name == &"heavy":
		kind = HitVfx.HitKind.HEAVY
		scale = heavy_hit_vfx_scale

	hit_vfx.configure(kind, scale, hit_vfx_lifetime)

	var parent := get_tree().current_scene
	if parent == null:
		parent = get_parent()
	if parent == null:
		hit_vfx.queue_free()
		return

	parent.add_child(hit_vfx)
	hit_vfx.global_position = target_3d.global_position + Vector3.UP * hit_vfx_vertical_offset

func _clear_attack_state() -> void:
	_attack_phase = AttackPhase.NONE
	_attack_phase_remaining = 0.0
	_current_attack_name = &""
	_current_attack_damage = 0.0
	_current_attack_range = 0.0
	_current_attack_radius = 0.0
	_current_attack_active = 0.0
	_current_attack_recovery = 0.0
	_attack_damaged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_apply_attack_debug_color()

func _get_locked_attack_direction() -> Vector3:
	var direction := _move_direction if _move_direction.length_squared() > 0.001 else _last_facing
	if direction.length_squared() <= 0.001:
		direction = Vector3.FORWARD

	return direction.normalized()


func _resolve_hit_stop() -> void:
	if hit_stop_path != NodePath(""):
		_hit_stop = get_node_or_null(hit_stop_path)

	if _hit_stop == null:
		_hit_stop = get_tree().get_first_node_in_group(&"hit_stop")

func _request_hit_stop_for_current_attack() -> void:
	if _hit_stop == null or not is_instance_valid(_hit_stop):
		_resolve_hit_stop()

	if _hit_stop == null:
		return

	match _current_attack_name:
		&"heavy":
			_hit_stop.request_heavy_attack_hit_stop()
		_:
			_hit_stop.request_light_attack_hit_stop()

func _resolve_camera_follow() -> void:
	if camera_follow_path != NodePath(""):
		_camera_follow = get_node_or_null(camera_follow_path) as CameraFollow

	if _camera_follow == null:
		_camera_follow = get_viewport().get_camera_3d() as CameraFollow

func _request_camera_shake_for_current_attack() -> void:
	if _camera_follow == null or not is_instance_valid(_camera_follow):
		_resolve_camera_follow()

	if _camera_follow == null:
		return

	match _current_attack_name:
		&"heavy":
			_camera_follow.request_heavy_attack_shake()
		_:
			_camera_follow.request_light_attack_shake()

func _set_attack_hitbox_enabled(value: bool) -> void:
	if attack_hitbox == null:
		return

	attack_hitbox.debug_visible_when_enabled = debug_attack_hitbox
	attack_hitbox.set_enabled(value)

func _get_attack_move_speed_multiplier() -> float:
	match _attack_phase:
		AttackPhase.WINDUP:
			return attack_windup_move_speed_multiplier
		AttackPhase.ACTIVE:
			return attack_active_move_speed_multiplier
		AttackPhase.RECOVERY:
			return attack_recovery_move_speed_multiplier
		_:
			return 1.0

func _is_attacking() -> bool:
	return _attack_phase != AttackPhase.NONE

func _setup_body_material() -> void:
	if body_mesh == null:
		return

	var material := body_mesh.get_active_material(0)
	if material is StandardMaterial3D:
		_body_material = (material as StandardMaterial3D).duplicate() as StandardMaterial3D
		body_mesh.set_surface_override_material(0, _body_material)

func _apply_attack_debug_color() -> void:
	if not debug_attack_state_colors or _body_material == null:
		return

	match _attack_phase:
		AttackPhase.WINDUP:
			_body_material.albedo_color = windup_body_color
		AttackPhase.ACTIVE:
			_body_material.albedo_color = active_body_color
		AttackPhase.RECOVERY:
			_body_material.albedo_color = recovery_body_color
		_:
			_body_material.albedo_color = idle_body_color

func set_control_enabled(value: bool) -> void:
	_controls_enabled = value
	if not _controls_enabled:
		_move_direction = Vector3.ZERO
		_dodge_direction = Vector3.ZERO
		_dodge_remaining = 0.0
		velocity = Vector3.ZERO
		_clear_attack_state()

func reset_combat_state() -> void:
	_controls_enabled = true
	velocity = Vector3.ZERO
	_move_direction = Vector3.ZERO
	_last_facing = Vector3.FORWARD
	_dodge_direction = Vector3.ZERO
	_dodge_remaining = 0.0
	_attack_direction = Vector3.FORWARD
	_clear_attack_state()
