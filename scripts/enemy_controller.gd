extends CharacterBody3D
class_name EnemyController

enum EnemyState { CHASE, TELEGRAPH, ACTIVE, RECOVERY, PATTERN_GAP, PATTERN_RECOVERY, STUNNED, DEAD }
enum AttackType { FAST_SLASH, DELAYED_HEAVY, GRAB, ARMOR_SLAM, RETREAT_SLASH }
enum AttackPattern { FAST_COMBO, GRAB_MIX, HEAVY_BAIT, SIMPLE_PRESSURE, ARMOR_CHECK, PRESSURE_INTO_SLAM, BAIT_RETREAT, SLASH_SLAM_MIX }

@export var target_path: NodePath
@export var target_group: StringName = &"player"

@export_group("Movement")
@export var move_speed: float = 3.4
@export var rotation_speed: float = 12.0

@export_group("Attack Selection")
@export var attack_cooldown: float = 0.15
@export var debug_log_attack_types: bool = false
@export var debug_log_attack_patterns: bool = false

@export_group("Attack Patterns")
@export var fast_combo_weight: float = 3.0
@export var grab_mix_weight: float = 2.2
@export var heavy_bait_weight: float = 2.4
@export var simple_pressure_weight: float = 3.2
@export var armor_check_weight: float = 2.0
@export var pressure_into_slam_weight: float = 1.8
@export var bait_retreat_weight: float = 1.8
@export var slash_slam_mix_weight: float = 1.6
@export var fast_combo_step_interval: float = 0.14
@export var grab_mix_step_interval: float = 0.18
@export var heavy_bait_step_interval: float = 0.0
@export var simple_pressure_step_interval: float = 0.13
@export var armor_check_step_interval: float = 0.0
@export var pressure_into_slam_step_interval: float = 0.16
@export var bait_retreat_step_interval: float = 0.0
@export var slash_slam_mix_step_interval: float = 0.18
@export var pattern_end_recovery_time: float = 0.42
@export var pattern_abort_distance: float = 4.2

@export_group("Fast Slash")
@export var fast_slash_range: float = 1.35
@export var fast_slash_radius: float = 0.68
@export var fast_slash_damage: float = 11.0
@export var fast_slash_telegraph_time: float = 0.36
@export var fast_slash_active_time: float = 0.12
@export var fast_slash_recovery_time: float = 0.34
@export var fast_slash_parryable: bool = true
@export var fast_slash_interruptible: bool = false
@export var fast_slash_interrupt_window_start: float = 0.0
@export var fast_slash_interrupt_window_end: float = 0.0
@export var fast_slash_interrupt_requires_heavy: bool = false
@export var fast_slash_interrupt_stun_duration: float = 0.62
@export var fast_slash_telegraph_color: Color = Color(1.0, 0.08, 0.04, 0.42)

@export_group("Delayed Heavy Slash")
@export var delayed_heavy_range: float = 1.65
@export var delayed_heavy_radius: float = 0.92
@export var delayed_heavy_damage: float = 24.0
@export var delayed_heavy_telegraph_time: float = 1.05
@export var delayed_heavy_active_time: float = 0.18
@export var delayed_heavy_recovery_time: float = 0.68
@export var delayed_heavy_parryable: bool = true
@export var delayed_heavy_interruptible: bool = true
@export var delayed_heavy_interrupt_window_start: float = 0.35
@export var delayed_heavy_interrupt_window_end: float = 1.0
@export var delayed_heavy_interrupt_requires_heavy: bool = false
@export var delayed_heavy_interrupt_stun_duration: float = 0.62
@export var delayed_heavy_telegraph_color: Color = Color(1.0, 0.34, 0.02, 0.5)

@export_group("Grab")
@export var grab_range: float = 1.05
@export var grab_radius: float = 0.62
@export var grab_damage: float = 20.0
@export var grab_telegraph_time: float = 0.7
@export var grab_active_time: float = 0.18
@export var grab_recovery_time: float = 0.56
@export var grab_parryable: bool = false
@export var grab_interruptible: bool = false
@export var grab_interrupt_window_start: float = 0.0
@export var grab_interrupt_window_end: float = 0.0
@export var grab_interrupt_requires_heavy: bool = false
@export var grab_interrupt_stun_duration: float = 0.62
@export var grab_telegraph_color: Color = Color(0.7, 0.05, 1.0, 0.45)

@export_group("Armor Slam")
@export var armor_slam_range: float = 1.55
@export var armor_slam_radius: float = 1.18
@export var armor_slam_damage: float = 32.0
@export var armor_slam_telegraph_time: float = 1.25
@export var armor_slam_active_time: float = 0.2
@export var armor_slam_recovery_time: float = 0.92
@export var armor_slam_parryable: bool = false
@export var armor_slam_interruptible: bool = false
@export var armor_slam_interrupt_window_start: float = 0.0
@export var armor_slam_interrupt_window_end: float = 0.0
@export var armor_slam_interrupt_requires_heavy: bool = true
@export var armor_slam_interrupt_stun_duration: float = 0.62
@export var armor_slam_telegraph_color: Color = Color(1.0, 0.74, 0.08, 0.58)
@export var armor_slam_body_color: Color = Color(1.0, 0.58, 0.08, 1.0)
@export var armor_slam_body_scale: float = 1.12
@export var armor_slam_hit_vfx_scale: float = 1.35
@export var armor_slam_hit_stop_duration: float = 0.1
@export var armor_slam_camera_shake_strength: float = 0.2
@export var armor_slam_camera_shake_duration: float = 0.16

