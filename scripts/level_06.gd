class_name Level06
extends BaseLevel

# Base tile flags provided by Godot
const FLIP_H = 1 << 12
const FLIP_V = 1 << 13
const TRANSPOSE = 1 << 14

func _ready() -> void:
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
		layer.set_cell(Vector2i(x, 2), 8, Vector2i(0, 0), 1) # Outter Bottom facing down
	layer.set_cell(Vector2i(1, 2), 9, Vector2i(0, 0), 0)    # Corner TL
	layer.set_cell(Vector2i(78, 2), 9, Vector2i(0, 0), 1)   # Corner TR

	# Bottom outer wall at Y = 43
	for x in range(2, 78):
		layer.set_cell(Vector2i(x, 43), 8, Vector2i(0, 0), 0) # Outter Top facing up
	layer.set_cell(Vector2i(1, 43), 9, Vector2i(0, 0), 2)    # Corner BL
	layer.set_cell(Vector2i(78, 43), 9, Vector2i(0, 0), 3)   # Corner BR

	# Left and Right outer vertical borders
	for y in range(3, 43):
		layer.set_cell(Vector2i(1, y), 8, Vector2i(0, 0), 3)  # Outter Right facing into room
		layer.set_cell(Vector2i(78, y), 8, Vector2i(0, 0), 2) # Outter Left facing into room

	# Bottom deadly pit bed of spikes (Row 42)
	for x in range(2, 78):
		_set_spike_up(layer, x, 42)

	# =========================================================================
	# 2. HORIZONTAL DIVIDERS (Creating 4 Descending Tiers)
	# =========================================================================
	# Divider 1 (between Tier 1 and Tier 2): leaves Shaft 1 open at X = 69..77
	_build_divider(layer, 2, 68, 10)

	# Divider 2 (between Tier 2 and Tier 3): leaves Shaft 2 open at X = 2..10
	_build_divider(layer, 11, 77, 20)

	# Divider 3 (between Tier 3 and Tier 4): leaves Shaft 3 open at X = 69..77
	_build_divider(layer, 2, 68, 30)

	# =========================================================================
	# 3. TIER 1: Spawn & Left-to-Right Walkway (Y = 8)
	# =========================================================================
	# Low ceiling under top border (Row 3 ceiling with hanging spikes)
	for x in range(12, 19):
		_set_spike_down(layer, x, 3)
	for x in range(30, 36):
		_set_spike_down(layer, x, 3)
	for x in range(48, 54):
		_set_spike_down(layer, x, 3)
	# Spikes right above Shaft 1 drop opening to punish jumping into the drop:
	for x in range(63, 69):
		_set_spike_down(layer, x, 3)

	# Spawn Safe Base: X = 2..8, Y = 8
	_build_platform_composite(layer, 2, 8, 8)
	_set_spike_right(layer, 9, 8)

	# Platform 1: X = 13..18, Y = 8
	_set_spike_left(layer, 12, 8)
	_build_platform_composite(layer, 13, 18, 8)
	_set_spike_right(layer, 19, 8)

	# Platform 2: X = 24..30, Y = 8
	_set_spike_left(layer, 23, 8)
	_build_platform_composite(layer, 24, 30, 8)
	_set_spike_right(layer, 31, 8)

	# Platform 3: X = 36..43, Y = 8
	_set_spike_left(layer, 35, 8)
	_build_platform_composite(layer, 36, 43, 8)
	_set_spike_right(layer, 44, 8)

	# Platform 4 (Lead-in to Shaft 1): X = 49..68, Y = 8
	_set_spike_left(layer, 48, 8)
	_build_platform_composite(layer, 49, 68, 8)
	_set_spike_right(layer, 69, 8)

	# =========================================================================
	# 4. SHAFT 1: High-Gravity Descent 1 (Right Side: X = 69..77, Y = 9..18)
	# =========================================================================
	# Intercalated side spikes forcing mid-air steering during rapid fall:
	_set_spike_left(layer, 77, 12)  # Right wall spike
	_set_spike_right(layer, 69, 14) # Left wall spike
	_set_spike_left(layer, 77, 16)  # Right wall spike

	# =========================================================================
	# 5. TIER 2: Right-to-Left Walkway (Y = 18)
	# =========================================================================
	# Ceiling spikes under Divider 1 (at Y = 12) punishing excessive jump height:
	for x in range(53, 59):
		_set_spike_down(layer, x, 12)
	for x in range(35, 41):
		_set_spike_down(layer, x, 12)
	for x in range(17, 23):
		_set_spike_down(layer, x, 12)
	# Drop warning spikes near Shaft 2 entrance:
	for x in range(11, 16):
		_set_spike_down(layer, x, 12)

	# Landing Base from Shaft 1: X = 64..75, Y = 18
	_set_spike_left(layer, 63, 18)
	_build_platform_composite(layer, 64, 75, 18)

	# Platform 1: X = 50..56, Y = 18
	_set_spike_right(layer, 57, 18)
	_build_platform_composite(layer, 50, 56, 18)
	_set_spike_left(layer, 49, 18)

	# Platform 2: X = 34..42, Y = 18
	_set_spike_right(layer, 43, 18)
	_build_platform_composite(layer, 34, 42, 18)
	_set_spike_left(layer, 33, 18)

	# Platform 3: X = 20..26, Y = 18
	_set_spike_right(layer, 27, 18)
	_build_platform_composite(layer, 20, 26, 18)
	_set_spike_left(layer, 19, 18)

	# Platform 4 (Lead-in to Shaft 2): X = 11..14, Y = 18
	_set_spike_right(layer, 15, 18)
	_build_platform_composite(layer, 11, 14, 18)
	_set_spike_left(layer, 10, 18)

	# =========================================================================
	# 6. SHAFT 2: High-Gravity Descent 2 (Left Side: X = 2..10, Y = 19..28)
	# =========================================================================
	# Intercalated side spikes during descent:
	_set_spike_right(layer, 2, 22)  # Left wall spike
	_set_spike_left(layer, 10, 24)  # Right wall spike
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
	_set_spike_right(layer, 14, 28)

	# Platform 1: X = 19..25, Y = 28
	_set_spike_left(layer, 18, 28)
	_build_platform_composite(layer, 19, 25, 28)
	_set_spike_right(layer, 26, 28)

	# Platform 2: X = 32..38, Y = 28
	_set_spike_left(layer, 31, 28)
	_build_platform_composite(layer, 32, 38, 28)
	_set_spike_right(layer, 39, 28)

	# Platform 3: X = 45..51, Y = 28
	_set_spike_left(layer, 44, 28)
	_build_platform_composite(layer, 45, 51, 28)
	_set_spike_right(layer, 52, 28)

	# Platform 4 (Lead-in to Shaft 3): X = 58..68, Y = 28
	_set_spike_left(layer, 57, 28)
	_build_platform_composite(layer, 58, 68, 28)
	_set_spike_right(layer, 69, 28)

	# =========================================================================
	# 8. SHAFT 3: High-Gravity Descent 3 (Right Side: X = 69..77, Y = 29..39)
	# =========================================================================
	# Final chute with rapid plunge and staggered spikes:
	_set_spike_left(layer, 77, 32)  # Right wall spike
	_set_spike_right(layer, 69, 34) # Left wall spike
	_set_spike_left(layer, 77, 36)  # Right wall spike
	_set_spike_right(layer, 69, 38) # Left wall spike

	# =========================================================================
	# 9. TIER 4: Final Base & Sprint to Comet (Right-to-Left, Y = 40)
	# =========================================================================
	# Landing Base from Shaft 3: X = 65..76, Y = 40
	_set_spike_left(layer, 64, 40)
	_build_platform_composite(layer, 65, 76, 40)

	# Stepping Platform 1: X = 50..56, Y = 40
	_set_spike_right(layer, 57, 40)
	_build_platform_composite(layer, 50, 56, 40)
	_set_spike_left(layer, 49, 40)

	# Stepping Platform 2: X = 36..42, Y = 40
	_set_spike_right(layer, 43, 40)
	_build_platform_composite(layer, 36, 42, 40)
	_set_spike_left(layer, 35, 40)

	# Stepping Platform 3: X = 22..28, Y = 40
	_set_spike_right(layer, 29, 40)
	_build_platform_composite(layer, 22, 28, 40)
	_set_spike_left(layer, 21, 40)

	# Goal Sanctum Pedestal (Comet Base): X = 6..12, Y = 40
	_set_spike_right(layer, 13, 40)
	_build_platform_composite(layer, 6, 12, 40)

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
		layer.set_cell(Vector2i(x, y), 8, Vector2i(0, 0), 0)     # Top edge: clean outter plate
		layer.set_cell(Vector2i(x, y + 1), 4, Vector2i(0, 0), 0) # Bottom edge: broken station with wires

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
			layer.set_cell(Vector2i(x, y), 8, Vector2i(0, 0), 0)   # Outter Top
		layer.set_cell(Vector2i(end_x, y), 9, Vector2i(0, 0), 1)   # Corner TR
