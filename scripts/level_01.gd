class_name Level01
extends BaseLevel

func _ready() -> void:
	level_theme_color = Color(1.0, 0.55, 0.2, 1.0)
	super._ready()
	_build_pillars()
	_build_lava()

func _build_lava() -> void:
	var layer = $TileMapLayer as TileMapLayer
	if not layer: return
	# Lava floor: x from 0 to 79, y from 43 to 45 (last 2 rows)
	for x in range(80):
		layer.set_cell(Vector2i(x, 43), 5, Vector2i(0, 0))
		layer.set_cell(Vector2i(x, 44), 5, Vector2i(0, 0))

func _build_pillars() -> void:
	var layer = $TileMapLayer as TileMapLayer
	if not layer: return
	
	var cells: Array[Vector2i] = []
	
	# Usando as coordenadas de grid 16x16 da tela de 1280x720 (80x45)
	# Platform 1 (Spawn):
	_add_rect_cells(cells, 4, 34, 6, 11)
	
	# Platform 2 (Small jump):
	_add_rect_cells(cells, 22, 37, 4, 8)
	
	# Platform 3 (Higher):
	_add_rect_cells(cells, 38, 31, 5, 14)
	
	# Platform 4 (Lower):
	_add_rect_cells(cells, 55, 38, 2, 7)
	
	# Platform 5 (Comet Goal):
	_add_rect_cells(cells, 72, 34, 6, 11)
	
	# Pinta tudo conectando os terrenos (terrain_set = 0, terrain = 0)
	layer.set_cells_terrain_connect(cells, 0, 0, true)

func _add_rect_cells(cells: Array[Vector2i], start_x: int, start_y: int, w: int, h: int) -> void:
	for x in range(start_x, start_x + w):
		for y in range(start_y, start_y + h):
			cells.append(Vector2i(x, y))
