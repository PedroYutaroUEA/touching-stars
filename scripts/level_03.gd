class_name Level03
extends BaseLevel

const PLATFORM_SCENE = preload("res://entities/moving_text_platform.tscn")

func _ready() -> void:
	super._ready()
	_spawn_platforms()
	_build_floor()

func _build_floor() -> void:
	var layer = $TileMapLayer as TileMapLayer
	if not layer: return
	
	# Spawn a small safe platform at start
	var cells: Array[Vector2i] = []
	_add_rect_cells(cells, 2, 35, 6, 10) # Start safe zone
	
	# Small goal platform
	_add_rect_cells(cells, 72, 12, 6, 4) # End safe zone, very high up!
	
	layer.set_cells_terrain_connect(cells, 0, 0, true)
	
	# Lava floor at bottom so falling kills
	for x in range(80):
		layer.set_cell(Vector2i(x, 43), 5, Vector2i(0, 0))
		layer.set_cell(Vector2i(x, 44), 5, Vector2i(0, 0))

func _spawn_platforms() -> void:
	# Horizontal step-on-me
	_add_platform("STEPONME", 0, Vector2(250, 500), Vector2(200, 0), 1.5)
	
	# Vertical killer
	_add_platform("THISPLATFORMKILLS", 1, Vector2(500, 200), Vector2(0, 350), 1.5)
	
	# Diagonal step-on-me
	_add_platform("NOTATRAPTRUSTME", 0, Vector2(550, 600), Vector2(150, -200), 2.0)
	
	# Ghost platform to bait player
	_add_platform("TSWASNTTHEWIND", 2, Vector2(650, 350), Vector2(750, 0), 0.25) # static
	
	# Fast vertical killer
	_add_platform("THISPLATFORMKILLS", 1, Vector2(800, 600), Vector2(0, -500), 2.0)
	
	# Sequence of small safe steps moving up
	_add_platform("STEP", 0, Vector2(850, 450), Vector2(0, -100), 1.0)
	_add_platform("ON", 0, Vector2(950, 300), Vector2(0, 100), 1.0)
	# Final trap
	_add_platform("ME?", 1, Vector2(1100, 140), Vector2(150, 0), 0.5)
	# Pussy block
	_add_platform("ME!", 0, Vector2(1100, 300), Vector2(250, 0), 1.0)
	
	# Giant killer sweep across the top
	_add_platform("THISPLATFORMKILLS", 1, Vector2(1000, 50), Vector2(-800, 0), 4.0)
	
	# Another ghost
	_add_platform("TSWASNTTHEWIND", 2, Vector2(300, 250), Vector2(100, 100), 2.0)
	
	# More chaos
	_add_platform("STEPONME", 0, Vector2(100, 300), Vector2(150, 0), 1.5)
	_add_platform("THISPLATFORMKILLS", 1, Vector2(200, 350), Vector2(0, 150), 0.8)

func _add_platform(txt: String, p_type: int, start_pos: Vector2, offset: Vector2, duration: float) -> void:
	var p = PLATFORM_SCENE.instantiate()
	p.text = txt
	p.platform_type = p_type
	p.global_position = start_pos
	p.target_offset = offset
	p.move_duration = duration
	add_child(p)

func _add_rect_cells(cells: Array[Vector2i], start_x: int, start_y: int, w: int, h: int) -> void:
	for x in range(start_x, start_x + w):
		for y in range(start_y, start_y + h):
			cells.append(Vector2i(x, y))
