class_name Level04
extends BaseLevel

func _ready() -> void:
	level_theme_color = Color(0.4, 0.88, 1.0, 1.0)
	super._ready()
	# Customização do banner de spawn (posição acima da base inicial)
	configure_spawn_info(Vector2(72, 545), 12, 12, 1, true)
	_build_level()

func _build_level() -> void:
	var layer = $TileMapLayer as TileMapLayer
	if not layer:
		return

	# =========================================================================
	# 0. BASE LAVA FLOOR (Abyss across screen bottom: Rows 43 and 44)
	# =========================================================================
	for x in range(80):
		layer.set_cell(Vector2i(x, 43), 5, Vector2i(0, 0))
		layer.set_cell(Vector2i(x, 44), 5, Vector2i(0, 0))

	# =========================================================================
	# TIER 1: Bottom floor (Moving Left to Right)
	# =========================================================================
	# Spawn Base (Station metal platform - solid traction)
	_build_station_box(layer, 2, 38, 6, 5)

	# Thin Ice Pillars (alternating between 2 and 3 tiles width)
	_build_ice_pillar(layer, 8, 38, 10)
	_build_ice_pillar(layer, 22, 37, 3)
	_build_ice_pillar(layer, 28, 36, 2)
	_build_ice_pillar(layer, 33, 36, 3)
	_build_ice_pillar(layer, 39, 35, 2)
	_build_ice_pillar(layer, 44, 35, 3)
	_build_ice_pillar(layer, 50, 34, 2)
	_build_ice_pillar(layer, 55, 34, 3)
	_build_ice_pillar(layer, 61, 33, 2)
	_build_ice_pillar(layer, 66, 33, 2)

	# Station Haven 1: Turnaround platform on the far right (Normal traction)
	_build_station_box(layer, 71, 32, 7, 6)

	# =========================================================================
	# TIER 2: Middle floor (Climbing & Moving Right to Left)
	# =========================================================================
	# Ice Pillars climbing up-left
	_build_ice_pillar(layer, 65, 28, 3)
	_build_ice_pillar(layer, 59, 28, 2)
	_build_ice_pillar(layer, 53, 27, 3)
	_build_ice_pillar(layer, 47, 27, 2)

	# Suspended Station Structure & Downward Spikes above Tier 2
	_build_station_box(layer, 34, 18, 15, 3)
	for x in range(35, 48):
		layer.set_cell(Vector2i(x, 21), 6, Vector2i(0, 0), 1) # Inverted ceiling spike

	# Low-clearance Ice Pillars beneath ceiling spikes (forces low tap jumps)
	_build_ice_pillar(layer, 41, 26, 3)
	_build_ice_pillar(layer, 35, 26, 2)
	_build_ice_pillar(layer, 29, 25, 3)
	_build_ice_pillar(layer, 23, 25, 2)
	_build_ice_pillar(layer, 17, 24, 3)
	_build_ice_pillar(layer, 11, 24, 2)

	# Station Haven 2: Turnaround platform on the far left (Normal traction)
	_build_station_box(layer, 2, 23, 6, 5)

	# =========================================================================
	# TIER 3: Top floor (Climbing & Moving Left to Right toward the Comet)
	# =========================================================================
	# Ice Pillars climbing up-right
	_build_ice_pillar(layer, 11, 19, 3)
	_build_ice_pillar(layer, 17, 19, 2)
	_build_ice_pillar(layer, 22, 18, 3)
	_build_ice_pillar(layer, 28, 18, 2)
	_build_ice_pillar(layer, 33, 17, 3)
	_build_ice_pillar(layer, 39, 17, 2)

	# Floating Obstacle in mid-air
	layer.set_cell(Vector2i(44, 13), 4, Vector2i(0, 0)) # Station block
	layer.set_cell(Vector2i(44, 14), 6, Vector2i(0, 0), 1) # Spike hanging down

	_build_ice_pillar(layer, 45, 16, 3)
	_build_ice_pillar(layer, 52, 15, 2)
	_build_ice_pillar(layer, 58, 14, 3)

	# Final Launch Runway: 5-tile ice runway to build up momentum for the grand leap
	_build_ice_pillar(layer, 64, 13, 5)

	# Goal Platform: Floating Sanctum holding the Comet
	_build_station_box(layer, 74, 11, 5, 4)

func _build_ice_pillar(layer: TileMapLayer, start_x: int, y: int, width: int, height: int = 2) -> void:
	for x in range(start_x, start_x + width):
		for py in range(y, y + height):
			layer.set_cell(Vector2i(x, py), 7, Vector2i(0, 0), 0)

func _build_station_box(layer: TileMapLayer, start_x: int, start_y: int, w: int, h: int) -> void:
	for x in range(start_x, start_x + w):
		for y in range(start_y, start_y + h):
			var is_left: bool = (x == start_x)
			var is_right: bool = (x == start_x + w - 1)
			var is_top: bool = (y == start_y)
			var is_bottom: bool = (y == start_y + h - 1)

			if is_top and is_left:
				layer.set_cell(Vector2i(x, y), 9, Vector2i(0, 0), 0) # Corner Top-Left
			elif is_top and is_right:
				layer.set_cell(Vector2i(x, y), 9, Vector2i(0, 0), 1) # Corner Top-Right
			elif is_bottom and is_left:
				layer.set_cell(Vector2i(x, y), 9, Vector2i(0, 0), 2) # Corner Bottom-Left
			elif is_bottom and is_right:
				layer.set_cell(Vector2i(x, y), 9, Vector2i(0, 0), 3) # Corner Bottom-Right
			elif is_top:
				layer.set_cell(Vector2i(x, y), 8, Vector2i(0, 0), 0) # Outter Top
			elif is_bottom:
				layer.set_cell(Vector2i(x, y), 8, Vector2i(0, 0), 1) # Outter Bottom
			elif is_left:
				layer.set_cell(Vector2i(x, y), 8, Vector2i(0, 0), 2) # Outter Left
			elif is_right:
				layer.set_cell(Vector2i(x, y), 8, Vector2i(0, 0), 3) # Outter Right
			else:
				layer.set_cell(Vector2i(x, y), 10, Vector2i(0, 0), 0) # Filling Center
