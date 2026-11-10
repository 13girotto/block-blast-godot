class_name PieceController
extends Node2D

const TILE_SIZE = 64

var main_controller: Node = null

var current_shape: Array[Vector2i] = []
var piece_color: Color = Color.WHITE

var is_dragging: bool = false
var initial_position: Vector2
var grid_manager: GridManager

func _ready() -> void:
	initial_position = global_position
	grid_manager = get_tree().get_first_node_in_group("grid")
	build_piece_visuals()

func build_piece_visuals() -> void:
	for child in get_children():
		child.queue_free()
		
	for cell in current_shape:
		var rect = ColorRect.new()
		rect.size = Vector2(TILE_SIZE - 4, TILE_SIZE - 4) # Deixa uma bordinha preta entre os blocos
		rect.position = Vector2(cell.x * TILE_SIZE, cell.y * TILE_SIZE)
		rect.color = piece_color
		add_child(rect)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if is_point_inside_piece(event.position):
				is_dragging = true
				# Ao clicar e começar a arrastar, a peça volta para o tamanho real para facilitar a visualização no tabuleiro
				scale = Vector2(1.0, 1.0)
		elif is_dragging:
			is_dragging = false
			
			if grid_manager:
				var grid_pos = grid_manager.world_to_grid(global_position)
				
				if grid_manager.can_place_piece(current_shape, grid_pos):
					grid_manager.place_piece(current_shape, grid_pos, piece_color)
					
					if main_controller and main_controller.has_method("notify_piece_placed"):
						main_controller.notify_piece_placed()
					
					queue_free()
				else:
					# Se não couber, retorna à posição inicial e volta a ser miniatura compacta no dock
					global_position = initial_position
					scale = Vector2(0.55, 0.55)
			else:
				global_position = initial_position
				scale = Vector2(0.55, 0.55)

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position()

func is_point_inside_piece(global_mouse_pos: Vector2) -> bool:
	for cell in current_shape:
		# Multiplica pela escala atual para que o clique funcione corretamente mesmo quando a miniatura estiver ativa no dock
		var scaled_tile_size = TILE_SIZE * scale.x
		var cell_world_pos = global_position + Vector2(cell.x * scaled_tile_size, cell.y * scaled_tile_size)
		var rect = Rect2(cell_world_pos, Vector2(scaled_tile_size, scaled_tile_size))
		if rect.has_point(global_mouse_pos):
			return true
	return false
