extends CanvasLayer
class_name CombatUI

@export var player_group: StringName = &"player"
@export var enemy_group: StringName = &"enemy"
@export var combo_tracker_group: StringName = &"combo_tracker"
@export var flow_tracker_group: StringName = &"flow_tracker"
@export var temporary_message_duration: float = 0.55

@export_group("Combo Display")
@export var combo_display_scale: float = 1.0
@export var combo_punch_scale: float = 1.14
@export var combo_punch_return_speed: float = 14.0

@onready var player_hp_label: Label = $Panel/Margin/Stats/PlayerHP
@onready var enemy_hp_label: Label = $Panel/Margin/Stats/EnemyHP
@onready var stamina_label: Label = $Panel/Margin/Stats/Stamina
@onready var flow_label: Label = $Panel/Margin/Stats/Flow
@onready var parry_stock_label: Label = $Panel/Margin/Stats/ParryStock
@onready var riposte_status_label: Label = $Panel/Margin/Stats/RiposteStatus
@onready var combo_display: Control = $ComboDisplay
@onready var combo_hit_label: Label = $ComboDisplay/HitCount
@onready var combo_rating_label: Label = $ComboDisplay/Rating
@onready var death_overlay: Control = $DeathOverlay
@onready var death_title_label: Label = $DeathOverlay/Center/Box/Title
@onready var death_instructions_label: Label = $DeathOverlay/Center/Box/Instructions
@onready var temporary_message_label: Label = $TemporaryMessage
@onready var flow_popup_label: Label = $FlowPopup

var _player: PlayerController
var _player_health: Health
var _enemy_health: Health
var _player_stamina: Stamina
var _combo_tracker: ComboTracker
var _flow_tracker: FlowTracker
var _temporary_message_time_remaining: float = 0.0
var _flow_popup_time_remaining: float = 0.0

func _ready() -> void:
	set_end_overlay_visible(false)
	clear_temporary_message()
	clear_flow_popup()
	clear_combo_display()
	call_deferred("_bind_combatants")
	call_deferred("_bind_combo_tracker")
	call_deferred("_bind_flow_tracker")

func _process(delta: float) -> void:
	if _player_health == null or _enemy_health == null or _player_stamina == null:
		_bind_combatants()

	if _combo_tracker == null or not is_instance_valid(_combo_tracker):
		_bind_combo_tracker()

	if _flow_tracker == null or not is_instance_valid(_flow_tracker):
		_bind_flow_tracker()

	_update_labels()
	_update_temporary_message(delta)
	_update_flow_popup(delta)
	_update_combo_punch(delta)

func set_end_overlay_visible(is_visible: bool, title: String = "", instructions: String = "") -> void:
	if death_overlay == null:
		return

	death_overlay.visible = is_visible
	death_title_label.text = title
	death_instructions_label.text = instructions

func set_death_visible(is_visible: bool, title: String = "YOU DIED", instructions: String = "Press R to retry") -> void:
	set_end_overlay_visible(is_visible, title, instructions)

func show_temporary_message(message: String, duration: float = -1.0) -> void:
	if temporary_message_label == null:
		return

	temporary_message_label.text = message
	temporary_message_label.visible = true
	_temporary_message_time_remaining = temporary_message_duration if duration <= 0.0 else duration

func clear_temporary_message() -> void:
	_temporary_message_time_remaining = 0.0
	if temporary_message_label != null:
		temporary_message_label.visible = false
		temporary_message_label.text = ""

func show_flow_popup(message: String, duration: float) -> void:
	if flow_popup_label == null:
		return

	flow_popup_label.text = message
	flow_popup_label.visible = true
	_flow_popup_time_remaining = maxf(0.0, duration)

func clear_flow_popup() -> void:
	_flow_popup_time_remaining = 0.0
	if flow_popup_label != null:
		flow_popup_label.visible = false
		flow_popup_label.text = ""

func clear_combo_display() -> void:
	if combo_display == null:
		return

	combo_display.visible = false
	combo_display.scale = Vector2.ONE * combo_display_scale
	combo_hit_label.text = ""
	combo_rating_label.text = ""

func _update_temporary_message(delta: float) -> void:
	if _temporary_message_time_remaining <= 0.0:
		return

	_temporary_message_time_remaining = maxf(0.0, _temporary_message_time_remaining - delta)
	if _temporary_message_time_remaining <= 0.0:
		clear_temporary_message()

func _update_flow_popup(delta: float) -> void:
	if _flow_popup_time_remaining <= 0.0:
		return

	_flow_popup_time_remaining = maxf(0.0, _flow_popup_time_remaining - delta)
	if _flow_popup_time_remaining <= 0.0:
		clear_flow_popup()

func _update_combo_punch(delta: float) -> void:
	if combo_display == null or not combo_display.visible:
		return

	var target_scale := Vector2.ONE * combo_display_scale
	combo_display.scale = combo_display.scale.lerp(target_scale, 1.0 - exp(-combo_punch_return_speed * delta))

