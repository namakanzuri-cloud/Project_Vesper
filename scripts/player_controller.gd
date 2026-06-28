extends CharacterBody3D
class_name PlayerController

signal damage_taken(amount: float)
signal parry_succeeded
signal normal_parry_succeeded
signal rhythm_deflect_succeeded(chain_count: int)
signal parry_failed
signal just_dodge_succeeded
signal riposte_hit
signal vesper_counter_hit
signal just_dodge_counter_hit
signal vesper_art_used
signal vesper_art_hit
signal vesper_art_missed
signal blood_rend_used
signal blood_rend_hit(blood_cost: float)
signal blood_scent_success
signal blood_scent_hit_taken

enum AttackPhase { NONE, WINDUP, ACTIVE, RECOVERY }
enum ParryPhase { NONE, STARTUP, ACTIVE, RECOVERY }

@export_group("Movement")
@export var move_speed: float = 6.0
@export var rotation_speed: float = 16.0
@export var camera_relative_movement: bool = true

@export_group("Dodge")
@export var dodge_speed: float = 15.0
@export var dodge_duration: float = 0.18
@export var dodge_invulnerable_duration: float = 0.18
@export var dodge_stamina_cost: float = 24.0

@export_group("Just Dodge")
@export var just_dodge_window: float = 0.10
@export var just_dodge_detection_margin: float = 0.28
@export var just_dodge_hit_stop_duration: float = 0.06
@export var just_dodge_camera_shake_strength: float = 0.10
@export var just_dodge_camera_shake_duration: float = 0.08
@export var just_dodge_combo_bonus: int = 1
@export var just_dodge_combo_extend_time: float = 1.0
@export var just_dodge_message: String = "JUST DODGE!"
@export var just_dodge_message_duration: float = 0.55

@export_group("Just Dodge Counter")
@export var just_dodge_counter_window: float = 0.6
@export var just_dodge_counter_damage_multiplier: float = 1.5
@export var just_dodge_counter_flow_gain: float = 10.0
@export var just_dodge_counter_enemy_stun_time: float = 0.32
@export var just_dodge_counter_stamina_cost: float = 0.0
@export var just_dodge_counter_windup: float = 0.10
@export var just_dodge_counter_active: float = 0.14
@export var just_dodge_counter_recovery: float = 0.24
@export var just_dodge_counter_hit_stop_duration: float = 0.09
@export var just_dodge_counter_camera_shake_strength: float = 0.13
@export var just_dodge_counter_camera_shake_duration: float = 0.10
@export var just_dodge_counter_vfx_scale: float = 1.18
@export var just_dodge_counter_ready_message: String = "JUST COUNTER READY"
@export var just_dodge_counter_hit_message: String = "JUST COUNTER!"
@export var just_dodge_counter_message_duration: float = 0.55
@export var just_dodge_counter_recent_display_time: float = 0.75

@export_group("Parry")
@export var parry_startup_time: float = 0.08
@export var parry_active_time: float = 0.18
@export var parry_recovery_time: float = 0.32
@export var parry_fail_recovery_time: float = 0.42
@export var parry_success_recovery_time: float = 0.05
@export var parry_stamina_cost: float = 12.0
@export var parry_success_stun_time: float = 0.78
@export_range(0.0, 1.0, 0.05) var parry_startup_move_speed_multiplier: float = 0.15
@export_range(0.0, 1.0, 0.05) var parry_active_move_speed_multiplier: float = 0.0
@export_range(0.0, 1.0, 0.05) var parry_recovery_move_speed_multiplier: float = 0.25

@export_group("Rhythm Deflect")
@export var deflect_success_recovery_time: float = 0.0
@export var deflect_chain_timeout: float = 1.0
@export var deflect_message: String = "DEFLECT!"
@export var deflect_message_duration: float = 0.42
@export var deflect_hit_stop_duration: float = 0.045
@export var deflect_shake_strength: float = 0.07
@export var deflect_shake_duration: float = 0.06
@export var deflect_hit_vfx_scale: float = 0.85

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

@export_group("Enemy AI Signals")
@export var recent_attack_history_duration: float = 4.0

@export_group("Debug")
@export var debug_attack_state_colors: bool = true
@export var debug_attack_hitbox: bool = true
@export var idle_body_color: Color = Color(0.2, 0.62, 1.0, 1.0)
@export var windup_body_color: Color = Color(1.0, 0.86, 0.18, 1.0)
@export var active_body_color: Color = Color(0.25, 1.0, 0.45, 1.0)
@export var recovery_body_color: Color = Color(0.85, 0.35, 1.0, 1.0)
@export var parry_startup_body_color: Color = Color(0.45, 0.9, 1.0, 1.0)
@export var parry_active_body_color: Color = Color(0.1, 1.0, 0.95, 1.0)
@export var parry_recovery_body_color: Color = Color(0.55, 0.65, 0.75, 1.0)
@export var parry_active_ring_color: Color = Color(0.2, 1.0, 0.95, 0.72)
@export var parry_recovery_ring_color: Color = Color(0.55, 0.65, 0.75, 0.36)
@export var riposte_ready_body_color: Color = Color(0.45, 1.0, 0.78, 1.0)
@export var riposte_ready_ring_color: Color = Color(0.45, 1.0, 0.78, 0.52)
@export var vesper_ready_body_color: Color = Color(1.0, 0.86, 0.28, 1.0)
@export var vesper_ready_ring_color: Color = Color(1.0, 0.86, 0.28, 0.62)
@export var just_dodge_counter_ready_body_color: Color = Color(0.5, 1.0, 0.7, 1.0)

@export_group("Collision")
@export_flags_3d_physics var enemy_collision_mask: int = 4

@export_group("Hit Stop")
@export var hit_stop_path: NodePath

@export_group("Camera Shake")
@export var camera_follow_path: NodePath
@export var parry_shake_strength: float = 0.18
@export var parry_shake_duration: float = 0.13

@export_group("Hit VFX")
@export var hit_vfx_scene: PackedScene = preload("res://scenes/HitVfx.tscn")
@export var light_hit_vfx_scale: float = 0.85
@export var heavy_hit_vfx_scale: float = 1.25
@export var parry_hit_vfx_scale: float = 1.35
@export var just_dodge_vfx_scale: float = 1.05
@export var hit_vfx_lifetime: float = 0.22
@export var hit_vfx_vertical_offset: float = 0.85

@export_group("Parry Feedback")
@export var combat_ui_path: NodePath
@export var parry_hit_stop_duration: float = 0.13
@export var parry_message: String = "PARRY!"

@export_group("Riposte")
@export var parry_stock_max: int = 3
@export var vesper_counter_required_parry_stock: int = 3
@export var riposte_window: float = 1.1
@export var riposte_damage_multiplier: float = 1.4
@export var vesper_counter_damage_multiplier: float = 2.1
@export var riposte_windup: float = 0.18
@export var riposte_active: float = 0.16
@export var riposte_recovery: float = 0.28
@export var riposte_ready_message: String = "RIPOSTE READY"
@export var vesper_counter_ready_message: String = "VESPER COUNTER READY"
@export var riposte_ready_message_duration: float = 0.55

