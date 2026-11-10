# scripts/levels/LevelData.gd
class_name LevelData
extends Resource

@export var level_title: String = "Nível 1"
@export var min_random_blocks: int = 8
@export var max_random_blocks: int = 14
@export var allowed_colors: Array[Color] = []
@export var missions: Array[Mission] = []
