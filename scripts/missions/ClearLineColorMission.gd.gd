# scripts/missions/ClearLineColorMission.gd
class_name ClearLineColorMission
extends Mission

@export var required_color: Color

func on_lines_cleared(events: Array[Dictionary]) -> void:
	for e in events:
		var colors: Array = e["colors"]
		# Incrementa progresso se a linha/coluna destruída possuir a cor exigida
		if colors.has(required_color):
			_add_progress(1)
