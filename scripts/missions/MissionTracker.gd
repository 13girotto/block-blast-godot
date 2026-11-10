# scripts/missions/MissionTracker.gd
class_name MissionTracker
extends Node

signal all_missions_completed
var active_missions: Array[Mission] = []

func setup(level_missions: Array[Mission]) -> void:
	active_missions.clear()
	for m in level_missions:
		var copy = m.duplicate(true) as Mission # Instância única do Resource
		copy.completed.connect(_check_all)
		active_missions.append(copy)

func on_lines_cleared(events: Array[Dictionary]) -> void:
	for m in active_missions:
		m.on_lines_cleared(events)

func _check_all() -> void:
	if active_missions.all(func(m): return m.is_complete()):
		all_missions_completed.emit()
