extends Node
class_name CombatStats

signal stats_changed

@export_group("Rank Thresholds")
@export var rank_threshold_c: float = 30.0
@export var rank_threshold_b: float = 110.0
@export var rank_threshold_a: float = 185.0
@export var rank_threshold_s: float = 275.0
@export var rank_threshold_vesper: float = 360.0

@export_group("Score Weights")
@export var score_victory_bonus: float = 80.0
@export var score_no_hit_bonus: float = 35.0
@export var score_low_damage_bonus: float = 20.0
@export var low_damage_bonus_limit: float = 25.0
@export var score_per_combo_hit: float = 2.0
@export var max_combo_score_cap: float = 28.0
@export var score_per_parry: float = 18.0
@export var normal_parry_score_cap: float = 72.0
@export var score_per_deflect: float = 3.0
@export var deflect_score_cap: float = 36.0
@export var score_per_max_deflect_chain: float = 6.0
@export var max_deflect_chain_score_cap: float = 42.0
@export var score_per_just_dodge: float = 12.0
@export var just_dodge_score_cap: float = 48.0
@export var score_per_interrupt: float = 18.0
@export var score_per_riposte_hit: float = 18.0
@export var score_per_vesper_counter_hit: float = 28.0
@export var score_per_just_counter_hit: float = 20.0
@export var counter_score_cap: float = 160.0
@export var score_per_vesper_art_hit: float = 70.0
@export var score_per_blood_rend_hit: float = 10.0
@export var score_per_blood_scent_success: float = 8.0
@export var blood_score_cap: float = 36.0
@export var score_per_final_flow: float = 0.2
@export var final_flow_score_cap: float = 20.0

@export_group("Score Penalties")
@export var score_penalty_per_damage: float = 0.75
@export var score_penalty_per_hit_taken: float = 14.0
@export var score_penalty_per_parry_fail: float = 6.0
@export var score_penalty_per_vesper_art_miss: float = 28.0
@export var score_penalty_per_blood_scent_hit_taken: float = 18.0

@export_group("Clear Time")
@export var clear_time_bonus_target: float = 45.0
@export var score_per_second_under_target: float = 0.75
@export var clear_time_score_cap: float = 30.0

@export_group("Result Logs")
@export var auto_save_result_logs: bool = true
@export var result_log_directory: String = "user://result_logs"

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
var flow_gain_total: float = 0.0
var flow_spend_total: float = 0.0
var flow_loss_total: float = 0.0
var flow_gain_attack_total: float = 0.0
var flow_gain_defense_total: float = 0.0
var flow_gain_deflect_total: float = 0.0
var flow_gain_counter_total: float = 0.0
var flow_gain_blood_scent_total: float = 0.0
var last_flow_delta: float = 0.0
var last_flow_reason: String = ""
var is_tracking: bool = false
var last_result_data: Dictionary = {}
var last_result_json: String = ""
var last_result_save_path: String = ""
var last_result_save_succeeded: bool = false
var last_result_save_message: String = ""

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
	flow_gain_total = 0.0
	flow_spend_total = 0.0
	flow_loss_total = 0.0
	flow_gain_attack_total = 0.0
	flow_gain_defense_total = 0.0
	flow_gain_deflect_total = 0.0
	flow_gain_counter_total = 0.0
	flow_gain_blood_scent_total = 0.0
	last_flow_delta = 0.0
	last_flow_reason = ""
	last_result_data = {}
	last_result_json = ""
	last_result_save_path = ""
	last_result_save_succeeded = false
	last_result_save_message = ""
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

func record_flow_event(delta: float, reason: String, current_flow: float) -> void:
	if not is_tracking:
		return

	last_flow_delta = delta
	last_flow_reason = reason
	final_flow = maxf(0.0, current_flow)
	if delta > 0.0:
		flow_gain_total += delta
		_record_flow_gain_category(delta, reason)
	elif _is_flow_spend_reason(reason):
		flow_spend_total += absf(delta)
	else:
		flow_loss_total += absf(delta)
	stats_changed.emit()

