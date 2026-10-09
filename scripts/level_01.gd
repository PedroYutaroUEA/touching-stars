class_name Level01
extends BaseLevel

func _ready() -> void:
	super._ready()
	_build_pillars()

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
	_add_rect_cells(cells, 38, 30, 5, 15)
	
	# Platform 4 (Lower):
	_add_rect_cells(cells, 55, 38, 4, 7)
	
	# Platform 5 (Comet Goal):
	_add_rect_cells(cells, 72, 34, 6, 11)
	
	# Pinta tudo conectando os terrenos (terrain_set = 0, terrain = 0)
	layer.set_cells_terrain_connect(cells, 0, 0, true)

func _add_rect_cells(cells: Array[Vector2i], start_x: int, start_y: int, w: int, h: int) -> void:
	for x in range(start_x, start_x + w):
		for y in range(start_y, start_y + h):
			cells.append(Vector2i(x, y))