@export_group("Retreat Slash")
@export var retreat_slash_range: float = 2.35
@export var retreat_slash_radius: float = 1.15
@export var retreat_slash_damage: float = 14.0
@export var retreat_slash_telegraph_time: float = 0.58
@export var retreat_slash_active_time: float = 0.13
@export var retreat_slash_recovery_time: float = 0.42
@export var retreat_slash_parryable: bool = true
@export var retreat_slash_interruptible: bool = false
@export var retreat_slash_interrupt_window_start: float = 0.0
@export var retreat_slash_interrupt_window_end: float = 0.0
@export var retreat_slash_interrupt_requires_heavy: bool = false
@export var retreat_slash_interrupt_stun_duration: float = 0.62
@export var retreat_slash_telegraph_color: Color = Color(0.08, 0.82, 1.0, 0.42)
@export var retreat_slash_retreat_distance: float = 0.35
@export var retreat_slash_retreat_duration: float = 0.22

@export_group("Interrupt")
@export var interrupt_stun_time: float = 0.62
@export var interrupt_message: String = "INTERRUPT!"
@export var interrupt_message_duration: float = 0.65
@export var interrupt_hit_stop_duration: float = 0.08
@export var interrupt_camera_shake_strength: float = 0.13
@export var interrupt_camera_shake_duration: float = 0.1

@export_group("Pose")
@export var pose_tween_time: float = 0.08

@export_group("Collision")
@export_flags_3d_physics var player_collision_mask: int = 2

@export_group("Hit Stop")
@export var hit_stop_path: NodePath

@export_group("Camera Shake")
@export var camera_follow_path: NodePath

@export_group("Combo")
@export var combo_tracker_path: NodePath

@export_group("Flow")
@export var flow_tracker_path: NodePath

@export_group("UI")
@export var combat_ui_path: NodePath

@export_group("Hit VFX")
@export var hit_vfx_scene: PackedScene = preload("res://scenes/HitVfx.tscn")
@export var enemy_hit_vfx_scale: float = 1.05
@export var hit_vfx_lifetime: float = 0.22
@export var hit_vfx_vertical_offset: float = 0.85

@export_group("Debug")
@export var normal_body_color: Color = Color(1.0, 0.25, 0.2, 1.0)
@export var stunned_body_color: Color = Color(0.35, 0.75, 1.0, 1.0)

@onready var health: Health = $Health
@onready var attack_hitbox: CombatHitbox = $AttackHitbox
@onready var body_mesh: MeshInstance3D = $Body
@onready var attack_telegraph: Node3D = get_node_or_null("AttackTelegraph") as Node3D
@onready var right_arm: Node3D = get_node_or_null("AttackPoseRig/RightArm") as Node3D
@onready var left_arm: Node3D = get_node_or_null("AttackPoseRig/LeftArm") as Node3D
@onready var weapon: Node3D = get_node_or_null("AttackPoseRig/Weapon") as Node3D

var _target: Node3D
var _state: int = EnemyState.CHASE
var _state_time_remaining: float = 0.0
var _attack_cooldown_remaining: float = 0.0
var _attack_direction: Vector3 = Vector3.FORWARD
var _current_attack_type: int = AttackType.FAST_SLASH
var _current_attack_pattern: int = AttackPattern.SIMPLE_PRESSURE
var _current_attack_telegraph_elapsed: float = 0.0
var _retreat_distance_remaining: float = 0.0
var _pattern_steps: Array[int] = []
var _pattern_step_index: int = 0
var _pattern_active: bool = false
var _attack_damaged_targets: Array[Node] = []
var _just_dodged_targets: Array[Node] = []
var _ai_enabled: bool = true
var _body_material: StandardMaterial3D
var _telegraph_material: StandardMaterial3D
var _hit_stop
var _camera_follow: CameraFollow
var _combo_tracker: ComboTracker
var _flow_tracker: FlowTracker
var _combat_ui: CombatUI
var _pose_tween: Tween
var _body_base_scale: Vector3 = Vector3.ONE

func _ready() -> void:
	_resolve_hit_stop()
	_resolve_camera_follow()
	_resolve_combo_tracker()
	_resolve_flow_tracker()
	_resolve_combat_ui()
	_resolve_target()
	_setup_body_material()
	_setup_telegraph_material()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(false)

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
		EnemyState.PATTERN_GAP:
			_update_pattern_gap(delta)
		EnemyState.PATTERN_RECOVERY:
			_update_pattern_recovery(delta)
		EnemyState.STUNNED:
			_update_stunned(delta)
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
			_start_attack_pattern(distance)

func _update_telegraph(delta: float) -> void:
	_current_attack_telegraph_elapsed += delta
	_update_telegraph_movement(delta)
	_update_attack_telegraph_transform()
	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_enter_active_attack()

func _update_telegraph_movement(delta: float) -> void:
	velocity = Vector3.ZERO
	if _current_attack_type != AttackType.RETREAT_SLASH:
		return
	if retreat_slash_retreat_duration <= 0.0 or _retreat_distance_remaining <= 0.0:
		return

	var retreat_speed := retreat_slash_retreat_distance / retreat_slash_retreat_duration
	var retreat_step := minf(_retreat_distance_remaining, retreat_speed * delta)
	_retreat_distance_remaining -= retreat_step
	var retreat_direction := -_attack_direction
	velocity.x = retreat_direction.x * retreat_step / maxf(delta, 0.001)
	velocity.z = retreat_direction.z * retreat_step / maxf(delta, 0.001)

func _update_active_attack(delta: float) -> void:
	velocity = Vector3.ZERO
	_strike_active_attack_targets()
	if _state != EnemyState.ACTIVE:
		return

	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_enter_recovery()

func _update_recovery(delta: float) -> void:
	velocity = Vector3.ZERO
	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_finish_attack_recovery()

