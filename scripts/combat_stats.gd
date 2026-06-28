extends Node
class_name CombatStats

signal stats_changed

@export_group("Rank Thresholds")
@export var rank_threshold_c: float = 30.0
@export var rank_threshold_b: float = 70.0
@export var rank_threshold_a: float = 120.0
@export var rank_threshold_s: float = 175.0
@export var rank_threshold_vesper: float = 240.0

@export_group("Score Weights")
@export var score_per_combo_hit: float = 2.0
@export var score_per_parry: float = 12.0
@export var score_per_max_deflect_chain: float = 4.0
@export var score_per_just_dodge: float = 14.0
@export var score_per_interrupt: float = 18.0
@export var score_per_riposte_hit: float = 18.0
@export var score_per_vesper_counter_hit: float = 28.0
@export var score_per_just_counter_hit: float = 20.0
@export var score_per_vesper_art_hit: float = 40.0
@export var score_per_blood_scent_success: float = 10.0
@export var score_per_final_flow: float = 0.4

@export_group("Score Penalties")
@export var score_penalty_per_damage: float = 0.6
@export var score_penalty_per_hit_taken: float = 8.0
@export var score_penalty_per_parry_fail: float = 4.0
@export var score_penalty_per_vesper_art_miss: float = 20.0

@export_group("Clear Time")
@export var clear_time_bonus_target: float = 45.0
@export var score_per_second_under_target: float = 0.75

var combat_time: float = 0.0
var damage_taken: float = 0.0
var hit_taken_count: int = 0
var max_combo: int = 0
var parry_count: int = 0
var normal_parry_count: int = 0
var rhythm_parry_count: int = 0
var deflect_count: int = 0
var max_deflect_chain: int = 0
var parry_fail_count: int = 0
var just_dodge_count: int = 0
var interrupt_count: int = 0
var riposte_hit_count: int = 0
var vesper_counter_hit_count: int = 0
var just_dodge_counter_hit_count: int = 0
var vesper_art_use_count: int = 0
var vesper_art_hit_count: int = 0
var vesper_art_miss_count: int = 0
var blood_rend_use_count: int = 0
var blood_rend_hit_count: int = 0
var blood_cost_total: float = 0.0
var blood_scent_success_count: int = 0
var blood_scent_hit_taken_count: int = 0
var final_flow: float = 0.0
var is_tracking: bool = false
var last_result_data: Dictionary = {}
var last_result_json: String = ""

func _process(delta: float) -> void:
	if not is_tracking:
		return

	combat_time += delta
	stats_changed.emit()

func reset_for_combat() -> void:
	combat_time = 0.0
	damage_taken = 0.0
	hit_taken_count = 0
	max_combo = 0
	parry_count = 0
	normal_parry_count = 0
	rhythm_parry_count = 0
	deflect_count = 0
	max_deflect_chain = 0
	parry_fail_count = 0
	just_dodge_count = 0
	interrupt_count = 0
	riposte_hit_count = 0
	vesper_counter_hit_count = 0
	just_dodge_counter_hit_count = 0
	vesper_art_use_count = 0
	vesper_art_hit_count = 0
	vesper_art_miss_count = 0
	blood_rend_use_count = 0
	blood_rend_hit_count = 0
	blood_cost_total = 0.0
	blood_scent_success_count = 0
	blood_scent_hit_taken_count = 0
	final_flow = 0.0
	is_tracking = true
	stats_changed.emit()

func finish_combat(current_flow: float) -> void:
	final_flow = maxf(0.0, current_flow)
	is_tracking = false
	stats_changed.emit()

func record_flow_changed(current_flow: float, _max_flow: float) -> void:
	if not is_tracking:
		return

	final_flow = maxf(0.0, current_flow)
	stats_changed.emit()

func record_damage_taken(amount: float) -> void:
	if not is_tracking or amount <= 0.0:
		return

	damage_taken += amount
	hit_taken_count += 1
	stats_changed.emit()

func record_combo_changed(combo_count: int, _rating_text: String = "") -> void:
	if not is_tracking:
		return

	max_combo = maxi(max_combo, combo_count)
	stats_changed.emit()

func record_parry() -> void:
	if not is_tracking:
		return

	parry_count += 1
	stats_changed.emit()