@export_group("Riposte Feedback")
@export var riposte_hit_message: String = "RIPOSTE!"
@export var vesper_counter_hit_message: String = "VESPER COUNTER!"
@export var riposte_hit_stop_duration: float = 0.13
@export var vesper_counter_hit_stop_duration: float = 0.18
@export var riposte_camera_shake_strength: float = 0.17
@export var riposte_camera_shake_duration: float = 0.13
@export var vesper_counter_camera_shake_strength: float = 0.22
@export var vesper_counter_camera_shake_duration: float = 0.18
@export var riposte_hit_vfx_scale: float = 1.45
@export var vesper_counter_hit_vfx_scale: float = 1.85
@export var vesper_counter_combo_extend_time: float = 2.1

@export_group("Vesper Art")
@export var vesper_art_flow_cost: float = 100.0
@export var vesper_art_damage_multiplier: float = 2.5
@export var vesper_art_miss_flow_cost: float = 75.0
@export var vesper_art_windup: float = 0.32
@export var vesper_art_active: float = 0.22
@export var vesper_art_recovery: float = 0.42
@export var vesper_art_hit_stop: float = 0.12
@export var vesper_art_camera_shake: float = 1.4
@export var vesper_art_camera_shake_duration: float = 0.18
@export var vesper_art_hit_vfx_scale: float = 2.05
@export var vesper_art_combo_extend_time: float = 2.0
@export var vesper_art_ready_message: String = "VESPER ART READY"
@export var vesper_art_hit_message: String = "VESPER ART!"
@export var vesper_art_message_duration: float = 0.65


@export_group("Blood Rend / Blood Scent")
@export var blood_rend_damage: float = 12.0
@export var blood_rend_self_damage: float = 8.0
@export var blood_rend_range: float = 2.0
@export var blood_rend_radius: float = 1.0
@export var blood_rend_ready_duration: float = 0.8
@export var blood_scent_duration: float = 6.0
@export var blood_rend_min_survive_hp: float = 1.0
@export var blood_rend_windup: float = 0.08
@export var blood_rend_active: float = 0.12
@export var blood_rend_recovery: float = 0.24
@export var blood_rend_hit_stop_duration: float = 0.08
@export var blood_rend_camera_shake_strength: float = 0.14
@export var blood_rend_camera_shake_duration: float = 0.10
@export var blood_rend_vfx_scale: float = 1.15
@export var blood_rend_ready_message: String = "BLOOD REND READY (Q)"
@export var blood_rend_hit_message: String = "BLOOD REND!"
@export var blood_rend_blocked_message: String = "TOO LITTLE HP"
@export var blood_rend_message_duration: float = 0.55
@export_group("Combo")
@export var combo_tracker_path: NodePath

@export_group("Flow")
@export var flow_tracker_path: NodePath

@onready var health: Health = $Health
@onready var stamina: Stamina = $Stamina
@onready var attack_hitbox: CombatHitbox = $AttackHitbox
@onready var body_mesh: MeshInstance3D = $Body
@onready var parry_visual: MeshInstance3D = get_node_or_null("ParryVisual") as MeshInstance3D

var _move_direction: Vector3 = Vector3.ZERO
var _last_facing: Vector3 = Vector3.FORWARD
var _dodge_direction: Vector3 = Vector3.ZERO
var _dodge_remaining: float = 0.0
var _dodge_invulnerable_remaining: float = 0.0
var _just_dodge_remaining: float = 0.0
var _just_dodge_counter_time_remaining: float = 0.0
var _just_dodge_counter_recent_time_remaining: float = 0.0
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
var _vesper_art_hit_confirmed: bool = false
var _recent_attack_times: Array[float] = []
var _parry_phase: int = ParryPhase.NONE
var _parry_phase_remaining: float = 0.0
var _body_material: StandardMaterial3D
var _parry_visual_material: StandardMaterial3D
var _controls_enabled: bool = true
var _hit_stop
var _camera_follow: CameraFollow
var _combat_ui: CombatUI
var _combo_tracker: ComboTracker
var _flow_tracker: FlowTracker
var parry_stock: int = 0
var _riposte_time_remaining: float = 0.0
var _last_health_value: float = 0.0
var _deflect_chain_count: int = 0
var _max_deflect_chain: int = 0
var _deflect_chain_time_remaining: float = 0.0
var _deflect_count: int = 0
var _normal_parry_count: int = 0
var _parry_fail_count: int = 0
var _last_parry_result: String = "None"
var _blood_rend_ready_time_remaining: float = 0.0
var _blood_scent_time_remaining: float = 0.0
var _blood_rend_self_damage_pending: float = 0.0

func _ready() -> void:
	_last_health_value = health.current_health
	if not health.changed.is_connected(_on_health_changed):
		health.changed.connect(_on_health_changed)

	_resolve_hit_stop()
	_resolve_camera_follow()
	_resolve_combat_ui()
	_resolve_combo_tracker()
	_resolve_flow_tracker()
	_setup_body_material()
	_setup_parry_visual_material()
	_set_attack_hitbox_enabled(false)
	_apply_debug_color()

func _physics_process(delta: float) -> void:
	_update_riposte_ready(delta)
	_update_just_dodge_counter_ready(delta)
	_update_blood_rend_ready(delta)
	_update_blood_scent(delta)
	_update_deflect_chain(delta)
	if health.is_dead() or not _controls_enabled:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	_read_movement_input()
	_handle_actions()
	_update_dodge_state(delta)
	_update_attack_state(delta)
	_update_parry_state(delta)
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
	if not _is_attacking() and not _is_parrying() and _move_direction.length_squared() > 0.001:
		_last_facing = _move_direction

func _handle_actions() -> void:
	if Input.is_action_just_pressed("dodge"):
		_try_dodge()

	if Input.is_action_just_pressed("parry"):
		_try_parry()

	if Input.is_action_just_pressed("blood_rend"):
		_try_blood_rend_attack()

	if Input.is_action_just_pressed("light_attack"):
		if _is_just_dodge_counter_ready():
			_try_just_dodge_counter_attack()
		else:
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
		_handle_heavy_attack()

func _handle_heavy_attack() -> void:
	if _is_riposte_ready():
		_try_riposte_attack()
	elif _can_use_vesper_art():
		_try_vesper_art_attack()
	# Basic heavy attack is intentionally disabled so heavy input is reserved for Riposte / Vesper Art.

func _update_just_dodge_counter_ready(delta: float) -> void:
	var was_ready := _is_just_dodge_counter_ready()
	if _just_dodge_counter_time_remaining > 0.0:
		_just_dodge_counter_time_remaining = maxf(0.0, _just_dodge_counter_time_remaining - delta)

	if _just_dodge_counter_recent_time_remaining > 0.0:
		_just_dodge_counter_recent_time_remaining = maxf(0.0, _just_dodge_counter_recent_time_remaining - delta)

	if was_ready and not _is_just_dodge_counter_ready():
		_apply_debug_color()

func _update_blood_rend_ready(delta: float) -> void:
	var was_ready := is_blood_rend_ready()
	if _blood_rend_ready_time_remaining > 0.0:
		_blood_rend_ready_time_remaining = maxf(0.0, _blood_rend_ready_time_remaining - delta)

	if was_ready and not is_blood_rend_ready():
		_apply_debug_color()