func _update_pattern_gap(delta: float) -> void:
	velocity = Vector3.ZERO
	if not _pattern_active:
		_state = EnemyState.CHASE
		_apply_body_debug_color()
		return

	if _should_abort_pattern_for_distance():
		_abort_pattern_to_chase()
		return

	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_start_current_pattern_step()

func _update_pattern_recovery(delta: float) -> void:
	velocity = Vector3.ZERO
	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_clear_attack_pattern_state()
		_state = EnemyState.CHASE
		_apply_body_debug_color()

func _update_stunned(delta: float) -> void:
	velocity = Vector3.ZERO
	_state_time_remaining -= delta
	if _state_time_remaining <= 0.0:
		_state = EnemyState.CHASE
		_apply_body_debug_color()

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

func _start_attack_pattern(distance_to_target: float) -> void:
	_current_attack_pattern = _select_attack_pattern(distance_to_target)
	_pattern_steps = _get_pattern_steps(_current_attack_pattern)
	_pattern_step_index = 0
	_pattern_active = true

	if debug_log_attack_patterns:
		print("Enemy pattern: %s" % _get_attack_pattern_name(_current_attack_pattern))

	_start_current_pattern_step()

func _start_current_pattern_step() -> void:
	if not _pattern_active:
		_state = EnemyState.CHASE
		_apply_body_debug_color()
		return

	if _pattern_step_index >= _pattern_steps.size():
		_enter_pattern_recovery()
		return

	if _should_abort_pattern_for_distance():
		_abort_pattern_to_chase()
		return

	var direction := _get_flat_to_target()
	if direction.length_squared() > 0.001:
		direction = direction.normalized()
	else:
		direction = -global_transform.basis.z.normalized()

	_start_attack_step(_pattern_steps[_pattern_step_index], direction)

func _start_attack_step(attack_type: int, direction: Vector3) -> void:
	_current_attack_type = attack_type
	_attack_direction = direction.normalized()
	if _attack_direction.length_squared() <= 0.001:
		_attack_direction = -global_transform.basis.z.normalized()

	_face_direction(_attack_direction)
	_state = EnemyState.TELEGRAPH
	_state_time_remaining = maxf(0.0, _get_current_attack_telegraph_time())
	_current_attack_telegraph_elapsed = 0.0
	_retreat_distance_remaining = retreat_slash_retreat_distance if _current_attack_type == AttackType.RETREAT_SLASH else 0.0
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_set_attack_pose(_current_attack_type, false)
	_apply_body_debug_color()
	_show_attack_telegraph()

	if debug_log_attack_types:
		print("Enemy attack: %s" % _get_attack_type_name(_current_attack_type))

	if _state_time_remaining <= 0.0:
		_enter_active_attack()

func _enter_active_attack() -> void:
	_state = EnemyState.ACTIVE
	_state_time_remaining = maxf(0.0, _get_current_attack_active_time())
	_hide_attack_telegraph()
	_set_attack_pose(_current_attack_type, true)
	_apply_body_debug_color()
	_set_attack_hitbox_enabled(true)
	_strike_active_attack_targets()

	if _state_time_remaining <= 0.0:
		_enter_recovery()

func _enter_recovery() -> void:
	_state = EnemyState.RECOVERY
	_state_time_remaining = maxf(0.0, _get_current_attack_recovery_time())
	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining, attack_cooldown)
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(true)
	_apply_body_debug_color()

	if _state_time_remaining <= 0.0:
		_finish_attack_recovery()

func _finish_attack_recovery() -> void:
	if _pattern_active:
		_advance_attack_pattern()
		return

	_state = EnemyState.CHASE
	_apply_body_debug_color()

func _advance_attack_pattern() -> void:
	_pattern_step_index += 1
	if _pattern_step_index >= _pattern_steps.size():
		_enter_pattern_recovery()
		return

	var interval := _get_current_pattern_step_interval()
	if interval <= 0.0:
		_start_current_pattern_step()
		return

	_state = EnemyState.PATTERN_GAP
	_state_time_remaining = interval
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(true)

func _enter_pattern_recovery() -> void:
	_state = EnemyState.PATTERN_RECOVERY
	_state_time_remaining = maxf(0.0, pattern_end_recovery_time)
	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining, attack_cooldown)
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(true)
	_apply_body_debug_color()

	if _state_time_remaining <= 0.0:
		_clear_attack_pattern_state()
		_state = EnemyState.CHASE
		_apply_body_debug_color()

func _abort_pattern_to_chase() -> void:
	_clear_attack_pattern_state()
	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining, attack_cooldown)
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(true)
	_state = EnemyState.CHASE
	_apply_body_debug_color()

func _strike_active_attack_targets() -> void:
	attack_hitbox.global_position = _get_current_attack_center()
	attack_hitbox.radius = _get_current_attack_radius()
	attack_hitbox.target_group = &"player"
	attack_hitbox.collision_mask = player_collision_mask
	attack_hitbox.refresh_debug_visual()

	var handled_targets: Array[Node] = []
	handled_targets.append_array(_attack_damaged_targets)
	var targets_in_hitbox := attack_hitbox.get_targets(self, handled_targets)
	var damaged: Array[Node] = []

	for target in targets_in_hitbox:
		if _get_current_attack_parryable() and target.has_method("try_parry_attack"):
			var did_parry := target.call("try_parry_attack", self) as bool
			if did_parry:
				return

		if _try_resolve_dodge_contact(target):
			continue

		var health_node := target.get_node_or_null("Health")
		if health_node != null and health_node.has_method("take_damage"):
			var did_damage := health_node.take_damage(_get_current_attack_damage()) as bool
			if did_damage:
				_attack_damaged_targets.append(target)
				damaged.append(target)
				_spawn_hit_vfx_for_target(target)
				_reset_combo_from_player_hit()
				_lose_flow_from_player_hit()

	_try_resolve_near_just_dodges(targets_in_hitbox)

	if not damaged.is_empty():
		_request_enemy_hit_stop()
		_request_enemy_camera_shake()