func _record_flow_gain_category(amount: float, reason: String) -> void:
	if reason.begins_with("DEFLECT"):
		flow_gain_deflect_total += amount
	elif reason == "LIGHT HIT" or reason == "HEAVY HIT":
		flow_gain_attack_total += amount
	elif reason == "PARRY" or reason == "JUST DODGE" or reason == "INTERRUPT" or reason == "HEAVY PUNISH":
		flow_gain_defense_total += amount
	elif reason == "RIPOSTE" or reason == "VESPER COUNTER" or reason == "JUST COUNTER" or reason == "COUNTER":
		flow_gain_counter_total += amount
	elif reason == "BLOOD SCENT":
		flow_gain_blood_scent_total += amount

func _is_flow_spend_reason(reason: String) -> bool:
	return reason == "VESPER ART" or reason == "VESPER ART MISS" or reason == "SPEND"


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

func _score_cap(value: float, cap: float) -> float:
	if cap <= 0.0:
		return maxf(0.0, value)
	return minf(maxf(0.0, value), cap)

func get_score_breakdown(result: String = "victory") -> Dictionary:
	var victory_score := score_victory_bonus if result == "victory" else 0.0
	var clear_time_score := _score_cap(maxf(0.0, clear_time_bonus_target - combat_time) * score_per_second_under_target, clear_time_score_cap)

	var clean_defense_score := 0.0
	if result == "victory":
		if hit_taken_count == 0 and damage_taken <= 0.0:
			clean_defense_score += score_no_hit_bonus
		elif damage_taken <= low_damage_bonus_limit:
			clean_defense_score += score_low_damage_bonus
	clean_defense_score += _score_cap(normal_parry_count * score_per_parry, normal_parry_score_cap)
	clean_defense_score += _score_cap(deflect_count * score_per_deflect, deflect_score_cap)
	clean_defense_score += _score_cap(max_deflect_chain * score_per_max_deflect_chain, max_deflect_chain_score_cap)
	clean_defense_score += _score_cap(just_dodge_count * score_per_just_dodge, just_dodge_score_cap)

	var basic_offense_score := _score_cap(max_combo * score_per_combo_hit, max_combo_score_cap)
	var counter_score := 0.0
	counter_score += interrupt_count * score_per_interrupt
	counter_score += riposte_hit_count * score_per_riposte_hit
	counter_score += vesper_counter_hit_count * score_per_vesper_counter_hit
	counter_score += just_dodge_counter_hit_count * score_per_just_counter_hit
	counter_score = _score_cap(counter_score, counter_score_cap)

	var flow_vesper_score := 0.0
	flow_vesper_score += vesper_art_hit_count * score_per_vesper_art_hit
	flow_vesper_score += _score_cap(final_flow * score_per_final_flow, final_flow_score_cap)

	var blood_score := 0.0
	blood_score += blood_rend_hit_count * score_per_blood_rend_hit
	blood_score += blood_scent_success_count * score_per_blood_scent_success
	blood_score = _score_cap(blood_score, blood_score_cap)

	var damage_penalty := -((damage_taken * score_penalty_per_damage) + (hit_taken_count * score_penalty_per_hit_taken))
	var mistake_penalty := -((parry_fail_count * score_penalty_per_parry_fail) + (vesper_art_miss_count * score_penalty_per_vesper_art_miss) + (blood_scent_hit_taken_count * score_penalty_per_blood_scent_hit_taken))
	var total_score := victory_score + clear_time_score + clean_defense_score + basic_offense_score + counter_score + flow_vesper_score + blood_score + damage_penalty + mistake_penalty

	return {
		"victory": victory_score,
		"clearTime": clear_time_score,
		"cleanDefense": clean_defense_score,
		"basicOffense": basic_offense_score,
		"counters": counter_score,
		"flowVesperArt": flow_vesper_score,
		"bloodRoute": blood_score,
		"damageTaken": damage_penalty,
		"mistakes": mistake_penalty,
		"total": maxf(0.0, total_score)
	}