func _update_blood_scent(delta: float) -> void:
	if _blood_scent_time_remaining <= 0.0:
		return

	_blood_scent_time_remaining = maxf(0.0, _blood_scent_time_remaining - delta)
	if _blood_scent_time_remaining <= 0.0:
		_apply_debug_color()

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
			_spend_vesper_art_miss_cost_if_needed()
			_enter_attack_phase(AttackPhase.RECOVERY, _current_attack_recovery)
		AttackPhase.RECOVERY:
			_clear_attack_state()
		_:
			_clear_attack_state()

func _update_parry_state(delta: float) -> void:
	if not _is_parrying():
		return

	_parry_phase_remaining -= delta
	while _is_parrying() and _parry_phase_remaining <= 0.0:
		_advance_parry_phase()

func _update_riposte_ready(delta: float) -> void:
	if _riposte_time_remaining <= 0.0:
		return

	_riposte_time_remaining = maxf(0.0, _riposte_time_remaining - delta)
	if _riposte_time_remaining <= 0.0:
		_apply_debug_color()

func _update_dodge_state(delta: float) -> void:
	_dodge_invulnerable_remaining = maxf(0.0, _dodge_invulnerable_remaining - delta)
	_just_dodge_remaining = maxf(0.0, _just_dodge_remaining - delta)

func _advance_parry_phase() -> void:
	match _parry_phase:
		ParryPhase.STARTUP:
			_enter_parry_phase(ParryPhase.ACTIVE, parry_active_time)
		ParryPhase.ACTIVE:
			_on_parry_failed()
		ParryPhase.RECOVERY:
			_clear_parry_state()
		_:
			_clear_parry_state()

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
		var speed_multiplier := 1.0
		if _is_attacking():
			speed_multiplier = _get_attack_move_speed_multiplier()
		elif _is_parrying():
			speed_multiplier = _get_parry_move_speed_multiplier()
		velocity.x = _move_direction.x * move_speed * speed_multiplier
		velocity.z = _move_direction.z * move_speed * speed_multiplier

	velocity.y = 0.0
	move_and_slide()

func _try_dodge() -> void:
	if _is_attacking() or _is_parrying() or _dodge_remaining > 0.0 or not stamina.try_spend(dodge_stamina_cost):
		return

	_clear_just_dodge_counter_ready()
	_dodge_direction = _move_direction if _move_direction.length_squared() > 0.001 else _last_facing
	_dodge_direction = _dodge_direction.normalized()
	_dodge_remaining = dodge_duration
	_dodge_invulnerable_remaining = dodge_invulnerable_duration
	_just_dodge_remaining = minf(just_dodge_window, dodge_invulnerable_duration)

func _try_parry() -> void:
	if _is_attacking() or _is_parrying() or _dodge_remaining > 0.0 or not stamina.try_spend(parry_stamina_cost):
		return

	_clear_just_dodge_counter_ready()
	_last_facing = _get_locked_attack_direction()
	rotation.y = atan2(-_last_facing.x, -_last_facing.z)
	_enter_parry_phase(ParryPhase.STARTUP, parry_startup_time)
	if parry_startup_time <= 0.0 and parry_active_time <= 0.0 and parry_recovery_time <= 0.0:
		_clear_parry_state()

func _try_attack(attack_name: StringName, damage: float, attack_range: float, attack_radius: float, stamina_cost: float, windup: float, active: float, recovery: float) -> bool:
	if _is_attacking() or _is_parrying() or _dodge_remaining > 0.0 or not stamina.try_spend(stamina_cost):
		return false

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
	_record_attack_start()

	_enter_attack_phase(AttackPhase.WINDUP, windup)
	if attack_name != &"just_dodge_counter":
		_clear_just_dodge_counter_ready()
	if active <= 0.0 and windup <= 0.0 and recovery <= 0.0:
		_clear_attack_state()

	return true

func _enter_attack_phase(phase: int, duration: float) -> void:
	_attack_phase = phase
	_attack_phase_remaining = maxf(0.0, duration)
	_set_attack_hitbox_enabled(_attack_phase == AttackPhase.ACTIVE)
	_apply_debug_color()

	if _attack_phase == AttackPhase.ACTIVE:
		_strike_active_attack_targets()

func _enter_parry_phase(phase: int, duration: float) -> void:
	_parry_phase = phase
	_parry_phase_remaining = maxf(0.0, duration)
	_apply_debug_color()

func try_parry_attack(attacker: Node) -> bool:
	if not is_parry_active():
		return false

	_on_parry_success(attacker, _get_parry_response(attacker))
	return true

func try_just_dodge_attack(attacker: Node, impact_position: Vector3 = Vector3.ZERO) -> bool:
	if not is_just_dodge_available():
		return false

	_on_just_dodge_success(attacker, impact_position)
	return true

func is_parry_active() -> bool:
	return _parry_phase == ParryPhase.ACTIVE

func is_dodge_invulnerable() -> bool:
	return _dodge_invulnerable_remaining > 0.0

func is_just_dodge_available() -> bool:
	return _dodge_remaining > 0.0 and _just_dodge_remaining > 0.0 and not health.is_dead() and _controls_enabled

func is_riposte_ready() -> bool:
	return _is_riposte_ready()

func is_vesper_counter_ready() -> bool:
	return _is_riposte_ready() and parry_stock >= get_vesper_counter_required_stock()

func is_vesper_art_ready() -> bool:
	return _can_use_vesper_art()

func is_just_dodge_counter_ready() -> bool:
	return _is_just_dodge_counter_ready()

func get_just_dodge_counter_time_remaining() -> float:
	return _just_dodge_counter_time_remaining if _is_just_dodge_counter_ready() else 0.0

func was_just_dodge_counter_recently_used() -> bool:
	return _just_dodge_counter_recent_time_remaining > 0.0

func is_blood_rend_ready() -> bool:
	return _blood_rend_ready_time_remaining > 0.0 and not health.is_dead() and _controls_enabled

func get_blood_rend_ready_time_remaining() -> float:
	return _blood_rend_ready_time_remaining if is_blood_rend_ready() else 0.0

func is_blood_scent_active() -> bool:
	return _blood_scent_time_remaining > 0.0 and not health.is_dead() and _controls_enabled

func get_blood_scent_time_remaining() -> float:
	return _blood_scent_time_remaining if is_blood_scent_active() else 0.0

func get_parry_stock() -> int:
	return parry_stock

func get_parry_stock_max() -> int:
	return maxi(1, parry_stock_max)

func get_vesper_counter_required_stock() -> int:
	return clampi(vesper_counter_required_parry_stock, 1, get_parry_stock_max())

func get_riposte_time_remaining() -> float:
	return _riposte_time_remaining if is_riposte_ready() else 0.0

func get_vesper_counter_time_remaining() -> float:
	return _riposte_time_remaining if is_vesper_counter_ready() else 0.0

func get_vesper_art_flow_cost() -> float:
	return vesper_art_flow_cost

func get_deflect_chain_count() -> int:
	return _deflect_chain_count

func get_max_deflect_chain() -> int:
	return _max_deflect_chain

func get_deflect_count() -> int:
	return _deflect_count

func get_normal_parry_count() -> int:
	return _normal_parry_count