func _try_resolve_dodge_contact(target: Node) -> bool:
	if target == null or _just_dodged_targets.has(target):
		return false

	if target.has_method("try_just_dodge_attack"):
		var did_just_dodge := target.call("try_just_dodge_attack", self, _get_current_attack_center()) as bool
		if did_just_dodge:
			_just_dodged_targets.append(target)
			_attack_damaged_targets.append(target)
			return true

	if target.has_method("is_dodge_invulnerable"):
		var is_invulnerable := target.call("is_dodge_invulnerable") as bool
		if is_invulnerable:
			_attack_damaged_targets.append(target)
			return true

	return false

func _try_resolve_near_just_dodges(excluded_targets: Array[Node]) -> void:
	var margin := _get_target_just_dodge_detection_margin()
	if margin <= 0.0:
		return

	var previous_radius := attack_hitbox.radius
	attack_hitbox.radius = _get_current_attack_radius() + margin
	var ignored_targets: Array[Node] = []
	ignored_targets.append_array(_attack_damaged_targets)
	for target in excluded_targets:
		if not ignored_targets.has(target):
			ignored_targets.append(target)

	for target in attack_hitbox.get_targets(self, ignored_targets):
		if _just_dodged_targets.has(target):
			continue
		if target.has_method("try_just_dodge_attack"):
			var did_just_dodge := target.call("try_just_dodge_attack", self, _get_current_attack_center()) as bool
			if did_just_dodge:
				_just_dodged_targets.append(target)
				_attack_damaged_targets.append(target)

	attack_hitbox.radius = previous_radius
	attack_hitbox.refresh_debug_visual()

func _get_target_just_dodge_detection_margin() -> float:
	if _target != null and is_instance_valid(_target):
		var margin = _target.get("just_dodge_detection_margin")
		if margin is float or margin is int:
			return maxf(0.0, float(margin))

	return 0.0

func _get_current_attack_center() -> Vector3:
	return global_position + _attack_direction * _get_current_attack_range()

func receive_player_attack_hit(_attack_name: StringName, _attacker: Node) -> bool:
	if _state != EnemyState.TELEGRAPH:
		return false

	if not _can_current_attack_be_interrupted(_attack_name):
		return false

	_interrupt_current_attack(_get_current_attack_interrupt_stun_duration())
	_add_flow_from_interrupt()
	return true

func _interrupt_current_attack(stun_duration: float) -> void:
	_state = EnemyState.STUNNED
	_state_time_remaining = maxf(0.0, stun_duration)
	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining, attack_cooldown)
	_clear_attack_pattern_state()
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	velocity = Vector3.ZERO
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(true)
	_apply_body_debug_color()
	_show_interrupt_message()
	_request_interrupt_hit_stop()
	_request_interrupt_camera_shake()

	if debug_log_attack_types:
		print("Enemy attack interrupted: %s" % _get_attack_type_name(_current_attack_type))

	if _state_time_remaining <= 0.0:
		_state = EnemyState.CHASE
		_apply_body_debug_color()

func _resolve_combo_tracker() -> void:
	if combo_tracker_path != NodePath(""):
		_combo_tracker = get_node_or_null(combo_tracker_path) as ComboTracker

	if _combo_tracker == null:
		_combo_tracker = get_tree().get_first_node_in_group(&"combo_tracker") as ComboTracker

func _resolve_flow_tracker() -> void:
	if flow_tracker_path != NodePath(""):
		_flow_tracker = get_node_or_null(flow_tracker_path) as FlowTracker

	if _flow_tracker == null:
		_flow_tracker = get_tree().get_first_node_in_group(&"flow_tracker") as FlowTracker

func _reset_combo_from_player_hit() -> void:
	if _combo_tracker == null or not is_instance_valid(_combo_tracker):
		_resolve_combo_tracker()

	if _combo_tracker != null:
		_combo_tracker.reset_combo()

func _lose_flow_from_player_hit() -> void:
	if _flow_tracker == null or not is_instance_valid(_flow_tracker):
		_resolve_flow_tracker()

	if _flow_tracker != null:
		_flow_tracker.lose_damage_taken_flow()

func _add_flow_from_interrupt() -> void:
	if _flow_tracker == null or not is_instance_valid(_flow_tracker):
		_resolve_flow_tracker()

	if _flow_tracker != null:
		_flow_tracker.add_interrupt_flow()

func _spawn_hit_vfx_for_target(target: Node) -> void:
	if hit_vfx_scene == null:
		return

	var target_3d := target as Node3D
	if target_3d == null:
		return

	var hit_vfx := hit_vfx_scene.instantiate() as HitVfx
	if hit_vfx == null:
		return

	var vfx_scale := armor_slam_hit_vfx_scale if _current_attack_type == AttackType.ARMOR_SLAM else enemy_hit_vfx_scale
	hit_vfx.configure(HitVfx.HitKind.ENEMY, vfx_scale, hit_vfx_lifetime)

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

	_update_attack_telegraph_transform()
	attack_telegraph.visible = true
	_apply_telegraph_color()

func _update_attack_telegraph_transform() -> void:
	if attack_telegraph == null:
		return

	var telegraph_position := global_position + _attack_direction * _get_current_attack_range()
	telegraph_position.y = global_position.y + 0.03
	attack_telegraph.global_position = telegraph_position
	attack_telegraph.global_rotation.y = rotation.y
	attack_telegraph.scale = _get_current_telegraph_scale()