func record_normal_parry() -> void:
	if not is_tracking:
		return

	normal_parry_count += 1
	stats_changed.emit()

func record_deflect(chain_count: int = 1) -> void:
	if not is_tracking:
		return

	rhythm_parry_count += 1
	deflect_count += 1
	max_deflect_chain = maxi(max_deflect_chain, chain_count)
	stats_changed.emit()

func record_parry_fail() -> void:
	if not is_tracking:
		return

	parry_fail_count += 1
	stats_changed.emit()

func record_just_dodge() -> void:
	if not is_tracking:
		return

	just_dodge_count += 1
	stats_changed.emit()

func record_interrupt() -> void:
	if not is_tracking:
		return

	interrupt_count += 1
	stats_changed.emit()

func record_riposte_hit() -> void:
	if not is_tracking:
		return

	riposte_hit_count += 1
	stats_changed.emit()

func record_vesper_counter_hit() -> void:
	if not is_tracking:
		return

	vesper_counter_hit_count += 1
	stats_changed.emit()

func record_just_dodge_counter_hit() -> void:
	if not is_tracking:
		return

	just_dodge_counter_hit_count += 1
	stats_changed.emit()

func record_vesper_art_used() -> void:
	if not is_tracking:
		return

	vesper_art_use_count += 1
	stats_changed.emit()

func record_vesper_art_hit() -> void:
	if not is_tracking:
		return

	vesper_art_hit_count += 1
	stats_changed.emit()

func record_vesper_art_miss() -> void:
	if not is_tracking:
		return

	vesper_art_miss_count += 1
	stats_changed.emit()

func record_blood_rend_used() -> void:
	if not is_tracking:
		return

	blood_rend_use_count += 1
	stats_changed.emit()

func record_blood_rend_hit(blood_cost: float) -> void:
	if not is_tracking:
		return

	blood_rend_hit_count += 1
	blood_cost_total += maxf(0.0, blood_cost)
	stats_changed.emit()

func record_blood_scent_success() -> void:
	if not is_tracking:
		return

	blood_scent_success_count += 1
	stats_changed.emit()

func record_blood_scent_hit_taken() -> void:
	if not is_tracking:
		return

	blood_scent_hit_taken_count += 1
	stats_changed.emit()

func get_score() -> float:
	var score := 0.0
	score += max_combo * score_per_combo_hit
	score += parry_count * score_per_parry
	score += max_deflect_chain * score_per_max_deflect_chain
	score += just_dodge_count * score_per_just_dodge
	score += interrupt_count * score_per_interrupt
	score += riposte_hit_count * score_per_riposte_hit
	score += vesper_counter_hit_count * score_per_vesper_counter_hit
	score += just_dodge_counter_hit_count * score_per_just_counter_hit
	score += vesper_art_hit_count * score_per_vesper_art_hit
	score += blood_scent_success_count * score_per_blood_scent_success
	score += final_flow * score_per_final_flow

	var clear_time_bonus := maxf(0.0, clear_time_bonus_target - combat_time) * score_per_second_under_target
	score += clear_time_bonus
	score -= damage_taken * score_penalty_per_damage
	score -= hit_taken_count * score_penalty_per_hit_taken
	score -= parry_fail_count * score_penalty_per_parry_fail
	score -= vesper_art_miss_count * score_penalty_per_vesper_art_miss
	return maxf(0.0, score)

func get_rank() -> String:
	var score := get_score()
	if score >= rank_threshold_vesper:
		return "VESPER"
	if score >= rank_threshold_s:
		return "S"
	if score >= rank_threshold_a:
		return "A"
	if score >= rank_threshold_b:
		return "B"
	if score >= rank_threshold_c:
		return "C"
	return "D"

