class_name Level06
extends BaseLevel

# Base tile flags provided by Godot
const FLIP_H = 1 << 12
const FLIP_V = 1 << 13
const TRANSPOSE = 1 << 14

func _ready() -> void:
	level_theme_color = Color(1.0, 0.78, 0.3, 1.0)
	super._ready()
	_build_saturn_descent()

func _build_saturn_descent() -> void:
	var layer = $TileMapLayer as TileMapLayer
	if not layer:
		return

	# =========================================================================
	# 1. OUTER BORDER WALLS (Composite Station Architecture)
	# =========================================================================
	# Top outer wall at Y = 2
	for x in range(2, 78):
		layer.set_cell(Vector2i(x, 2), 2, Vector2i(0, 0), 0) # Outter Bottom facing down
	layer.set_cell(Vector2i(1, 2), 2, Vector2i(0, 0), 0)    # Corner TL
	layer.set_cell(Vector2i(78, 2), 2, Vector2i(0, 0), 0)   # Corner TR

	# Bottom outer wall at Y = 43
	for x in range(2, 78):
		layer.set_cell(Vector2i(x, 43), 2, Vector2i(0, 0), 0) # Outter Top facing up
	layer.set_cell(Vector2i(1, 43), 2, Vector2i(0, 0), 0)    # Corner BL
	layer.set_cell(Vector2i(78, 43), 2, Vector2i(0, 0), 0)   # Corner BR

	# Left and Right outer vertical borders
	for y in range(3, 43):
		layer.set_cell(Vector2i(1, y), 2, Vector2i(0, 0), 0)  # Outter Right facing into room
		layer.set_cell(Vector2i(78, y), 2, Vector2i(0, 0), 0) # Outter Left facing into room

	# Bottom deadly pit bed of spikes (Row 42)
	for x in range(2, 78):
		_set_spike_up(layer, x, 42)

	# =========================================================================
	# 2. HORIZONTAL DIVIDERS (Creating 4 Descending Tiers)
	# =========================================================================
	# Divider 1 (between Tier 1 and Tier 2): leaves Shaft 1 open at X = 69..77
	_set_spike_up(layer, 12, 9)
	_build_divider(layer, 2, 14, 10)
	
	_build_divider(layer, 17, 18, 10)
	
	_build_divider(layer, 24, 30, 10)
	_set_spike_down(layer, 25, 8)
	
	_set_spike_down(layer, 28, 8)
	_build_divider(layer, 38, 68, 10)

	# Divider 2 (between Tier 2 and Tier 3): leaves Shaft 2 open at X = 2..10
	_build_divider(layer, 11, 77, 20)
	for x in range(11, 77):
		_set_spike_up(layer, x, 19)

	# Divider 3 (between Tier 3 and Tier 4): leaves Shaft 3 open at X = 69..77
	_build_divider(layer, 2, 68, 30)

	# =========================================================================
	# 3. TIER 1: Spawn & Left-to-Right Walkway (Y = 8)
	# =========================================================================
	# Low ceiling under top border (Row 3 ceiling with hanging spikes)
	for x in range(8, 19):
		_set_spike_down(layer, x, 3)
	for x in range(30, 36):
		_set_spike_down(layer, x, 3)
	for x in range(48, 58):
		_set_spike_down(layer, x, 3)
	# Spikes right above Shaft 1 drop opening to punish jumping into the drop:
	for x in range(63, 69):
		_set_spike_down(layer, x, 3)

	# Spawn Safe Base: X = 2..8, Y = 8
	_build_platform_composite(layer, 3, 8, 7)
	#_set_spike_right(layer, 9, 7)

	# Platform 1: X = 13..18, Y = 8
	_set_spike_left(layer, 12, 7)
	_set_spike_up(layer, 13, 6)
	_build_platform_composite(layer, 13, 18, 7)
	_set_spike_right(layer, 19, 7)

	# Platform 2: X = 24..30, Y = 8
	_set_spike_left(layer, 23, 7)
	_build_platform_composite(layer, 24, 30, 7)
	#_set_spike_right(layer, 31, 7)

	# Platform 3: X = 36..43, Y = 8
	_set_spike_left(layer, 37, 7)
	_build_platform_composite(layer, 38, 45, 7)
	_set_spike_up(layer, 45, 6)
	_set_spike_right(layer, 46, 7)

	# Platform 4 (Lead-in to Shaft 1): X = 49..68, Y = 8
	_set_spike_left(layer, 48, 7)
	_build_platform_composite(layer, 49, 68, 7)
	# parkour trap
	_build_platform_composite(layer, 55, 55, 6)
	for x in range(56, 60):
		_set_spike_up(layer, x, 6)
	_build_platform_composite(layer, 60, 61, 5)
	_build_platform_composite(layer, 60, 61, 6)
	_set_spike_right(layer, 69, 7)

	# =========================================================================
	# 4. SHAFT 1: High-Gravity Descent 1 (Right Side: X = 69..77, Y = 9..18)
	# =========================================================================
	# Intercalated side spikes forcing mid-air steering during rapid fall:
	_set_spike_left(layer, 77, 12)  # Right wall spike
	_set_spike_left(layer, 77, 14) # Left wall spike
	_set_spike_left(layer, 77, 16)  # Right wall spike

	# =========================================================================
	# 5. TIER 2: Right-to-Left Walkway (Y = 18)
	# =========================================================================
	# Ceiling spikes under Divider 1 (at Y = 12) punishing excessive jump height:
	for x in range(53, 59):
		_set_spike_down(layer, x, 12)
	for x in range(39, 46):
		_set_spike_down(layer, x, 12)
	for x in range(24, 31):
		_set_spike_down(layer, x, 12)
	for x in range(17, 19):
		_set_spike_down(layer, x, 12)
	# Drop warning spikes near Shaft 2 entrance:
	for x in range(11, 15):
		_set_spike_down(layer, x, 12)

	# Landing Base from Shaft 1: X = 64..75, Y = 18
	_set_spike_left(layer, 63, 18)
	_build_platform_composite(layer, 64, 75, 18)

	# Platform 1: X = 50..56, Y = 18
	_set_spike_up(layer, 56, 17)
	_build_platform_composite(layer, 50, 56, 18)
	_set_spike_left(layer, 49, 18)

	# Platform 2: X = 34..42, Y = 18
	_set_spike_right(layer, 43, 18)
	_build_platform_composite(layer, 34, 42, 18)
	_set_spike_left(layer, 33, 18)

	# Platform 3: X = 20..26, Y = 18
	_set_spike_right(layer, 27, 18)
	_build_platform_composite(layer, 21, 26, 18)
	_set_spike_up(layer, 21, 17)
	_set_spike_up(layer, 24, 17)
	_set_spike_left(layer, 20, 18)

	# Platform 4 (Lead-in to Shaft 2): X = 11..14, Y = 18
	_set_spike_right(layer, 15, 18)
	_build_platform_composite(layer, 11, 14, 18)
	_set_spike_left(layer, 10, 18)

	# =========================================================================
	# 6. SHAFT 2: High-Gravity Descent 2 (Left Side: X = 2..10, Y = 19..28)
	# =========================================================================
	# Intercalated side spikes during descent:
	_set_spike_right(layer, 2, 22)  # Left wall spike
	_build_platform_composite(layer, 2, 4, 24)
	_set_spike_right(layer, 4, 24)  # Right wall spike
	_set_spike_right(layer, 2, 26)  # Left wall spike

	# =========================================================================
	# 7. TIER 3: Left-to-Right Walkway (Y = 28)
	# =========================================================================
	# Ceiling spikes under Divider 2 (at Y = 22):
	for x in range(16, 22):
		_set_spike_down(layer, x, 22)
	for x in range(30, 36):
		_set_spike_down(layer, x, 22)
	for x in range(44, 50):
		_set_spike_down(layer, x, 22)
	for x in range(61, 67):
		_set_spike_down(layer, x, 22)

	# Landing Base from Shaft 2: X = 4..13, Y = 28
	_build_platform_composite(layer, 4, 13, 28)
	for x in range(5, 11):
		_set_spike_up(layer, x, 27)
	_set_spike_right(layer, 14, 28)
	
	_build_platform_composite(layer, 16, 16, 27)
	_build_platform_composite(layer, 16, 16, 26)
	_build_platform_composite(layer, 16, 16, 25)

	# Platform 1: X = 19..25, Y = 28
	_set_spike_left(layer, 18, 28)
	_build_platform_composite(layer, 19, 25, 28)
	_set_spike_up(layer, 21, 27)
	_set_spike_up(layer, 22, 27)
	_set_spike_up(layer, 23, 27)
	_set_spike_right(layer, 26, 28)

	_build_platform_composite(layer, 28, 28, 26)
	_build_platform_composite(layer, 29, 29, 27)
	_build_platform_composite(layer, 28, 28, 28)

	# Platform 2: X = 32..38, Y = 28
	_set_spike_left(layer, 31, 28)
	_build_platform_composite(layer, 32, 38, 28)
	_set_spike_up(layer, 32, 27)
	_set_spike_up(layer, 34, 27)
	_set_spike_up(layer, 36, 27)
	_set_spike_up(layer, 38, 27)
	_set_spike_right(layer, 39, 28)

	_build_platform_composite(layer, 42, 42, 26)
	_build_platform_composite(layer, 41, 41, 27)
	_build_platform_composite(layer, 42, 42, 28)

	# Platform 3: X = 45..51, Y = 28
	_set_spike_left(layer, 44, 28)
	_build_platform_composite(layer, 45, 51, 28)
	_set_spike_up(layer, 46, 27)
	_set_spike_up(layer, 48, 27)
	_set_spike_up(layer, 50, 27)
	
	_build_platform_composite(layer, 53, 53, 25)
	_set_spike_up(layer, 53, 27)
	_set_spike_down(layer, 53, 28)
	
	_build_platform_composite(layer, 56, 56, 25)
	_set_spike_up(layer, 56, 27)
	_set_spike_down(layer, 56, 28)
	
	# Platform 4 (Lead-in to Shaft 3): X = 58..68, Y = 28
	_build_platform_composite(layer, 58, 68, 28)
	_set_spike_up(layer, 59, 27)
	_set_spike_up(layer, 61, 27)
	
	_set_spike_up(layer, 65, 27)
	_set_spike_up(layer, 66, 27)
	_set_spike_up(layer, 67, 27)
	_set_spike_up(layer, 68, 27)
	_set_spike_right(layer, 69, 28)

	# =========================================================================
	# 8. SHAFT 3: High-Gravity Descent 3 (Right Side: X = 69..77, Y = 29..39)
	# =========================================================================
	# Final chute with rapid plunge and staggered spikes:
	_set_spike_left(layer, 77, 32)  # Right wall spike
	_set_spike_left(layer, 77, 36)  # Right wall spike

	# =========================================================================
	# 9. TIER 4: Final Base & Sprint to Comet (Right-to-Left, Y = 40)
	# =========================================================================
	# Landing Base from Shaft 3: X = 65..76, Y = 40
	_set_spike_up(layer, 66, 39)
	_set_spike_left(layer, 64, 40)
	_build_platform_composite(layer, 65, 76, 40)

	# Stepping Platform 1: X = 50..56, Y = 40
	_set_spike_right(layer, 57, 40)
	_build_platform_composite(layer, 48, 56, 40)
	_set_spike_up(layer, 48, 39)
	_set_spike_up(layer, 51, 39)

	_set_spike_up(layer, 46, 38)
	_build_platform_composite(layer, 46, 46, 39)


	# Stepping Platform 2: X = 36..42, Y = 40
	_set_spike_right(layer, 43, 40)
	_set_spike_up(layer, 41, 39)
	_set_spike_up(layer, 39, 39)
	_build_platform_composite(layer, 36, 42, 40)
	_set_spike_left(layer, 35, 40)

	_build_platform_composite(layer, 32, 32, 38)

	# Stepping Platform 3: X = 22..28, Y = 40
	_set_spike_right(layer, 29, 40)
	_set_spike_up(layer, 28, 39)
	_set_spike_up(layer, 27, 39)
	_set_spike_up(layer, 24, 39)
	_build_platform_composite(layer, 22, 28, 40)
	_set_spike_left(layer, 21, 40)

	_set_spike_left(layer, 21, 33)
	_set_spike_down(layer, 22, 34)
	_set_spike_down(layer, 24, 34)
	_build_platform_composite(layer, 22, 24, 33)
	_set_spike_right(layer, 25, 33)

	_build_platform_composite(layer, 23, 23, 37)
	_set_spike_left(layer, 21, 36)
	_build_platform_composite(layer, 22, 22, 36)

	# Goal Sanctum Pedestal (Comet Base): X = 6..12, Y = 40
	_set_spike_up(layer, 12, 36)
	_set_spike_up(layer, 11, 36)
	_build_platform_composite(layer, 11, 12, 37)
	_set_spike_down(layer, 12, 38)
	_set_spike_down(layer, 11, 38)
	
	_set_spike_right(layer, 13, 40)
	_build_platform_composite(layer, 11, 12, 40)
	_set_spike_left(layer, 10, 37)