func get_parry_fail_count() -> int:
	return _parry_fail_count

func get_last_parry_result() -> String:
	return _last_parry_result

func get_recent_attack_count(window_seconds: float) -> int:
	var now := Time.get_ticks_msec() / 1000.0
	var count_window := maxf(0.0, window_seconds)
	_prune_recent_attack_times(now, maxf(count_window, recent_attack_history_duration))

	var attack_count := 0
	for attack_time in _recent_attack_times:
		if now - attack_time <= count_window:
			attack_count += 1

	return attack_count

func _on_health_changed(current_health: float, _max_health: float) -> void:
	if current_health < _last_health_value:
		var damage_delta := _last_health_value - current_health
		var self_damage_delta := minf(damage_delta, _blood_rend_self_damage_pending)
		_blood_rend_self_damage_pending = maxf(0.0, _blood_rend_self_damage_pending - self_damage_delta)
		var normal_damage_delta := damage_delta - self_damage_delta

		if normal_damage_delta > 0.0:
			damage_taken.emit(normal_damage_delta)
			if is_blood_scent_active():
				blood_scent_hit_taken.emit()
				_end_blood_scent()
			_reset_parry_reward_state()
			_reset_deflect_state()
			_clear_just_dodge_counter_ready()
			_clear_blood_rend_ready()

	_last_health_value = current_health

func _on_parry_success(attacker: Node, parry_response: Dictionary) -> void:
	var stops_enemy := bool(parry_response.get("parry_stops_enemy", true))
	var is_deflect := bool(parry_response.get("is_rhythm_deflect", false)) or not stops_enemy
	if is_deflect:
		_on_rhythm_deflect_success(attacker, parry_response)
	else:
		_on_normal_parry_success(attacker, parry_response)

func _on_normal_parry_success(attacker: Node, parry_response: Dictionary) -> void:
	var stops_enemy := bool(parry_response.get("parry_stops_enemy", true))
	var grants_riposte := bool(parry_response.get("parry_grants_riposte", true))
	if stops_enemy and attacker != null and attacker.has_method("receive_parry_stun"):
		attacker.call("receive_parry_stun", parry_success_stun_time)

	_last_parry_result = "PARRY"
	_normal_parry_count += 1
	_reset_current_deflect_chain()
	_request_parry_hit_stop()
	_request_parry_camera_shake()
	_spawn_parry_vfx(attacker)
	_show_parry_message()
	if grants_riposte:
		_grant_riposte_ready()
	_add_combo_from_parry()
	_add_flow_from_parry(float(parry_response.get("parry_flow_gain", 0.0)))
	_register_blood_scent_success()
	normal_parry_succeeded.emit()
	parry_succeeded.emit()

	if parry_success_recovery_time > 0.0:
		_enter_parry_phase(ParryPhase.RECOVERY, parry_success_recovery_time)
	else:
		_clear_parry_state()

func _on_rhythm_deflect_success(attacker: Node, parry_response: Dictionary) -> void:
	_register_deflect_chain()
	_last_parry_result = "DEFLECT x%d" % _deflect_chain_count
	_deflect_count += 1
	_request_deflect_hit_stop()
	_request_deflect_camera_shake()
	_spawn_parry_vfx(attacker, deflect_hit_vfx_scale)
	_show_deflect_message()
	_add_combo_from_parry()
	_add_flow_from_deflect(float(parry_response.get("deflect_flow_gain", 0.0)))
	_register_blood_scent_success()
	rhythm_deflect_succeeded.emit(_deflect_chain_count)
	parry_succeeded.emit()

	if deflect_success_recovery_time > 0.0:
		_enter_parry_phase(ParryPhase.RECOVERY, deflect_success_recovery_time)
	else:
		_clear_parry_state()

func _on_parry_failed() -> void:
	_last_parry_result = "FAIL"
	_parry_fail_count += 1
	_reset_current_deflect_chain()
	parry_failed.emit()
	_enter_parry_phase(ParryPhase.RECOVERY, parry_fail_recovery_time)

func _on_just_dodge_success(attacker: Node, impact_position: Vector3) -> void:
	_just_dodge_remaining = 0.0
	_grant_just_dodge_counter_ready()
	_request_just_dodge_hit_stop()
	_request_just_dodge_camera_shake()
	_spawn_just_dodge_vfx(impact_position)
	_show_just_dodge_message()
	_add_combo_from_just_dodge()
	_add_flow_from_just_dodge()
	_register_blood_scent_success()
	just_dodge_succeeded.emit()

func _strike_active_attack_targets() -> void:
	attack_hitbox.global_position = global_position + _attack_direction * _current_attack_range
	attack_hitbox.radius = _current_attack_radius
	attack_hitbox.target_group = &"enemy"
	attack_hitbox.collision_mask = enemy_collision_mask
	attack_hitbox.refresh_debug_visual()

	var attack_damage := _get_current_attack_damage()
	var damaged := attack_hitbox.strike(attack_damage, self, _attack_damaged_targets)
	if not damaged.is_empty() and _is_blood_rend_attack_name(_current_attack_name):
		_on_blood_rend_hit()
	elif not damaged.is_empty() and _is_riposte_attack_name(_current_attack_name):
		_add_flow_from_riposte_hit()
		_show_riposte_hit_message()
		_register_blood_scent_success()
		if _current_attack_name == &"vesper_counter":
			vesper_counter_hit.emit()
		else:
			riposte_hit.emit()
	elif not damaged.is_empty() and _is_just_dodge_counter_attack_name(_current_attack_name):
		_show_just_dodge_counter_hit_message()
		_register_blood_scent_success()
		just_dodge_counter_hit.emit()
	elif not damaged.is_empty() and _is_vesper_art_attack_name(_current_attack_name):
		_confirm_vesper_art_hit()

	for target in damaged:
		if not _attack_damaged_targets.has(target):
			_attack_damaged_targets.append(target)
			_spawn_hit_vfx_for_target(target)
			_add_combo_from_attack_hit(target)
			if not _is_blood_rend_attack_name(_current_attack_name):
				_add_flow_from_attack_hit(target)
			if _is_just_dodge_counter_attack_name(_current_attack_name):
				if target.has_method("receive_just_dodge_counter_stun"):
					target.call("receive_just_dodge_counter_stun", just_dodge_counter_enemy_stun_time)
				elif target.has_method("receive_parry_stun"):
					target.call("receive_parry_stun", just_dodge_counter_enemy_stun_time)
			elif not _is_blood_rend_attack_name(_current_attack_name) and target.has_method("receive_player_attack_hit"):
				var interrupt_attack_name := &"heavy" if _counts_as_heavy_interrupt_attack(_current_attack_name) else _current_attack_name
				target.call("receive_player_attack_hit", interrupt_attack_name, self)

	if not damaged.is_empty():
		_grant_blood_rend_ready_from_attack_hit()
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
	elif _current_attack_name == &"riposte":
		kind = HitVfx.HitKind.RIPOSTE
		scale = riposte_hit_vfx_scale
	elif _current_attack_name == &"vesper_counter":
		kind = HitVfx.HitKind.VESPER_COUNTER
		scale = vesper_counter_hit_vfx_scale
	elif _current_attack_name == &"vesper_art":
		kind = HitVfx.HitKind.VESPER_ART
		scale = vesper_art_hit_vfx_scale
	elif _current_attack_name == &"just_dodge_counter":
		kind = HitVfx.HitKind.JUST_DODGE
		scale = just_dodge_counter_vfx_scale
	elif _current_attack_name == &"blood_rend":
		kind = HitVfx.HitKind.HEAVY
		scale = blood_rend_vfx_scale

	hit_vfx.configure(kind, scale, hit_vfx_lifetime)

	var parent := get_tree().current_scene
	if parent == null:
		parent = get_parent()
	if parent == null:
		hit_vfx.queue_free()
		return

	parent.add_child(hit_vfx)
	hit_vfx.global_position = target_3d.global_position + Vector3.UP * hit_vfx_vertical_offset

