class_name GridManager
extends Node2D

const GRID_SIZE = 12  # 12x12
const TILE_SIZE = 48  # Ajustado para a tela

# Matriz que armazena as cores dos blocos no tabuleiro
var grid_data: Array = []

signal score_updated(points: int)
# NOVO: Sinal emitido para o MissionTracker informando quais linhas/colunas foram limpas e suas cores
signal lines_cleared(events: Array[Dictionary])

func _ready() -> void:
	add_to_group("grid")
	initialize_grid()

func initialize_grid() -> void:
	grid_data.clear()
	for x in range(GRID_SIZE):
		var row: Array = []
		for y in range(GRID_SIZE):
			row.append(Color(0, 0, 0, 0)) # Vazio
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
		var cleared_colors: Array[Color] = []
		
		# NOVO: Estrutura para registrar os eventos de limpeza para as missões
		var clearance_events: Array[Dictionary] = []
		
		# Limpar Linhas
		for y in completed_rows:
			var row_colors: Array[Color] = []
			for x in range(GRID_SIZE):
				row_colors.append(grid_data[x][y])
				cleared_colors.append(grid_data[x][y])
				grid_data[x][y] = Color(0, 0, 0, 0)
			clearance_events.append({"type": "row", "index": y, "colors": row_colors})
				
		# Limpar Colunas
		for x in completed_cols:
			var col_colors: Array[Color] = []
			for y in range(GRID_SIZE):
				var current_color = grid_data[x][y]
				col_colors.append(current_color)
				# Evita duplicar se a célula estiver na interseção de linha e coluna limpas
				if current_color != Color(0, 0, 0, 0):
					cleared_colors.append(current_color)
					grid_data[x][y] = Color(0, 0, 0, 0)
			clearance_events.append({"type": "col", "index": x, "colors": col_colors})
		
		# 3. Cálculo de Pontuação baseado nas cores iguais encontradas
		var color_counts = {}
		for c in cleared_colors:
			if c == Color(0, 0, 0, 0): continue
			var color_key = c.to_html() 
			if color_counts.has(color_key):
				color_counts[color_key] += 1
			else:
				color_counts[color_key] = 1
				
		for color_key in color_counts:
			var count = color_counts[color_key]
			var points_for_this_color = (count * 10) + (count * count * 15)
			total_points += points_for_this_color
			
		print("Linhas/Colunas limpas! Pontos ganhos: ", total_points)
		emit_signal("score_updated", total_points)
		
		# NOVO: Emite o sinal para o sistema de missões rastrear a limpeza
		emit_signal("lines_cleared", clearance_events)
		
		queue_redraw()

# NOVO: Função para espalhar blocos iniciais aleatórios no início de cada nível
func fill_random_initial_blocks(count: int, allowed_colors: Array[Color]) -> void:
	if allowed_colors.is_empty():
		return
		
	var placed := 0
	var attempts := 0
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	while placed < count and attempts < 500:
		attempts += 1
		var rx = rng.randi_range(0, GRID_SIZE - 1)
		var ry = rng.randi_range(0, GRID_SIZE - 1)
		
		if grid_data[rx][ry] == Color(0, 0, 0, 0):
			grid_data[rx][ry] = allowed_colors.pick_random()
			placed += 1
			
	queue_redraw()

# Desenha visualmente a grade e os blocos fixados nela
func _draw() -> void:
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var rect = Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE - 2, TILE_SIZE - 2)
			var color = grid_data[x][y]
			
			if color == Color(0, 0, 0, 0):
				draw_rect(rect, Color(0.18, 0.18, 0.24))
			else:
				draw_rect(rect, color)