func _hide_attack_telegraph() -> void:
	if attack_telegraph != null:
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

	if _current_attack_type == AttackType.ARMOR_SLAM:
		_hit_stop.request_hit_stop(armor_slam_hit_stop_duration)
	else:
		_hit_stop.request_enemy_attack_hit_stop()

func _request_interrupt_hit_stop() -> void:
	if _hit_stop == null or not is_instance_valid(_hit_stop):
		_resolve_hit_stop()

	if _hit_stop == null:
		return

	_hit_stop.request_hit_stop(interrupt_hit_stop_duration)

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

	if _current_attack_type == AttackType.ARMOR_SLAM:
		_camera_follow.request_shake(armor_slam_camera_shake_strength, armor_slam_camera_shake_duration)
	else:
		_camera_follow.request_enemy_attack_shake()

func _request_interrupt_camera_shake() -> void:
	if _camera_follow == null or not is_instance_valid(_camera_follow):
		_resolve_camera_follow()

	if _camera_follow == null:
		return

	_camera_follow.request_shake(interrupt_camera_shake_strength, interrupt_camera_shake_duration)

func _resolve_combat_ui() -> void:
	if combat_ui_path != NodePath(""):
		_combat_ui = get_node_or_null(combat_ui_path) as CombatUI

	if _combat_ui == null:
		_combat_ui = get_tree().get_first_node_in_group(&"combat_ui") as CombatUI

func _show_interrupt_message() -> void:
	if _combat_ui == null or not is_instance_valid(_combat_ui):
		_resolve_combat_ui()

	if _combat_ui != null:
		_combat_ui.show_temporary_message(interrupt_message, interrupt_message_duration)

func receive_parry_stun(stun_time: float) -> void:
	if health.is_dead():
		return

	_state = EnemyState.STUNNED
	_state_time_remaining = maxf(0.0, stun_time)
	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining, attack_cooldown)
	_clear_attack_pattern_state()
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	velocity = Vector3.ZERO
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(true)
	_apply_body_debug_color()

	if _state_time_remaining <= 0.0:
		_state = EnemyState.CHASE
		_apply_body_debug_color()

func _enter_dead_state() -> void:
	if _state == EnemyState.DEAD:
		return

	_state = EnemyState.DEAD
	_state_time_remaining = 0.0
	_clear_attack_pattern_state()
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(false)
	_apply_body_debug_color()

func _select_attack_pattern(distance_to_target: float) -> int:
	var options: Array[Dictionary] = []
	_append_pattern_option(options, AttackPattern.FAST_COMBO, fast_combo_weight, distance_to_target)
	_append_pattern_option(options, AttackPattern.GRAB_MIX, grab_mix_weight, distance_to_target)
	_append_pattern_option(options, AttackPattern.HEAVY_BAIT, heavy_bait_weight, distance_to_target)
	_append_pattern_option(options, AttackPattern.SIMPLE_PRESSURE, simple_pressure_weight, distance_to_target)
	_append_pattern_option(options, AttackPattern.ARMOR_CHECK, armor_check_weight, distance_to_target)
	_append_pattern_option(options, AttackPattern.PRESSURE_INTO_SLAM, pressure_into_slam_weight, distance_to_target)
	_append_pattern_option(options, AttackPattern.BAIT_RETREAT, bait_retreat_weight, distance_to_target)
	_append_pattern_option(options, AttackPattern.SLASH_SLAM_MIX, slash_slam_mix_weight, distance_to_target)

	if options.is_empty():
		return AttackPattern.HEAVY_BAIT

	var total_weight := 0.0
	for option in options:
		total_weight += option["weight"] as float

	if total_weight <= 0.0:
		return options[0]["pattern"] as int

	var roll := randf() * total_weight
	for option in options:
		roll -= option["weight"] as float
		if roll <= 0.0:
			return option["pattern"] as int

	return options.back()["pattern"] as int

func _append_pattern_option(options: Array[Dictionary], pattern: int, weight: float, distance_to_target: float) -> void:
	if weight <= 0.0:
		return

	var first_attack := _get_pattern_first_attack(pattern)
	if distance_to_target > _get_attack_start_range_for_type(first_attack) + 0.05:
		return

	options.append({ "pattern": pattern, "weight": weight })

func _get_pattern_steps(pattern: int) -> Array[int]:
	var steps: Array[int] = []
	match pattern:
		AttackPattern.FAST_COMBO:
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.DELAYED_HEAVY)
		AttackPattern.GRAB_MIX:
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.GRAB)
		AttackPattern.HEAVY_BAIT:
			steps.append(AttackType.DELAYED_HEAVY)
		AttackPattern.ARMOR_CHECK:
			steps.append(AttackType.ARMOR_SLAM)
		AttackPattern.PRESSURE_INTO_SLAM:
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.ARMOR_SLAM)
		AttackPattern.BAIT_RETREAT:
			steps.append(AttackType.RETREAT_SLASH)
		AttackPattern.SLASH_SLAM_MIX:
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.ARMOR_SLAM)
		_:
			steps.append(AttackType.FAST_SLASH)
			steps.append(AttackType.FAST_SLASH)
	return steps

func _get_pattern_first_attack(pattern: int) -> int:
	match pattern:
		AttackPattern.HEAVY_BAIT:
			return AttackType.DELAYED_HEAVY
		AttackPattern.ARMOR_CHECK:
			return AttackType.ARMOR_SLAM
		AttackPattern.BAIT_RETREAT:
			return AttackType.RETREAT_SLASH
		_:
			return AttackType.FAST_SLASH