func _record_attack_start() -> void:
	var now := Time.get_ticks_msec() / 1000.0
	_recent_attack_times.append(now)
	_prune_recent_attack_times(now, recent_attack_history_duration)

func _prune_recent_attack_times(now: float, keep_duration: float) -> void:
	while not _recent_attack_times.is_empty() and now - _recent_attack_times[0] > keep_duration:
		_recent_attack_times.remove_at(0)

func _clear_attack_state() -> void:
	_attack_phase = AttackPhase.NONE
	_attack_phase_remaining = 0.0
	_current_attack_name = &""
	_current_attack_damage = 0.0
	_current_attack_range = 0.0
	_current_attack_radius = 0.0
	_current_attack_active = 0.0
	_current_attack_recovery = 0.0
	_vesper_art_hit_confirmed = false
	_attack_damaged_targets.clear()
	_set_attack_hitbox_enabled(false)
	_apply_debug_color()

func _clear_parry_state() -> void:
	_parry_phase = ParryPhase.NONE
	_parry_phase_remaining = 0.0
	_apply_debug_color()

func _get_current_attack_damage() -> float:
	if _current_attack_name == &"vesper_counter":
		return _current_attack_damage * vesper_counter_damage_multiplier
	if _current_attack_name == &"riposte":
		return _current_attack_damage * riposte_damage_multiplier
	if _current_attack_name == &"vesper_art":
		return _current_attack_damage * vesper_art_damage_multiplier
	if _current_attack_name == &"just_dodge_counter":
		return _current_attack_damage * just_dodge_counter_damage_multiplier
	if _current_attack_name == &"blood_rend":
		return _current_attack_damage

	return _current_attack_damage

func _try_blood_rend_attack() -> void:
	if not is_blood_rend_ready():
		return
	if health.current_health <= maxf(0.0, blood_rend_min_survive_hp):
		_show_blood_rend_blocked_message()
		return
	if _is_parrying() or _dodge_remaining > 0.0:
		return

	if _is_attacking():
		_clear_attack_state()

	if not _try_attack(
		&"blood_rend",
		blood_rend_damage,
		blood_rend_range,
		blood_rend_radius,
		0.0,
		blood_rend_windup,
		blood_rend_active,
		blood_rend_recovery
	):
		return

	blood_rend_used.emit()
	_clear_blood_rend_ready()

func _on_blood_rend_hit() -> void:
	var blood_cost := _apply_blood_rend_self_damage()
	_start_blood_scent()
	_clear_blood_rend_ready()
	_show_blood_rend_hit_message()
	blood_rend_hit.emit(blood_cost)

func _apply_blood_rend_self_damage() -> float:
	var minimum_health := maxf(0.0, blood_rend_min_survive_hp)
	var available_health := maxf(0.0, health.current_health - minimum_health)
	var actual_cost := minf(maxf(0.0, blood_rend_self_damage), available_health)
	if actual_cost <= 0.0:
		return 0.0

	_blood_rend_self_damage_pending += actual_cost
	health.take_damage(actual_cost)
	return actual_cost

func _grant_blood_rend_ready_from_attack_hit() -> void:
	if not _can_current_attack_grant_blood_rend_ready():
		return
	if blood_rend_ready_duration <= 0.0:
		_blood_rend_ready_time_remaining = 0.0
		return

	_blood_rend_ready_time_remaining = blood_rend_ready_duration
	_show_blood_rend_ready_message()
	_apply_debug_color()

func _can_current_attack_grant_blood_rend_ready() -> bool:
	return _current_attack_name == &"light" or _current_attack_name == &"just_dodge_counter" or _current_attack_name == &"riposte" or _current_attack_name == &"vesper_counter"

func _clear_blood_rend_ready() -> void:
	if _blood_rend_ready_time_remaining <= 0.0:
		return

	_blood_rend_ready_time_remaining = 0.0
	_apply_debug_color()

func _start_blood_scent() -> void:
	_blood_scent_time_remaining = maxf(0.0, blood_scent_duration)
	_apply_debug_color()

func _end_blood_scent() -> void:
	if _blood_scent_time_remaining <= 0.0:
		return

	_blood_scent_time_remaining = 0.0
	_apply_debug_color()

func _register_blood_scent_success() -> void:
	if not is_blood_scent_active():
		return

	_add_flow_from_blood_scent_success()
	blood_scent_success.emit()

func _try_just_dodge_counter_attack() -> void:
	if not _is_just_dodge_counter_ready():
		return

	if not _try_attack(
		&"just_dodge_counter",
		light_attack_damage,
		light_attack_range,
		light_attack_radius,
		just_dodge_counter_stamina_cost,
		just_dodge_counter_windup,
		just_dodge_counter_active,
		just_dodge_counter_recovery
	):
		return

	_clear_just_dodge_counter_ready()
	_just_dodge_counter_recent_time_remaining = just_dodge_counter_recent_display_time

func _try_vesper_art_attack() -> void:
	if _try_attack(
		&"vesper_art",
		heavy_attack_damage,
		heavy_attack_range,
		heavy_attack_radius,
		heavy_attack_stamina_cost,
		vesper_art_windup,
		vesper_art_active,
		vesper_art_recovery
	):
		vesper_art_used.emit()

func _try_riposte_attack() -> void:
	var attack_name := &"vesper_counter" if parry_stock >= get_vesper_counter_required_stock() else &"riposte"
	if not _try_attack(
		attack_name,
		heavy_attack_damage,
		heavy_attack_range,
		heavy_attack_radius,
		heavy_attack_stamina_cost,
		riposte_windup,
		riposte_active,
		riposte_recovery
	):
		return

	if attack_name == &"vesper_counter":
		parry_stock = 0
	else:
		parry_stock = maxi(0, parry_stock - 1)

	_clear_riposte_ready()

func _is_riposte_ready() -> bool:
	return _riposte_time_remaining > 0.0 and parry_stock >= 1

func _is_just_dodge_counter_ready() -> bool:
	return _just_dodge_counter_time_remaining > 0.0 and not health.is_dead() and _controls_enabled

func _is_riposte_attack_name(attack_name: StringName) -> bool:
	return attack_name == &"riposte" or attack_name == &"vesper_counter"

func _is_vesper_art_attack_name(attack_name: StringName) -> bool:
	return attack_name == &"vesper_art"

func _is_just_dodge_counter_attack_name(attack_name: StringName) -> bool:
	return attack_name == &"just_dodge_counter"