func get_result_text() -> String:
	var lines := PackedStringArray()
	lines.append("RESULT")
	lines.append("Rank: %s" % get_rank())
	lines.append("Score: %d" % int(round(get_score())))
	lines.append("Clear Time: %.1fs" % combat_time)
	lines.append("Damage Taken: %d" % int(round(damage_taken)))
	lines.append("Hit Taken: %d" % hit_taken_count)
	lines.append("Max Combo: %d" % max_combo)
	lines.append("Parry: %d" % parry_count)
	lines.append("Normal Parry: %d" % normal_parry_count)
	lines.append("Rhythm Parry / Deflect: %d" % rhythm_parry_count)
	lines.append("Max Deflect Chain: %d" % max_deflect_chain)
	lines.append("Parry Fail: %d" % parry_fail_count)
	lines.append("Just Dodge: %d" % just_dodge_count)
	lines.append("Interrupt: %d" % interrupt_count)
	lines.append("Riposte Hit: %d" % riposte_hit_count)
	lines.append("Vesper Counter Hit: %d" % vesper_counter_hit_count)
	lines.append("Just Counter Hit: %d" % just_dodge_counter_hit_count)
	lines.append("Vesper Art Use: %d" % vesper_art_use_count)
	lines.append("Vesper Art Hit: %d" % vesper_art_hit_count)
	lines.append("Vesper Art Miss: %d" % vesper_art_miss_count)
	lines.append("Blood Rend Use: %d" % blood_rend_use_count)
	lines.append("Blood Rend Hit: %d" % blood_rend_hit_count)
	lines.append("Blood Cost: %d" % int(round(blood_cost_total)))
	lines.append("Blood Scent Success: %d" % blood_scent_success_count)
	lines.append("Blood Scent Hit Taken: %d" % blood_scent_hit_taken_count)
	lines.append("Final Flow: %d" % int(round(final_flow)))
	return "\n".join(lines)

func build_result_log(result: String) -> Dictionary:
	var rank := "D" if result == "death" else get_rank()
	return {
		"schemaVersion": 1,
		"result": result,
		"rank": rank,
		"score": int(round(get_score())),
		"clearTime": snappedf(combat_time, 0.1),
		"damageTaken": int(round(damage_taken)),
		"hitTakenCount": hit_taken_count,
		"maxCombo": max_combo,
		"finalFlow": int(round(final_flow)),
		"parryCount": parry_count,
		"normalParryCount": normal_parry_count,
		"rhythmParryCount": rhythm_parry_count,
		"deflectCount": deflect_count,
		"maxDeflectChain": max_deflect_chain,
		"parryFailCount": parry_fail_count,
		"justDodgeCount": just_dodge_count,
		"interruptCount": interrupt_count,
		"riposteHitCount": riposte_hit_count,
		"vesperCounterHitCount": vesper_counter_hit_count,
		"justDodgeCounterHitCount": just_dodge_counter_hit_count,
		"vesperArtUseCount": vesper_art_use_count,
		"vesperArtHitCount": vesper_art_hit_count,
		"vesperArtMissCount": vesper_art_miss_count,
		"bloodRendUseCount": blood_rend_use_count,
		"bloodRendHitCount": blood_rend_hit_count,
		"bloodCostTotal": int(round(blood_cost_total)),
		"bloodScentSuccessCount": blood_scent_success_count,
		"bloodScentHitTakenCount": blood_scent_hit_taken_count,
		"timestampText": Time.get_datetime_string_from_system(false, true),
		"notes": ""
	}

func generate_result_json(result: String) -> String:
	last_result_data = build_result_log(result)
	last_result_json = JSON.stringify(last_result_data, "\t")
	return last_result_json

func get_result_log_summary() -> String:
	if last_result_data.is_empty():
		return ""

	var lines := PackedStringArray()
	lines.append("RUN LOG READY")
	lines.append("Press Copy Result Log")
	lines.append("Rank: %s / Score: %d" % [str(last_result_data.get("rank", "")), int(last_result_data.get("score", 0))])
	lines.append("Time: %.1fs / Damage: %d" % [float(last_result_data.get("clearTime", 0.0)), int(last_result_data.get("damageTaken", 0))])
	lines.append("Max Combo: %d / Final Flow: %d" % [int(last_result_data.get("maxCombo", 0)), int(last_result_data.get("finalFlow", 0))])
	lines.append("Deflect: %d / Max Chain: %d / Fail: %d" % [int(last_result_data.get("deflectCount", 0)), int(last_result_data.get("maxDeflectChain", 0)), int(last_result_data.get("parryFailCount", 0))])
	lines.append("Blood Rend: %d/%d / Scent OK: %d" % [int(last_result_data.get("bloodRendHitCount", 0)), int(last_result_data.get("bloodRendUseCount", 0)), int(last_result_data.get("bloodScentSuccessCount", 0))])
	return "\n".join(lines)