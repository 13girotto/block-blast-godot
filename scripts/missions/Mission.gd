# scripts/missions/Mission.gd
class_name Mission
extends Resource

signal progress_changed
signal completed

var progress := 0
@export var target := 1

func on_lines_cleared(_events: Array[Dictionary]) -> void:
	pass

func is_complete() -> bool:
	return progress >= target

func _add_progress(amount: int) -> void:
	if is_complete():
		return
	progress = min(progress + amount, target)
	progress_changed.emit()
	if is_complete():
		completed.emit()