func _is_blood_rend_attack_name(attack_name: StringName) -> bool:
	return attack_name == &"blood_rend"

func _counts_as_heavy_interrupt_attack(attack_name: StringName) -> bool:
	return _is_riposte_attack_name(attack_name) or _is_vesper_art_attack_name(attack_name)

func _can_use_vesper_art() -> bool:
	if health.is_dead() or not _controls_enabled or _is_riposte_ready():
		return false

	if _flow_tracker == null or not is_instance_valid(_flow_tracker):
		_resolve_flow_tracker()

	return _flow_tracker != null and _flow_tracker.can_spend(vesper_art_flow_cost)

func _grant_riposte_ready() -> void:
	parry_stock = mini(maxi(1, parry_stock + 1), get_parry_stock_max())
	if riposte_window > 0.0:
		_riposte_time_remaining = riposte_window
		_show_riposte_ready_message()
	else:
		_riposte_time_remaining = 0.0

	_apply_debug_color()

func _clear_riposte_ready() -> void:
	_riposte_time_remaining = 0.0
	_apply_debug_color()

func _grant_just_dodge_counter_ready() -> void:
	if just_dodge_counter_window > 0.0:
		_just_dodge_counter_time_remaining = just_dodge_counter_window
		_show_just_dodge_counter_ready_message()
	else:
		_just_dodge_counter_time_remaining = 0.0

	_apply_debug_color()

func _clear_just_dodge_counter_ready() -> void:
	if _just_dodge_counter_time_remaining <= 0.0:
		return

	_just_dodge_counter_time_remaining = 0.0
	_apply_debug_color()

func _reset_parry_reward_state() -> void:
	parry_stock = 0
	_riposte_time_remaining = 0.0
	_apply_debug_color()

func _reset_deflect_state() -> void:
	_deflect_chain_count = 0
	_max_deflect_chain = 0
	_deflect_chain_time_remaining = 0.0
	_deflect_count = 0
	_normal_parry_count = 0
	_parry_fail_count = 0
	_last_parry_result = "None"

func _reset_current_deflect_chain() -> void:
	_deflect_chain_count = 0
	_deflect_chain_time_remaining = 0.0

func _register_deflect_chain() -> void:
	if _deflect_chain_time_remaining > 0.0:
		_deflect_chain_count += 1
	else:
		_deflect_chain_count = 1

	_max_deflect_chain = maxi(_max_deflect_chain, _deflect_chain_count)
	_deflect_chain_time_remaining = maxf(0.0, deflect_chain_timeout)

func _update_deflect_chain(delta: float) -> void:
	if _deflect_chain_time_remaining <= 0.0:
		return

	_deflect_chain_time_remaining = maxf(0.0, _deflect_chain_time_remaining - delta)
	if _deflect_chain_time_remaining <= 0.0:
		_deflect_chain_count = 0

func _get_parry_response(attacker: Node) -> Dictionary:
	if attacker != null and attacker.has_method("get_current_parry_response"):
		var response = attacker.call("get_current_parry_response")
		if response is Dictionary:
			return response

	return {
		"parry_stops_enemy": true,
		"parry_grants_riposte": true,
		"is_rhythm_deflect": false,
		"deflect_flow_gain": 0.0,
		"parry_flow_gain": 0.0
	}

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
		&"vesper_counter":
			_hit_stop.request_hit_stop(vesper_counter_hit_stop_duration)
		&"riposte":
			_hit_stop.request_hit_stop(riposte_hit_stop_duration)
		&"vesper_art":
			_hit_stop.request_hit_stop(vesper_art_hit_stop)
		&"just_dodge_counter":
			_hit_stop.request_hit_stop(just_dodge_counter_hit_stop_duration)
		&"blood_rend":
			_hit_stop.request_hit_stop(blood_rend_hit_stop_duration)
		&"heavy":
			_hit_stop.request_heavy_attack_hit_stop()
		_:
			_hit_stop.request_light_attack_hit_stop()

func _request_parry_hit_stop() -> void:
	if _hit_stop == null or not is_instance_valid(_hit_stop):
		_resolve_hit_stop()

	if _hit_stop == null:
		return

	_hit_stop.request_hit_stop(parry_hit_stop_duration)

func _request_deflect_hit_stop() -> void:
	if _hit_stop == null or not is_instance_valid(_hit_stop):
		_resolve_hit_stop()

	if _hit_stop == null:
		return

	_hit_stop.request_hit_stop(deflect_hit_stop_duration)

func _request_just_dodge_hit_stop() -> void:
	if _hit_stop == null or not is_instance_valid(_hit_stop):
		_resolve_hit_stop()

	if _hit_stop == null:
		return

	_hit_stop.request_hit_stop(just_dodge_hit_stop_duration)

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
		&"vesper_counter":
			_camera_follow.request_shake(vesper_counter_camera_shake_strength, vesper_counter_camera_shake_duration)
		&"riposte":
			_camera_follow.request_shake(riposte_camera_shake_strength, riposte_camera_shake_duration)
		&"vesper_art":
			_camera_follow.request_shake(vesper_art_camera_shake, vesper_art_camera_shake_duration)
		&"just_dodge_counter":
			_camera_follow.request_shake(just_dodge_counter_camera_shake_strength, just_dodge_counter_camera_shake_duration)
		&"blood_rend":
			_camera_follow.request_shake(blood_rend_camera_shake_strength, blood_rend_camera_shake_duration)
		&"heavy":
			_camera_follow.request_heavy_attack_shake()
		_:
			_camera_follow.request_light_attack_shake()

func _request_parry_camera_shake() -> void:
	if _camera_follow == null or not is_instance_valid(_camera_follow):
		_resolve_camera_follow()

	if _camera_follow == null:
		return

	_camera_follow.request_shake(parry_shake_strength, parry_shake_duration)

func _request_deflect_camera_shake() -> void:
	if _camera_follow == null or not is_instance_valid(_camera_follow):
		_resolve_camera_follow()

	if _camera_follow == null:
		return

	_camera_follow.request_shake(deflect_shake_strength, deflect_shake_duration)

func _request_just_dodge_camera_shake() -> void:
	if _camera_follow == null or not is_instance_valid(_camera_follow):
		_resolve_camera_follow()

	if _camera_follow == null:
		return

	_camera_follow.request_shake(just_dodge_camera_shake_strength, just_dodge_camera_shake_duration)

func _spawn_parry_vfx(attacker: Node, scale_override: float = -1.0) -> void:
	if hit_vfx_scene == null:
		return

	var hit_vfx := hit_vfx_scene.instantiate() as HitVfx
	if hit_vfx == null:
		return

	var vfx_scale := parry_hit_vfx_scale if scale_override <= 0.0 else scale_override
	hit_vfx.configure(HitVfx.HitKind.PARRY, vfx_scale, hit_vfx_lifetime)

	var parent := get_tree().current_scene
	if parent == null:
		parent = get_parent()
	if parent == null:
		hit_vfx.queue_free()
		return

	parent.add_child(hit_vfx)

	var target_3d := attacker as Node3D
	var vfx_position := global_position
	if target_3d != null:
		vfx_position = global_position.lerp(target_3d.global_position, 0.45)
	hit_vfx.global_position = vfx_position + Vector3.UP * hit_vfx_vertical_offset