func get_score(result: String = "victory") -> float:
	return float(get_score_breakdown(result).get("total", 0.0))

func get_rank(result: String = "victory") -> String:
	var score := get_score(result)
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

func _format_score_line(label: String, value: float) -> String:
	var sign := "+" if value >= 0.0 else "-"
	return "%s: %s%d" % [label, sign, int(round(absf(value)))]

func _rounded_score_breakdown(breakdown: Dictionary) -> Dictionary:
	var rounded := {}
	for key in breakdown.keys():
		rounded[key] = int(round(float(breakdown.get(key, 0.0))))
	return rounded

func get_result_text(result: String = "victory") -> String:
	var breakdown := get_score_breakdown(result)
	var lines := PackedStringArray()
	lines.append("RESULT")
	lines.append("Rank: %s" % get_rank(result))
	lines.append("Score: %d" % int(round(get_score(result))))
	lines.append("Clear Time: %.1fs" % combat_time)
	lines.append("Damage Taken: %d / Hits: %d" % [int(round(damage_taken)), hit_taken_count])
	lines.append("")
	lines.append("Score Breakdown")
	lines.append(_format_score_line("Victory", float(breakdown.get("victory", 0.0))))
	lines.append(_format_score_line("Clear Time", float(breakdown.get("clearTime", 0.0))))
	lines.append(_format_score_line("Clean Defense", float(breakdown.get("cleanDefense", 0.0))))
	lines.append(_format_score_line("Basic Offense", float(breakdown.get("basicOffense", 0.0))))
	lines.append(_format_score_line("Counters", float(breakdown.get("counters", 0.0))))
	lines.append(_format_score_line("Flow / Vesper Art", float(breakdown.get("flowVesperArt", 0.0))))
	lines.append(_format_score_line("Blood Route", float(breakdown.get("bloodRoute", 0.0))))
	lines.append(_format_score_line("Damage Taken", float(breakdown.get("damageTaken", 0.0))))
	lines.append(_format_score_line("Mistakes", float(breakdown.get("mistakes", 0.0))))
	lines.append("")
	lines.append("Core: Combo %d / Parry %d / Deflect %d / Chain %d" % [max_combo, normal_parry_count, deflect_count, max_deflect_chain])
	lines.append("Counters: JD %d / INT %d / Riposte %d / VC %d / JDC %d" % [just_dodge_count, interrupt_count, riposte_hit_count, vesper_counter_hit_count, just_dodge_counter_hit_count])
	lines.append("Vesper Art: Use %d / Hit %d / Miss %d" % [vesper_art_use_count, vesper_art_hit_count, vesper_art_miss_count])
	lines.append("Blood: Rend %d/%d / Cost %d / Scent OK %d / Hit %d" % [blood_rend_hit_count, blood_rend_use_count, int(round(blood_cost_total)), blood_scent_success_count, blood_scent_hit_taken_count])
	lines.append("Flow: Final %d / Gain %d / Spend %d / Loss %d" % [int(round(final_flow)), int(round(flow_gain_total)), int(round(flow_spend_total)), int(round(flow_loss_total))])
	return "\n".join(lines)

