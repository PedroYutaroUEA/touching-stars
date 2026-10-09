class_name Level02
extends BaseLevel

func _ready() -> void:
	super._ready()
	_build_terrain()

func _build_terrain() -> void:
	var layer = $TileMapLayer as TileMapLayer
	if not layer: return
	
	var cells: Array[Vector2i] = []
	
	# Grid 16x16 (Viewport: 80x45)
	
	# Platform 1 (Spawn)
	_add_rect_cells(cells, 0, 42, 12, 3)
	
	# Platform 2 (Middle Safe Zone)
	_add_rect_cells(cells, 43, 40, 2, 4)
	
	# Platform 3 (Goal)
	_add_rect_cells(cells, 66, 42, 4, 3)
	
	layer.set_cells_terrain_connect(cells, 0, 1, true)
			
	# Giant Block 2 of broken-station (over Gap 2)
	for x in range(50, 62):
		# Bottom row of upside down spikes
		layer.set_cell(Vector2i(x, 34), 6, Vector2i(0, 0), 1)
		# Giant column
		for y in range(14, 34):
			layer.set_cell(Vector2i(x, y), 4, Vector2i(0, 0))
		
	
	# Lava floor (Source 5)
	for x in range(80):
		layer.set_cell(Vector2i(x, 43), 5, Vector2i(0, 0))
		layer.set_cell(Vector2i(x, 44), 5, Vector2i(0, 0))

func _add_rect_cells(cells: Array[Vector2i], start_x: int, start_y: int, w: int, h: int) -> void:
	for x in range(start_x, start_x + w):
		for y in range(start_y, start_y + h):
			cells.append(Vector2i(x, y))