# =============================================================================
# HELPER FUNCTIONS (Composite Station & Directional Spikes)
# =============================================================================
func _set_spike_up(layer: TileMapLayer, x: int, y: int) -> void:
	layer.set_cell(Vector2i(x, y), 6, Vector2i(0, 0), 0)

func _set_spike_down(layer: TileMapLayer, x: int, y: int) -> void:
	layer.set_cell(Vector2i(x, y), 6, Vector2i(0, 0), FLIP_H | FLIP_V)

func _set_spike_left(layer: TileMapLayer, x: int, y: int) -> void:
	layer.set_cell(Vector2i(x, y), 6, Vector2i(0, 0), FLIP_V | TRANSPOSE)

func _set_spike_right(layer: TileMapLayer, x: int, y: int) -> void:
	layer.set_cell(Vector2i(x, y), 6, Vector2i(0, 0), FLIP_H | TRANSPOSE)

func _build_divider(layer: TileMapLayer, start_x: int, end_x: int, y: int) -> void:
	for x in range(start_x, end_x + 1):
		layer.set_cell(Vector2i(x, y), 2, Vector2i(0, 0), 0)     # Top edge: clean outter plate
		layer.set_cell(Vector2i(x, y + 1), 2, Vector2i(0, 0), 0) # Bottom edge: broken station with wires

func _build_platform_composite(layer: TileMapLayer, start_x: int, end_x: int, y: int) -> void:
	var width: int = end_x - start_x + 1
	if width == 1:
		layer.set_cell(Vector2i(start_x, y), 4, Vector2i(0, 0), 0)
	elif width == 2:
		layer.set_cell(Vector2i(start_x, y), 9, Vector2i(0, 0), 0) # Corner TL
		layer.set_cell(Vector2i(end_x, y), 9, Vector2i(0, 0), 1)   # Corner TR
	else:
		layer.set_cell(Vector2i(start_x, y), 9, Vector2i(0, 0), 0) # Corner TL
		for x in range(start_x + 1, end_x):
			layer.set_cell(Vector2i(x, y), 9, Vector2i(0, 0), 0)   # Outter Top
		layer.set_cell(Vector2i(end_x, y), 9, Vector2i(0, 0), 1)   # Corner TR