func _spawn_just_dodge_vfx(impact_position: Vector3) -> void:
	if hit_vfx_scene == null:
		return

	var hit_vfx := hit_vfx_scene.instantiate() as HitVfx
	if hit_vfx == null:
		return

	hit_vfx.configure(HitVfx.HitKind.JUST_DODGE, just_dodge_vfx_scale, hit_vfx_lifetime)

	var parent := get_tree().current_scene
	if parent == null:
		parent = get_parent()
	if parent == null:
		hit_vfx.queue_free()
		return

	parent.add_child(hit_vfx)
	var vfx_position := global_position
	if impact_position != Vector3.ZERO:
		vfx_position = global_position.lerp(impact_position, 0.35)
	hit_vfx.global_position = vfx_position + Vector3.UP * hit_vfx_vertical_offset

func _resolve_combat_ui() -> void:
	if combat_ui_path != NodePath(""):
		_combat_ui = get_node_or_null(combat_ui_path) as CombatUI

	if _combat_ui == null:
		_combat_ui = get_tree().get_first_node_in_group(&"combat_ui") as CombatUI

func _show_parry_message() -> void:
	if _combat_ui == null or not is_instance_valid(_combat_ui):
		_resolve_combat_ui()

	if _combat_ui != null:
		_combat_ui.show_temporary_message(parry_message)

func _show_deflect_message() -> void:
	if _combat_ui == null or not is_instance_valid(_combat_ui):
		_resolve_combat_ui()

	if _combat_ui != null:
		var message := deflect_message
		if _deflect_chain_count >= 2:
			message = "DEFLECT x%d" % _deflect_chain_count
		_combat_ui.show_temporary_message(message, deflect_message_duration)

func _show_riposte_ready_message() -> void:
	if _combat_ui == null or not is_instance_valid(_combat_ui):
		_resolve_combat_ui()

	if _combat_ui != null:
		var message := vesper_counter_ready_message if parry_stock >= get_vesper_counter_required_stock() else riposte_ready_message
		_combat_ui.show_temporary_message(message, riposte_ready_message_duration)

func _show_riposte_hit_message() -> void:
	if _combat_ui == null or not is_instance_valid(_combat_ui):
		_resolve_combat_ui()

	if _combat_ui != null:
		var message := vesper_counter_hit_message if _current_attack_name == &"vesper_counter" else riposte_hit_message
		_combat_ui.show_temporary_message(message)

func _show_just_dodge_counter_ready_message() -> void:
	if _combat_ui == null or not is_instance_valid(_combat_ui):
		_resolve_combat_ui()

	if _combat_ui != null:
		_combat_ui.show_temporary_message(just_dodge_counter_ready_message, just_dodge_counter_message_duration)

func _show_just_dodge_counter_hit_message() -> void:
	if _combat_ui == null or not is_instance_valid(_combat_ui):
		_resolve_combat_ui()

	if _combat_ui != null:
		_combat_ui.show_temporary_message(just_dodge_counter_hit_message, just_dodge_counter_message_duration)

func _show_vesper_art_hit_message() -> void:
	if _combat_ui == null or not is_instance_valid(_combat_ui):
		_resolve_combat_ui()

	if _combat_ui != null:
		_combat_ui.show_temporary_message(vesper_art_hit_message, vesper_art_message_duration)

func _show_just_dodge_message() -> void:
	if _combat_ui == null or not is_instance_valid(_combat_ui):
		_resolve_combat_ui()

	if _combat_ui != null:
		_combat_ui.show_temporary_message(just_dodge_message, just_dodge_message_duration)

func _show_blood_rend_ready_message() -> void:
	if _combat_ui == null or not is_instance_valid(_combat_ui):
		_resolve_combat_ui()

	if _combat_ui != null:
		_combat_ui.show_temporary_message(blood_rend_ready_message, blood_rend_message_duration)

func _show_blood_rend_hit_message() -> void:
	if _combat_ui == null or not is_instance_valid(_combat_ui):
		_resolve_combat_ui()

	if _combat_ui != null:
		_combat_ui.show_temporary_message(blood_rend_hit_message, blood_rend_message_duration)

func _show_blood_rend_blocked_message() -> void:
	if _combat_ui == null or not is_instance_valid(_combat_ui):
		_resolve_combat_ui()

	if _combat_ui != null:
		_combat_ui.show_temporary_message(blood_rend_blocked_message, blood_rend_message_duration)

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

func _add_combo_from_attack_hit(target: Node) -> void:
	var target_health := target.get_node_or_null("Health") as Health
	if target_health == null or target_health.is_dead():
		return

	if _combo_tracker == null or not is_instance_valid(_combo_tracker):
		_resolve_combo_tracker()

	if _combo_tracker != null:
		if _current_attack_name == &"vesper_counter":
			_combo_tracker.add_hit(1, vesper_counter_combo_extend_time)
		elif _current_attack_name == &"vesper_art":
			_combo_tracker.add_hit(1, vesper_art_combo_extend_time)
		else:
			_combo_tracker.add_hit()

func _add_combo_from_parry() -> void:
	if _combo_tracker == null or not is_instance_valid(_combo_tracker):
		_resolve_combo_tracker()

	if _combo_tracker != null:
		_combo_tracker.add_hit()

func _add_combo_from_just_dodge() -> void:
	if _combo_tracker == null or not is_instance_valid(_combo_tracker):
		_resolve_combo_tracker()

	if _combo_tracker == null:
		return

	if just_dodge_combo_bonus > 0:
		_combo_tracker.add_hit(just_dodge_combo_bonus, just_dodge_combo_extend_time)
	else:
		_combo_tracker.extend_combo(just_dodge_combo_extend_time)

func _add_flow_from_parry(flow_gain: float = 0.0) -> void:
	if _flow_tracker == null or not is_instance_valid(_flow_tracker):
		_resolve_flow_tracker()

	if _flow_tracker != null:
		if flow_gain > 0.0:
			_flow_tracker.add_flow(flow_gain, "PARRY")
		else:
			_flow_tracker.add_parry_flow()

func _add_flow_from_deflect(flow_gain: float = 0.0) -> void:
	if _flow_tracker == null or not is_instance_valid(_flow_tracker):
		_resolve_flow_tracker()

	if _flow_tracker == null:
		return

	if _flow_tracker.has_method("add_deflect_flow"):
		_flow_tracker.call("add_deflect_flow", _deflect_chain_count, flow_gain)
	else:
		_flow_tracker.add_flow(flow_gain, "DEFLECT")

func _add_flow_from_just_dodge() -> void:
	if _flow_tracker == null or not is_instance_valid(_flow_tracker):
		_resolve_flow_tracker()

	if _flow_tracker != null:
		_flow_tracker.add_just_dodge_flow()

func _confirm_vesper_art_hit() -> void:
	if not _controls_enabled or _vesper_art_hit_confirmed:
		return

	_vesper_art_hit_confirmed = true
	_spend_vesper_art_flow(vesper_art_flow_cost, "VESPER ART")
	_show_vesper_art_hit_message()
	vesper_art_hit.emit()