func _get_current_pattern_step_interval() -> float:
	match _current_attack_pattern:
		AttackPattern.FAST_COMBO:
			return fast_combo_step_interval
		AttackPattern.GRAB_MIX:
			return grab_mix_step_interval
		AttackPattern.HEAVY_BAIT:
			return heavy_bait_step_interval
		AttackPattern.ARMOR_CHECK:
			return armor_check_step_interval
		AttackPattern.PRESSURE_INTO_SLAM:
			return pressure_into_slam_step_interval
		AttackPattern.BAIT_RETREAT:
			return bait_retreat_step_interval
		AttackPattern.SLASH_SLAM_MIX:
			return slash_slam_mix_step_interval
		_:
			return simple_pressure_step_interval

func _get_attack_pattern_name(pattern: int) -> String:
	match pattern:
		AttackPattern.FAST_COMBO:
			return "Fast Combo"
		AttackPattern.GRAB_MIX:
			return "Grab Mix"
		AttackPattern.HEAVY_BAIT:
			return "Heavy Bait"
		AttackPattern.ARMOR_CHECK:
			return "Armor Check"
		AttackPattern.PRESSURE_INTO_SLAM:
			return "Pressure into Slam"
		AttackPattern.BAIT_RETREAT:
			return "Bait Retreat"
		AttackPattern.SLASH_SLAM_MIX:
			return "Slash Slam Mix"
		_:
			return "Simple Pressure"

func _should_abort_pattern_for_distance() -> bool:
	if not _pattern_active or pattern_abort_distance <= 0.0:
		return false

	var to_target := _get_flat_to_target()
	if to_target.length_squared() <= 0.001:
		return false

	return to_target.length() > pattern_abort_distance

func _clear_attack_pattern_state() -> void:
	_pattern_active = false
	_pattern_step_index = 0
	_pattern_steps.clear()

func _get_attack_start_range() -> float:
	return maxf(
		_get_attack_start_range_for_type(AttackType.FAST_SLASH),
		maxf(
			_get_attack_start_range_for_type(AttackType.DELAYED_HEAVY),
			maxf(
				_get_attack_start_range_for_type(AttackType.GRAB),
				maxf(
					_get_attack_start_range_for_type(AttackType.ARMOR_SLAM),
					_get_attack_start_range_for_type(AttackType.RETREAT_SLASH)
				)
			)
		)
	)

func _get_attack_start_range_for_type(attack_type: int) -> float:
	if attack_type == AttackType.RETREAT_SLASH:
		return maxf(0.1, _get_attack_range(attack_type) + _get_attack_radius(attack_type) - retreat_slash_retreat_distance - 0.15)

	return _get_attack_range(attack_type) + _get_attack_radius(attack_type)

func _get_current_attack_range() -> float:
	return _get_attack_range(_current_attack_type)

func _get_current_attack_radius() -> float:
	return _get_attack_radius(_current_attack_type)

func _get_current_attack_damage() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_damage
		AttackType.RETREAT_SLASH:
			return retreat_slash_damage
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_damage
		AttackType.GRAB:
			return grab_damage
		_:
			return fast_slash_damage

func _get_current_attack_telegraph_time() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_telegraph_time
		AttackType.RETREAT_SLASH:
			return retreat_slash_telegraph_time
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_telegraph_time
		AttackType.GRAB:
			return grab_telegraph_time
		_:
			return fast_slash_telegraph_time

func _get_current_attack_active_time() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_active_time
		AttackType.RETREAT_SLASH:
			return retreat_slash_active_time
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_active_time
		AttackType.GRAB:
			return grab_active_time
		_:
			return fast_slash_active_time

func _get_current_attack_recovery_time() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_recovery_time
		AttackType.RETREAT_SLASH:
			return retreat_slash_recovery_time
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_recovery_time
		AttackType.GRAB:
			return grab_recovery_time
		_:
			return fast_slash_recovery_time

func _get_current_attack_parryable() -> bool:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_parryable
		AttackType.RETREAT_SLASH:
			return retreat_slash_parryable
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_parryable
		AttackType.GRAB:
			return grab_parryable
		_:
			return fast_slash_parryable

func _get_current_attack_interruptible() -> bool:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_interruptible
		AttackType.RETREAT_SLASH:
			return retreat_slash_interruptible
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_interruptible
		AttackType.GRAB:
			return grab_interruptible
		_:
			return fast_slash_interruptible

func _get_attack_range(attack_type: int) -> float:
	match attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_range
		AttackType.RETREAT_SLASH:
			return retreat_slash_range
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_range
		AttackType.GRAB:
			return grab_range
		_:
			return fast_slash_range

func _get_attack_radius(attack_type: int) -> float:
	match attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_radius
		AttackType.RETREAT_SLASH:
			return retreat_slash_radius
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_radius
		AttackType.GRAB:
			return grab_radius
		_:
			return fast_slash_radius

func _get_current_telegraph_scale() -> Vector3:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return Vector3(armor_slam_radius * 1.22, 1.0, armor_slam_radius * 1.22)
		AttackType.RETREAT_SLASH:
			return Vector3(retreat_slash_radius * 0.9, 1.0, retreat_slash_radius * 0.72)
		AttackType.DELAYED_HEAVY:
			return Vector3(delayed_heavy_radius * 1.15, 1.0, delayed_heavy_radius * 1.15)
		AttackType.GRAB:
			return Vector3(grab_radius * 0.82, 1.0, grab_radius * 1.35)
		_:
			return Vector3(fast_slash_radius, 1.0, fast_slash_radius * 0.9)


