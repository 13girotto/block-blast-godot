class_name MainController
extends Node2D

@export var piece_scene: PackedScene = preload("res://scenes/piece.tscn")

var available_shapes: Array[Array] = [
	[Vector2i(0, 0)] as Array[Vector2i], # 1x1
	[Vector2i(0, 0), Vector2i(1, 0)] as Array[Vector2i], # Horizontal 2
	[Vector2i(0, 0), Vector2i(0, 1)] as Array[Vector2i], # Vertical 2
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)] as Array[Vector2i], # Horizontal 3
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)] as Array[Vector2i], # Vertical 3
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)] as Array[Vector2i], # Horizontal 4
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)] as Array[Vector2i], # Vertical 4
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)] as Array[Vector2i], # Quadrado 2x2
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)] as Array[Vector2i] # L pequeno
]

var available_colors: Array[Color] = [
	Color(0.2, 0.6, 0.9), # Azul
	Color(0.9, 0.3, 0.3), # Vermelho
	Color(0.3, 0.8, 0.4), # Verde
	Color(0.9, 0.7, 0.2), # Amarelo
	Color(0.7, 0.3, 0.8) # Roxo
]

var active_pieces_in_dock: int = 0
var score: int = 0
var score_label: Label

func _ready() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	setup_score_ui()
	setup_grid_connection()
	spawn_piece_dock()

# Cria o texto da pontuação na parte superior da tela
func setup_score_ui() -> void:
	score_label = Label.new()
	score_label.text = "Pontos: 0"
	score_label.position = Vector2(50, 60)
	
	score_label.add_theme_font_size_override("font_size", 32)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(score_label)

# Conecta o sinal de pontuação do GridManager
func setup_grid_connection() -> void:
	var grid = get_tree().get_first_node_in_group("grid")
	if grid and grid.has_signal("score_updated"):
		grid.connect("score_updated", Callable(self, "_on_score_updated"))

func _on_score_updated(points: int) -> void:
	score += points
	if score_label:
		score_label.text = "Pontos: %d" % score
	print("Pontuação atualizada: ", score)

func spawn_piece_dock() -> void:
	active_pieces_in_dock = 4
	
	var dock_slots_x = [80, 260, 440, 620]
	var dock_y = 960
	
	for i in range(4):
		if not piece_scene:
			print("ERRO: piece_scene nula!")
			return

		var new_piece = piece_scene.instantiate() as PieceController
		new_piece.current_shape = available_shapes.pick_random() as Array[Vector2i]
		new_piece.piece_color = available_colors.pick_random()
		
		var target_pos = Vector2(dock_slots_x[i], dock_y)
		
		new_piece.initial_position = target_pos
		new_piece.global_position = target_pos
		new_piece.scale = Vector2(0.55, 0.55)
		
		new_piece.main_controller = self
		add_child(new_piece)
		
		# PRINT DE TESTE: Mostra no console a posição exata criada
		print("Peça ", i, " gerada na global_position: ", new_piece.global_position)

func notify_piece_placed() -> void:
	active_pieces_in_dock -= 1
	if active_pieces_in_dock <= 0:
		spawn_piece_dock()
