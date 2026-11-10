class_name GameManager
extends Node

var score: int = 0

func add_score(points: int) -> void:
	score += points
	print("Pontuação atual: ", score)

func reset_game() -> void:
	score = 0
