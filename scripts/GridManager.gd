class_name GridManager
extends Node2D

const GRID_SIZE = 8
const TILE_SIZE = 64

# Matriz que armazena as cores dos blocos no tabuleiro
var grid_data: Array = []

signal score_updated(points: int)

func _ready() -> void:
	add_to_group("grid")
	initialize_grid()

func initialize_grid() -> void:
	grid_data.clear()
	for x in range(GRID_SIZE):
		var row: Array = []
		for y in range(GRID_SIZE):
			row.append(Color(0, 0, 0, 0)) # Célula vazia
		grid_data.append(row)

# Converte posição de mundo para coordenadas da grade
func world_to_grid(global_pos: Vector2) -> Vector2i:
	var local_pos = to_local(global_pos)
	var x = floor(local_pos.x / TILE_SIZE)
	var y = floor(local_pos.y / TILE_SIZE)
	return Vector2i(int(x), int(y))

# Verifica se a peça cabe na posição desejada
func can_place_piece(shape: Array[Vector2i], grid_pos: Vector2i) -> bool:
	for cell in shape:
		var target_x = grid_pos.x + cell.x
		var target_y = grid_pos.y + cell.y
		
		# Fora dos limites da grade
		if target_x < 0 or target_x >= GRID_SIZE or target_y < 0 or target_y >= GRID_SIZE:
			return false
		
		# Espaço já ocupado
		if grid_data[target_x][target_y] != Color(0, 0, 0, 0):
			return false
			
	return true

# Coloca a peça na grade, verifica linhas/colunas completas e calcula os pontos por cor
func place_piece(shape: Array[Vector2i], grid_pos: Vector2i, piece_color: Color) -> void:
	for cell in shape:
		var target_x = grid_pos.x + cell.x
		var target_y = grid_pos.y + cell.y
		grid_data[target_x][target_y] = piece_color
	
	queue_redraw()
	
	# Após colocar, verifica se completou linhas ou colunas e pontua
	check_and_clear_lines()

# Lógica de verificação, limpeza e pontuação por cores
func check_and_clear_lines() -> void:
	var completed_rows: Array[int] = []
	var completed_cols: Array[int] = []
	
	# 1. Checar Linhas Completas (Y)
	for y in range(GRID_SIZE):
		var is_full = true
		for x in range(GRID_SIZE):
			if grid_data[x][y] == Color(0, 0, 0, 0):
				is_full = false
				break
		if is_full:
			completed_rows.append(y)
			
	# 2. Checar Colunas Completas (X)
	for x in range(GRID_SIZE):
		var is_full = true
		for y in range(GRID_SIZE):
			if grid_data[x][y] == Color(0, 0, 0, 0):
				is_full = false
				break
		if is_full:
			completed_cols.append(x)
			
	# Se houver linhas ou colunas completas, vamos processá-las
	if completed_rows.size() > 0 or completed_cols.size() > 0:
		var total_points = 0
		
		# Coleta todas as cores presentes nas linhas e colunas completas para calcular a pontuação
		var cleared_colors: Array[Color] = []
		
		# Limpar Linhas
		for y in completed_rows:
			for x in range(GRID_SIZE):
				cleared_colors.append(grid_data[x][y])
				grid_data[x][y] = Color(0, 0, 0, 0)
				
		# Limpar Colunas
		for x in completed_cols:
			for y in range(GRID_SIZE):
				# Evita duplicar se a célula estiver na interseção de linha e coluna limpas
				if grid_data[x][y] != Color(0, 0, 0, 0):
					cleared_colors.append(grid_data[x][y])
					grid_data[x][y] = Color(0, 0, 0, 0)
		
		# 3. Cálculo de Pontuação baseado nas cores iguais encontradas
		# Contabiliza a frequência de cada cor eliminada
		var color_counts = {}
		for c in cleared_colors:
			var color_key = c.to_html() # Usa o código HEX da cor como chave no dicionário
			if color_counts.has(color_key):
				color_counts[color_key] += 1
			else:
				color_counts[color_key] = 1
				
		# Regra de pontuação: 10 pontos por bloco base + bônus quadrático para cores repetidas (ex: count * count * 15)
		for color_key in color_counts:
			var count = color_counts[color_key]
			var points_for_this_color = (count * 10) + (count * count * 15)
			total_points += points_for_this_color
			
		print("Linhas/Colunas limpas! Pontos ganhos: ", total_points)
		emit_signal("score_updated", total_points)
		
		queue_redraw()

# Desenha visualmente a grade e os blocos fixados nela
func _draw() -> void:
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var rect = Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE - 2, TILE_SIZE - 2)
			var color = grid_data[x][y]
			
			if color == Color(0, 0, 0, 0):
				# Cor padrão do fundo da célula vazia na grade
				draw_rect(rect, Color(0.18, 0.18, 0.24))
			else:
				# Desenha o bloco preenchido com a sua respectiva cor
				draw_rect(rect, color)
