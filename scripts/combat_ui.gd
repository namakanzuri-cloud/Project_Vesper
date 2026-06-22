extends CanvasLayer
class_name CombatUI

@export var player_group: StringName = &"player"
@export var enemy_group: StringName = &"enemy"

@onready var player_hp_label: Label = $Panel/Margin/Stats/PlayerHP
@onready var enemy_hp_label: Label = $Panel/Margin/Stats/EnemyHP
@onready var stamina_label: Label = $Panel/Margin/Stats/Stamina
@onready var death_overlay: Control = $DeathOverlay
@onready var death_title_label: Label = $DeathOverlay/Center/Box/Title
@onready var death_instructions_label: Label = $DeathOverlay/Center/Box/Instructions

var _player_health: Health
var _enemy_health: Health
var _player_stamina: Stamina

func _ready() -> void:
	set_death_visible(false)
	call_deferred("_bind_combatants")

func _process(_delta: float) -> void:
	if _player_health == null or _enemy_health == null or _player_stamina == null:
		_bind_combatants()

	_update_labels()

func set_death_visible(is_visible: bool, title: String = "YOU DIED", instructions: String = "Press R to retry") -> void:
	if death_overlay == null:
		return

	death_overlay.visible = is_visible
	death_title_label.text = title
	death_instructions_label.text = instructions

func _bind_combatants() -> void:
	var player := get_tree().get_first_node_in_group(player_group)
	if player != null:
		_player_health = player.get_node_or_null("Health") as Health
		_player_stamina = player.get_node_or_null("Stamina") as Stamina

	var enemy := get_tree().get_first_node_in_group(enemy_group)
	if enemy != null:
		_enemy_health = enemy.get_node_or_null("Health") as Health

func _update_labels() -> void:
	if _player_health != null:
		player_hp_label.text = "Player HP: %d / %d" % [int(ceil(_player_health.current_health)), int(ceil(_player_health.max_health))]

	if _enemy_health != null:
		enemy_hp_label.text = "Enemy HP: %d / %d" % [int(ceil(_enemy_health.current_health)), int(ceil(_enemy_health.max_health))]

	if _player_stamina != null:
		stamina_label.text = "Stamina: %d / %d" % [int(ceil(_player_stamina.current_stamina)), int(ceil(_player_stamina.max_stamina))]