func build_result_log(result: String) -> Dictionary:
	var breakdown := get_score_breakdown(result)
	var rank := "D" if result == "death" else get_rank(result)
	return {
		"schemaVersion": 2,
		"result": result,
		"rank": rank,
		"score": int(round(get_score(result))),
		"scoreBreakdown": _rounded_score_breakdown(breakdown),
		"clearTime": snappedf(combat_time, 0.1),
		"damageTaken": int(round(damage_taken)),
		"hitTakenCount": hit_taken_count,
		"maxCombo": max_combo,
		"finalFlow": int(round(final_flow)),
		"flowGainTotal": int(round(flow_gain_total)),
		"flowSpendTotal": int(round(flow_spend_total)),
		"flowLossTotal": int(round(flow_loss_total)),
		"flowGainAttack": int(round(flow_gain_attack_total)),
		"flowGainDefense": int(round(flow_gain_defense_total)),
		"flowGainDeflect": int(round(flow_gain_deflect_total)),
		"flowGainCounter": int(round(flow_gain_counter_total)),
		"flowGainBloodScent": int(round(flow_gain_blood_scent_total)),
		"flowSourceTotals": {
			"attack": int(round(flow_gain_attack_total)),
			"defense": int(round(flow_gain_defense_total)),
			"deflect": int(round(flow_gain_deflect_total)),
			"counter": int(round(flow_gain_counter_total)),
			"bloodScent": int(round(flow_gain_blood_scent_total)),
			"gainTotal": int(round(flow_gain_total)),
			"spendTotal": int(round(flow_spend_total)),
			"lossTotal": int(round(flow_loss_total))
		},
		"lastFlowDelta": int(round(last_flow_delta)),
		"lastFlowReason": last_flow_reason,
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
		"styleStats": {
			"rhythmParryCount": rhythm_parry_count,
			"deflectCount": deflect_count,
			"maxDeflectChain": max_deflect_chain,
			"normalParryCount": normal_parry_count,
			"parryFailCount": parry_fail_count,
			"justDodgeCount": just_dodge_count,
			"interruptCount": interrupt_count,
			"riposteHitCount": riposte_hit_count,
			"vesperCounterHitCount": vesper_counter_hit_count,
			"justDodgeCounterHitCount": just_dodge_counter_hit_count,
			"vesperArtUseCount": vesper_art_use_count,
			"vesperArtHitCount": vesper_art_hit_count,
			"vesperArtMissCount": vesper_art_miss_count
		},
		"bloodRouteStats": {
			"bloodRendUseCount": blood_rend_use_count,
			"bloodRendHitCount": blood_rend_hit_count,
			"bloodCostTotal": int(round(blood_cost_total)),
			"bloodScentSuccessCount": blood_scent_success_count,
			"bloodScentHitTakenCount": blood_scent_hit_taken_count
		},
		"timestampText": Time.get_datetime_string_from_system(false, true),
		"notes": ""
	}

func generate_result_json(result: String) -> String:
	last_result_data = build_result_log(result)
	last_result_json = JSON.stringify(last_result_data, "\t")
	if auto_save_result_logs:
		save_last_result_log()
	else:
		last_result_save_path = ""
		last_result_save_succeeded = false
		last_result_save_message = "AUTO SAVE OFF"
	return last_result_json

func save_last_result_log() -> bool:
	last_result_save_path = ""
	last_result_save_succeeded = false
	last_result_save_message = ""
	if last_result_json == "" or last_result_data.is_empty():
		last_result_save_message = "NO RESULT LOG TO SAVE"
		push_warning(last_result_save_message)
		return false

	var directory := _normalized_result_log_directory()
	var make_dir_error := DirAccess.make_dir_recursive_absolute(directory)
	if make_dir_error != OK:
		last_result_save_message = "SAVE FAILED: DIR %s" % str(make_dir_error)
		push_warning("Result log auto-save failed: %s" % last_result_save_message)
		return false

	var file_path := _get_unique_result_log_path(directory, _build_result_log_file_name())
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		var open_error := FileAccess.get_open_error()
		last_result_save_message = "SAVE FAILED: FILE %s" % str(open_error)
		push_warning("Result log auto-save failed: %s" % last_result_save_message)
		return false

	file.store_string(last_result_json)
	file.close()
	last_result_save_path = file_path
	last_result_save_succeeded = true
	last_result_save_message = "SAVED: %s" % file_path
	return true