func _spend_vesper_art_miss_cost_if_needed() -> void:
	if not _is_vesper_art_attack_name(_current_attack_name) or _vesper_art_hit_confirmed:
		return

	_spend_vesper_art_flow(vesper_art_miss_flow_cost, "VESPER ART MISS")
	vesper_art_missed.emit()

func _spend_vesper_art_flow(amount: float, reason: String) -> void:
	if amount <= 0.0:
		return
	if _flow_tracker == null or not is_instance_valid(_flow_tracker):
		_resolve_flow_tracker()

	if _flow_tracker != null:
		_flow_tracker.lose_flow(amount, reason)

func _add_flow_from_attack_hit(_target: Node) -> void:
	if _flow_tracker == null or not is_instance_valid(_flow_tracker):
		_resolve_flow_tracker()

	if _flow_tracker == null:
		return

	if _current_attack_name == &"light":
		_flow_tracker.add_light_attack_hit_flow()
	elif _current_attack_name == &"heavy":
		_flow_tracker.add_heavy_attack_hit_flow()
	elif _current_attack_name == &"just_dodge_counter":
		_flow_tracker.add_flow(just_dodge_counter_flow_gain, "JUST COUNTER")

func _add_flow_from_riposte_hit() -> void:
	if _flow_tracker == null or not is_instance_valid(_flow_tracker):
		_resolve_flow_tracker()

	if _flow_tracker == null:
		return

	if _current_attack_name == &"vesper_counter":
		_flow_tracker.add_vesper_counter_hit_flow()
	else:
		_flow_tracker.add_riposte_hit_flow()

func _add_flow_from_blood_scent_success() -> void:
	if _flow_tracker == null or not is_instance_valid(_flow_tracker):
		_resolve_flow_tracker()

	if _flow_tracker == null:
		return

	if _flow_tracker.has_method("add_blood_scent_success_flow"):
		_flow_tracker.call("add_blood_scent_success_flow")

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

func _get_parry_move_speed_multiplier() -> float:
	match _parry_phase:
		ParryPhase.STARTUP:
			return parry_startup_move_speed_multiplier
		ParryPhase.ACTIVE:
			return parry_active_move_speed_multiplier
		ParryPhase.RECOVERY:
			return parry_recovery_move_speed_multiplier
		_:
			return 1.0

func _is_attacking() -> bool:
	return _attack_phase != AttackPhase.NONE

func _is_parrying() -> bool:
	return _parry_phase != ParryPhase.NONE

func _setup_body_material() -> void:
	if body_mesh == null:
		return

	var material := body_mesh.get_active_material(0)
	if material is StandardMaterial3D:
		_body_material = (material as StandardMaterial3D).duplicate() as StandardMaterial3D
		body_mesh.set_surface_override_material(0, _body_material)

func _setup_parry_visual_material() -> void:
	if parry_visual == null:
		return

	var material := parry_visual.get_active_material(0)
	if material is StandardMaterial3D:
		_parry_visual_material = (material as StandardMaterial3D).duplicate() as StandardMaterial3D
		parry_visual.set_surface_override_material(0, _parry_visual_material)

	parry_visual.visible = false

func _apply_debug_color() -> void:
	_apply_body_debug_color()
	_apply_parry_visual()

func _apply_body_debug_color() -> void:
	if not debug_attack_state_colors or _body_material == null:
		return

	if _is_parrying():
		match _parry_phase:
			ParryPhase.STARTUP:
				_body_material.albedo_color = parry_startup_body_color
			ParryPhase.ACTIVE:
				_body_material.albedo_color = parry_active_body_color
			ParryPhase.RECOVERY:
				_body_material.albedo_color = parry_recovery_body_color
		return

	if _is_riposte_ready() and _attack_phase == AttackPhase.NONE:
		_body_material.albedo_color = vesper_ready_body_color if parry_stock >= get_vesper_counter_required_stock() else riposte_ready_body_color
		return

	if _is_just_dodge_counter_ready() and _attack_phase == AttackPhase.NONE:
		_body_material.albedo_color = just_dodge_counter_ready_body_color
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

func _apply_parry_visual() -> void:
	if parry_visual == null:
		return

	parry_visual.visible = _is_parrying() or _is_riposte_ready()
	if _parry_visual_material == null:
		return

	if _is_riposte_ready() and not _is_parrying():
		var ready_color := vesper_ready_ring_color if parry_stock >= get_vesper_counter_required_stock() else riposte_ready_ring_color
		_parry_visual_material.albedo_color = ready_color
		_parry_visual_material.emission = Color(ready_color.r, ready_color.g, ready_color.b, 1.0)
		_parry_visual_material.emission_energy_multiplier = 0.75 if parry_stock >= get_vesper_counter_required_stock() else 0.55
		return

	match _parry_phase:
		ParryPhase.ACTIVE:
			_parry_visual_material.albedo_color = parry_active_ring_color
			_parry_visual_material.emission = Color(parry_active_ring_color.r, parry_active_ring_color.g, parry_active_ring_color.b, 1.0)
			_parry_visual_material.emission_energy_multiplier = 0.85
		ParryPhase.RECOVERY:
			_parry_visual_material.albedo_color = parry_recovery_ring_color
			_parry_visual_material.emission = Color(parry_recovery_ring_color.r, parry_recovery_ring_color.g, parry_recovery_ring_color.b, 1.0)
			_parry_visual_material.emission_energy_multiplier = 0.25
		_:
			_parry_visual_material.albedo_color = parry_active_ring_color
			_parry_visual_material.emission = Color(parry_active_ring_color.r, parry_active_ring_color.g, parry_active_ring_color.b, 1.0)
			_parry_visual_material.emission_energy_multiplier = 0.45

func set_control_enabled(value: bool) -> void:
	_controls_enabled = value
	if not _controls_enabled:
		_move_direction = Vector3.ZERO
		_dodge_direction = Vector3.ZERO
		_dodge_remaining = 0.0
		_dodge_invulnerable_remaining = 0.0
		_just_dodge_remaining = 0.0
		_just_dodge_counter_time_remaining = 0.0
		_just_dodge_counter_recent_time_remaining = 0.0
		_blood_rend_ready_time_remaining = 0.0
		_blood_scent_time_remaining = 0.0
		_blood_rend_self_damage_pending = 0.0
		velocity = Vector3.ZERO
		_reset_parry_reward_state()
		_reset_deflect_state()
		_clear_attack_state()
		_clear_parry_state()

func reset_combat_state() -> void:
	_controls_enabled = true
	velocity = Vector3.ZERO
	_move_direction = Vector3.ZERO
	_last_facing = Vector3.FORWARD
	_dodge_direction = Vector3.ZERO
	_dodge_remaining = 0.0
	_dodge_invulnerable_remaining = 0.0
	_just_dodge_remaining = 0.0
	_just_dodge_counter_time_remaining = 0.0
	_just_dodge_counter_recent_time_remaining = 0.0
	_blood_rend_ready_time_remaining = 0.0
	_blood_scent_time_remaining = 0.0
	_blood_rend_self_damage_pending = 0.0
	_attack_direction = Vector3.FORWARD
	_recent_attack_times.clear()
	_reset_parry_reward_state()
	_reset_deflect_state()
	_clear_attack_state()
	_clear_parry_state()