func _get_current_attack_telegraph_color() -> Color:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_telegraph_color
		AttackType.RETREAT_SLASH:
			return retreat_slash_telegraph_color
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_telegraph_color
		AttackType.GRAB:
			return grab_telegraph_color
		_:
			return fast_slash_telegraph_color

func _get_attack_type_name(attack_type: int) -> String:
	match attack_type:
		AttackType.ARMOR_SLAM:
			return "Armor Slam"
		AttackType.RETREAT_SLASH:
			return "Retreat Slash"
		AttackType.DELAYED_HEAVY:
			return "Delayed Heavy Slash"
		AttackType.GRAB:
			return "Grab"
		_:
			return "Fast Slash"

func _get_flat_to_target() -> Vector3:
	if _target == null:
		return Vector3.ZERO

	var to_target := _target.global_position - global_position
	to_target.y = 0.0
	return to_target

func _setup_body_material() -> void:
	if body_mesh == null:
		return

	_body_base_scale = body_mesh.scale
	var material := body_mesh.get_active_material(0)
	if material is StandardMaterial3D:
		_body_material = (material as StandardMaterial3D).duplicate() as StandardMaterial3D
		body_mesh.set_surface_override_material(0, _body_material)

	_apply_body_debug_color()

func _setup_telegraph_material() -> void:
	var telegraph_mesh := attack_telegraph as MeshInstance3D
	if telegraph_mesh == null:
		return

	var material := telegraph_mesh.get_active_material(0)
	if material is StandardMaterial3D:
		_telegraph_material = (material as StandardMaterial3D).duplicate() as StandardMaterial3D
		telegraph_mesh.set_surface_override_material(0, _telegraph_material)

func _apply_telegraph_color() -> void:
	if _telegraph_material == null:
		return

	var color := _get_current_attack_telegraph_color()
	_telegraph_material.albedo_color = color
	_telegraph_material.emission = Color(color.r, color.g, color.b, 1.0)
	if _current_attack_type == AttackType.ARMOR_SLAM:
		_telegraph_material.emission_energy_multiplier = 0.85
	elif _current_attack_type == AttackType.DELAYED_HEAVY:
		_telegraph_material.emission_energy_multiplier = 0.65
	else:
		_telegraph_material.emission_energy_multiplier = 0.4

func _apply_body_debug_color() -> void:
	if _body_material == null:
		return

	if _state == EnemyState.STUNNED:
		_body_material.albedo_color = stunned_body_color
	elif _current_attack_type == AttackType.ARMOR_SLAM and (_state == EnemyState.TELEGRAPH or _state == EnemyState.ACTIVE):
		_body_material.albedo_color = armor_slam_body_color
	else:
		_body_material.albedo_color = normal_body_color

func _can_current_attack_be_interrupted(attack_name: StringName) -> bool:
	if not _get_current_attack_interruptible():
		return false
	if _get_current_attack_interrupt_requires_heavy() and attack_name != &"heavy":
		return false

	var window_start := _get_current_attack_interrupt_window_start()
	var window_end := _get_current_attack_interrupt_window_end()
	if window_end <= 0.0:
		window_end = _get_current_attack_telegraph_time()

	return _current_attack_telegraph_elapsed >= window_start and _current_attack_telegraph_elapsed <= window_end

func _get_current_attack_interrupt_window_start() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_interrupt_window_start
		AttackType.RETREAT_SLASH:
			return retreat_slash_interrupt_window_start
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_interrupt_window_start
		AttackType.GRAB:
			return grab_interrupt_window_start
		_:
			return fast_slash_interrupt_window_start

func _get_current_attack_interrupt_window_end() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_interrupt_window_end
		AttackType.RETREAT_SLASH:
			return retreat_slash_interrupt_window_end
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_interrupt_window_end
		AttackType.GRAB:
			return grab_interrupt_window_end
		_:
			return fast_slash_interrupt_window_end

func _get_current_attack_interrupt_requires_heavy() -> bool:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_interrupt_requires_heavy
		AttackType.RETREAT_SLASH:
			return retreat_slash_interrupt_requires_heavy
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_interrupt_requires_heavy
		AttackType.GRAB:
			return grab_interrupt_requires_heavy
		_:
			return fast_slash_interrupt_requires_heavy

func _get_current_attack_interrupt_stun_duration() -> float:
	match _current_attack_type:
		AttackType.ARMOR_SLAM:
			return armor_slam_interrupt_stun_duration
		AttackType.RETREAT_SLASH:
			return retreat_slash_interrupt_stun_duration
		AttackType.DELAYED_HEAVY:
			return delayed_heavy_interrupt_stun_duration
		AttackType.GRAB:
			return grab_interrupt_stun_duration
		_:
			return fast_slash_interrupt_stun_duration