func _bind_combatants() -> void:
	var player := get_tree().get_first_node_in_group(player_group)
	if player != null:
		_player = player as PlayerController
		_player_health = player.get_node_or_null("Health") as Health
		_player_stamina = player.get_node_or_null("Stamina") as Stamina

	var enemy := get_tree().get_first_node_in_group(enemy_group)
	if enemy != null:
		_enemy_health = enemy.get_node_or_null("Health") as Health

func _bind_combo_tracker() -> void:
	var combo_tracker := get_tree().get_first_node_in_group(combo_tracker_group) as ComboTracker
	if combo_tracker == _combo_tracker:
		return

	if _combo_tracker != null and _combo_tracker.combo_changed.is_connected(_on_combo_changed):
		_combo_tracker.combo_changed.disconnect(_on_combo_changed)

	_combo_tracker = combo_tracker
	if _combo_tracker == null:
		clear_combo_display()
		return

	if not _combo_tracker.combo_changed.is_connected(_on_combo_changed):
		_combo_tracker.combo_changed.connect(_on_combo_changed)

	_on_combo_changed(_combo_tracker.combo_count, _combo_tracker.get_rating_text())

func _bind_flow_tracker() -> void:
	var flow_tracker := get_tree().get_first_node_in_group(flow_tracker_group) as FlowTracker
	if flow_tracker == _flow_tracker:
		return

	if _flow_tracker != null:
		if _flow_tracker.flow_changed.is_connected(_on_flow_changed):
			_flow_tracker.flow_changed.disconnect(_on_flow_changed)
		if _flow_tracker.flow_popup_requested.is_connected(_on_flow_popup_requested):
			_flow_tracker.flow_popup_requested.disconnect(_on_flow_popup_requested)

	_flow_tracker = flow_tracker
	if _flow_tracker == null:
		_on_flow_changed(0.0, 0.0)
		return

	if not _flow_tracker.flow_changed.is_connected(_on_flow_changed):
		_flow_tracker.flow_changed.connect(_on_flow_changed)
	if not _flow_tracker.flow_popup_requested.is_connected(_on_flow_popup_requested):
		_flow_tracker.flow_popup_requested.connect(_on_flow_popup_requested)

	_on_flow_changed(_flow_tracker.current_flow, _flow_tracker.max_flow)

func _on_flow_changed(current_flow: float, max_flow: float) -> void:
	if flow_label == null:
		return

	flow_label.text = "FLOW: %d / %d" % [int(round(current_flow)), int(round(max_flow))]

func _on_flow_popup_requested(message: String, duration: float) -> void:
	show_flow_popup(message, duration)

func _on_combo_changed(combo_count: int, rating_text: String) -> void:
	var minimum_visible_combo := 2
	if _combo_tracker != null:
		minimum_visible_combo = _combo_tracker.minimum_visible_combo

	if combo_count < minimum_visible_combo:
		clear_combo_display()
		return

	combo_hit_label.text = "%d HIT" % combo_count
	combo_rating_label.text = rating_text
	combo_rating_label.visible = rating_text != ""
	combo_display.visible = true
	combo_display.scale = Vector2.ONE * combo_punch_scale

func _update_labels() -> void:
	if _player_health != null:
		player_hp_label.text = "Player HP: %d / %d" % [int(ceil(_player_health.current_health)), int(ceil(_player_health.max_health))]

	if _enemy_health != null:
		enemy_hp_label.text = "Enemy HP: %d / %d" % [int(ceil(_enemy_health.current_health)), int(ceil(_enemy_health.max_health))]

	if _player_stamina != null:
		stamina_label.text = "Stamina: %d / %d" % [int(ceil(_player_stamina.current_stamina)), int(ceil(_player_stamina.max_stamina))]

	if _flow_tracker != null:
		flow_label.text = "FLOW: %d / %d" % [int(round(_flow_tracker.current_flow)), int(round(_flow_tracker.max_flow))]

	_update_parry_reward_labels()

func _update_parry_reward_labels() -> void:
	if parry_stock_label == null or riposte_status_label == null:
		return

	if _player == null or not is_instance_valid(_player):
		parry_stock_label.text = "Parry Stock: 0/3"
		riposte_status_label.visible = false
		return

	parry_stock_label.text = "Parry Stock: %d/%d" % [_player.get_parry_stock(), _player.get_parry_stock_max()]
	var player_dead := _player_health != null and _player_health.is_dead()
	var enemy_dead := _enemy_health != null and _enemy_health.is_dead()
	if _player.is_vesper_counter_ready():
		riposte_status_label.text = "VESPER COUNTER READY"
		riposte_status_label.visible = true
	elif _player.is_riposte_ready():
		riposte_status_label.text = "RIPOSTE READY"
		riposte_status_label.visible = true
	elif not player_dead and not enemy_dead and _player.is_vesper_art_ready():
		riposte_status_label.text = _player.vesper_art_ready_message
		riposte_status_label.visible = true
	else:
		riposte_status_label.visible = false