func _normalized_result_log_directory() -> String:
	var directory := result_log_directory.strip_edges()
	if directory == "":
		directory = "user://result_logs"
	while directory.ends_with("/") and directory != "user://":
		directory = directory.trim_suffix("/")
	return directory

func _build_result_log_file_name() -> String:
	var datetime := Time.get_datetime_dict_from_system()
	var result := _sanitize_file_name_part(str(last_result_data.get("result", "result")).to_lower())
	var rank := _sanitize_file_name_part(str(last_result_data.get("rank", "rank")).to_lower())
	return "%04d%02d%02d_%02d%02d%02d_%s_%s.json" % [
		int(datetime.get("year", 0)),
		int(datetime.get("month", 0)),
		int(datetime.get("day", 0)),
		int(datetime.get("hour", 0)),
		int(datetime.get("minute", 0)),
		int(datetime.get("second", 0)),
		result,
		rank
	]

func _sanitize_file_name_part(text: String) -> String:
	var cleaned := ""
	for index in text.length():
		var character := text.substr(index, 1)
		if (character >= "a" and character <= "z") or (character >= "A" and character <= "Z") or (character >= "0" and character <= "9") or character == "_" or character == "-":
			cleaned += character
		else:
			cleaned += "-"
	return cleaned if cleaned != "" else "unknown"

func _get_unique_result_log_path(directory: String, file_name: String) -> String:
	var base_name := file_name.get_basename()
	var extension := file_name.get_extension()
	var path := "%s/%s" % [directory, file_name]
	var duplicate_index := 1
	while FileAccess.file_exists(path):
		path = "%s/%s_%02d.%s" % [directory, base_name, duplicate_index, extension]
		duplicate_index += 1
	return path

func get_result_log_summary() -> String:
	if last_result_data.is_empty():
		return ""

	var breakdown: Dictionary = last_result_data.get("scoreBreakdown", {})
	var lines := PackedStringArray()
	lines.append("RUN LOG READY")
	lines.append("Press Copy Result Log")
	if last_result_save_succeeded:
		lines.append("Auto Save: OK")
		lines.append(last_result_save_path)
	elif last_result_save_message != "":
		lines.append("Auto Save: %s" % last_result_save_message)
	lines.append("Rank: %s / Score: %d" % [str(last_result_data.get("rank", "")), int(last_result_data.get("score", 0))])
	lines.append("Time: %.1fs / Damage: %d / Hits %d" % [float(last_result_data.get("clearTime", 0.0)), int(last_result_data.get("damageTaken", 0)), int(last_result_data.get("hitTakenCount", 0))])
	lines.append("Breakdown V/Clean/Counter/Flow: %d / %d / %d / %d" % [int(breakdown.get("victory", 0)), int(breakdown.get("cleanDefense", 0)), int(breakdown.get("counters", 0)), int(breakdown.get("flowVesperArt", 0))])
	lines.append("Penalty Damage/Mistakes: %d / %d" % [int(breakdown.get("damageTaken", 0)), int(breakdown.get("mistakes", 0))])
	lines.append("Deflect: %d / Max Chain: %d / Flow %d" % [int(last_result_data.get("deflectCount", 0)), int(last_result_data.get("maxDeflectChain", 0)), int(last_result_data.get("flowGainDeflect", 0))])
	lines.append("Vesper Art: %d/%d hit / Miss %d" % [int(last_result_data.get("vesperArtHitCount", 0)), int(last_result_data.get("vesperArtUseCount", 0)), int(last_result_data.get("vesperArtMissCount", 0))])
	lines.append("Blood Rend: %d/%d / Cost: %d" % [int(last_result_data.get("bloodRendHitCount", 0)), int(last_result_data.get("bloodRendUseCount", 0)), int(last_result_data.get("bloodCostTotal", 0))])
	lines.append("Blood Scent: OK %d / Hit %d" % [int(last_result_data.get("bloodScentSuccessCount", 0)), int(last_result_data.get("bloodScentHitTakenCount", 0))])
	return "\n".join(lines)