func _set_attack_pose(attack_type: int, is_active: bool) -> void:
	var duration := pose_tween_time
	_begin_pose_change(duration)
	_apply_body_scale(attack_type == AttackType.ARMOR_SLAM)

	match attack_type:
		AttackType.ARMOR_SLAM:
			if is_active:
				_apply_pose_values(Vector3(0.32, 1.02, -0.54), Vector3(82, 0, -20), Vector3(-0.34, 1.02, -0.52), Vector3(82, 0, 20), Vector3(0.0, 0.74, -0.72), Vector3(96, 0, 0), true, duration)
			else:
				_apply_pose_values(Vector3(0.46, 1.78, 0.06), Vector3(-86, -12, -28), Vector3(-0.42, 1.62, 0.02), Vector3(-78, 12, 26), Vector3(0.18, 2.05, 0.16), Vector3(-88, 0, -12), true, duration)
		AttackType.RETREAT_SLASH:
			if is_active:
				_apply_pose_values(Vector3(0.36, 1.02, -0.5), Vector3(48, 52, -18), Vector3(-0.42, 1.0, -0.12), Vector3(18, 0, 12), Vector3(0.16, 1.02, -0.94), Vector3(78, 72, -10), true, duration)
			else:
				_apply_pose_values(Vector3(0.5, 1.0, 0.22), Vector3(-8, -68, -10), Vector3(-0.44, 1.0, -0.08), Vector3(18, 0, 16), Vector3(0.82, 0.98, 0.08), Vector3(-12, -76, -8), true, duration)
		AttackType.DELAYED_HEAVY:
			if is_active:
				_apply_pose_values(Vector3(0.18, 1.22, -0.58), Vector3(48, -18, -42), Vector3(-0.38, 1.0, -0.16), Vector3(18, 0, 12), Vector3(0.12, 1.05, -0.98), Vector3(82, 36, -36), true, duration)
			else:
				_apply_pose_values(Vector3(0.5, 1.48, 0.12), Vector3(-58, -22, -24), Vector3(-0.42, 1.08, -0.18), Vector3(18, 0, 12), Vector3(0.52, 1.82, 0.22), Vector3(-70, -18, -22), true, duration)
		AttackType.GRAB:
			if is_active:
				_apply_pose_values(Vector3(0.28, 1.08, -0.68), Vector3(72, 0, -16), Vector3(-0.28, 1.08, -0.78), Vector3(76, 0, 16), Vector3(0.0, 0.0, 0.0), Vector3.ZERO, false, duration)
			else:
				_apply_pose_values(Vector3(0.36, 1.08, -0.32), Vector3(45, 0, -14), Vector3(-0.22, 1.12, -0.56), Vector3(62, 0, 18), Vector3(0.0, 0.0, 0.0), Vector3.ZERO, false, duration)
		_:
			if is_active:
				_apply_pose_values(Vector3(0.22, 1.12, -0.5), Vector3(35, 36, -28), Vector3(-0.42, 1.02, -0.14), Vector3(18, 0, 12), Vector3(0.1, 1.12, -0.88), Vector3(68, 62, -18), true, duration)
			else:
				_apply_pose_values(Vector3(0.5, 1.08, 0.02), Vector3(-14, -24, -12), Vector3(-0.42, 1.02, -0.14), Vector3(18, 0, 12), Vector3(0.68, 1.08, -0.1), Vector3(-18, -28, -12), true, duration)

func reset_attack_pose(use_tween: bool = false) -> void:
	var duration := pose_tween_time if use_tween else 0.0
	_begin_pose_change(duration)
	_apply_body_scale(false)
	_apply_pose_values(Vector3(0.55, 0.78, -0.02), Vector3(90, 0, 0), Vector3(-0.55, 0.78, -0.02), Vector3(90, 0, 0), Vector3(0.66, 0.7, -0.08), Vector3(90, 0, 0), true, duration)

func _apply_body_scale(use_armor_scale: bool) -> void:
	if body_mesh == null:
		return

	body_mesh.scale = _body_base_scale * armor_slam_body_scale if use_armor_scale else _body_base_scale

func _begin_pose_change(duration: float) -> void:
	if _pose_tween != null and _pose_tween.is_valid():
		_pose_tween.kill()

	_pose_tween = null
	if duration > 0.0:
		_pose_tween = create_tween()
		_pose_tween.set_parallel(true)

func _apply_pose_values(
	right_position: Vector3,
	right_rotation_degrees: Vector3,
	left_position: Vector3,
	left_rotation_degrees: Vector3,
	weapon_position: Vector3,
	weapon_rotation_degrees: Vector3,
	weapon_visible: bool,
	duration: float
) -> void:
	_move_pose_node(right_arm, right_position, right_rotation_degrees, true, duration)
	_move_pose_node(left_arm, left_position, left_rotation_degrees, true, duration)
	_move_pose_node(weapon, weapon_position, weapon_rotation_degrees, weapon_visible, duration)

func _move_pose_node(node: Node3D, target_position: Vector3, target_rotation_degrees: Vector3, is_visible: bool, duration: float) -> void:
	if node == null:
		return

	node.visible = is_visible
	if duration <= 0.0 or _pose_tween == null:
		node.position = target_position
		node.rotation_degrees = target_rotation_degrees
		return

	_pose_tween.tween_property(node, "position", target_position, duration)
	_pose_tween.tween_property(node, "rotation_degrees", target_rotation_degrees, duration)

func set_ai_enabled(value: bool) -> void:
	_ai_enabled = value
	if not _ai_enabled:
		velocity = Vector3.ZERO
		_state_time_remaining = 0.0
		_attack_cooldown_remaining = 0.0
		_clear_attack_pattern_state()
		_attack_damaged_targets.clear()
		_just_dodged_targets.clear()
		_set_attack_hitbox_enabled(false)
		_hide_attack_telegraph()
		reset_attack_pose(false)
		_state = EnemyState.DEAD if health.is_dead() else EnemyState.CHASE
		_apply_body_debug_color()

func reset_combat_state() -> void:
	_ai_enabled = true
	velocity = Vector3.ZERO
	_state = EnemyState.CHASE
	_state_time_remaining = 0.0
	_attack_cooldown_remaining = 0.0
	_attack_direction = Vector3.FORWARD
	_current_attack_type = AttackType.FAST_SLASH
	_current_attack_pattern = AttackPattern.SIMPLE_PRESSURE
	_current_attack_telegraph_elapsed = 0.0
	_retreat_distance_remaining = 0.0
	_clear_attack_pattern_state()
	_attack_damaged_targets.clear()
	_just_dodged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_hide_attack_telegraph()
	reset_attack_pose(false)
	_apply_body_debug_color()
	_resolve_target()
