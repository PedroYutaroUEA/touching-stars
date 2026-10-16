class_name Level05
extends BaseLevel

# Base tile flags provided by Godot
const FLIP_H = 1 << 12
const FLIP_V = 1 << 13
const TRANSPOSE = 1 << 14

func _ready() -> void:
	level_theme_color = Color(0.98, 0.35, 0.5, 1.0)
	super._ready()
	_build_spike_maze()

func _build_spike_maze() -> void:
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

	# Bottom pit bed of spikes (Row 42)
	for x in range(2, 78):
		_set_spike_up(layer, x, 42)

	# =========================================================================
	# 2. HORIZONTAL DIVIDER WALLS (With Station borders and hanging wires)
	# =========================================================================
	# Divider 1 (between Floor 1 and Floor 2): leaves Shaft 1 open at X = 69..77
	_build_divider(layer, 2, 68, 34)

	# Divider 2 (between Floor 2 and Floor 3): leaves Shaft 2 open at X = 2..10
	_build_divider(layer, 11, 77, 24)

	# Divider 3 (between Floor 3 and Floor 4): leaves Shaft 3 open at X = 69..77
	_build_divider(layer, 2, 68, 14)

	# =========================================================================
	# 3. FLOOR 1: Walkway with Spikes Attached to Sides (Moving Left -> Right)
	# =========================================================================
	# Spawn Safe Base
	_build_platform_composite(layer, 2, 7, 40)

	# Platforms with side-attached spikes (no floating spikes in mid-air!)
	# Platform 1: X = 10..12
	_set_spike_up(layer, 7, 39)
	_set_spike_right(layer, 8, 40) # Spike sticking right from spawn base
	_build_platform_composite(layer, 10, 12, 40)
	_set_spike_left(layer, 9, 40)   # Protruding left from platform 1
	_set_spike_up(layer, 10, 39)

	# Platform 2: X = 16..18
	_set_spike_right(layer, 13, 40) # Protruding right from platform 1
	_build_platform_composite(layer, 16, 18, 40)
	_set_spike_left(layer, 15, 40)
	_set_spike_right(layer, 19, 40)

	# Platform 3: X = 22..24
	_build_platform_composite(layer, 22, 24, 40)
	_set_spike_left(layer, 21, 40)
	_set_spike_right(layer, 25, 40)

	# Platform 4: X = 28..31
	_set_spike_left(layer, 27, 40)
	_set_spike_up(layer, 28, 39)
	_build_platform_composite(layer, 28, 31, 40)
	_set_spike_up(layer, 31, 39)
	_set_spike_right(layer, 32, 40)

	# Platform 5: X = 35..38
	_set_spike_left(layer, 34, 40)
	_set_spike_up(layer, 35, 39)
	_build_platform_composite(layer, 35, 38, 40)
	_set_spike_right(layer, 39, 40)

	# Platform 6: X = 43..46
	_set_spike_down(layer, 42, 36)
	#_set_spike_left(layer, 42, 40)
	_build_platform_composite(layer, 43, 46, 40)
	_set_spike_up(layer, 45, 39)
	#_set_spike_right(layer, 47, 40)
	_set_spike_down(layer, 47, 36)

	# Platform 7: X = 51..54
	_build_platform_composite(layer, 51, 54, 40)
	_set_spike_left(layer, 50, 40)
	_set_spike_right(layer, 55, 40)

	# Platform 8 (Lead into Shaft 1): X = 59..68
	_set_spike_left(layer, 58, 40)
	_build_platform_composite(layer, 59, 68, 40)
	_set_spike_right(layer, 69, 40)
	
	# Ceiling spikes under Divider 1 to force controlled hops
	for x in range(14, 25):
		_set_spike_down(layer, x, 35)
	for x in range(32, 42):
		_set_spike_down(layer, x, 35)
	for x in range(48, 58):
		_set_spike_down(layer, x, 35)

	# =========================================================================
	# 4. SHAFT 1: Vertical Climb (Right Side: X = 69..77, Y = 25..42)
	# =========================================================================
	# Right wall lined with spikes pointing LEFT into the shaft
	for y in range(26, 42):
		_set_spike_left(layer, 77, y)

	# Left wall at X = 69: NO BLOCKING SPIKES AT Y = 26..33 (Entrance to Floor 2 is OPEN!)
	# Stepping stones in Shaft 1 (2x1 and 1x1 metal blocks)
	_set_spike_left(layer, 72, 38)
	_build_platform_composite(layer, 73, 75, 38)
	_set_spike_up(layer, 75, 37)
	_build_platform_composite(layer, 70, 72, 35)
	_build_platform_composite(layer, 73, 75, 32)
	_build_platform_composite(layer, 70, 72, 29)
	_build_platform_composite(layer, 73, 75, 26)

	# =========================================================================
	# 5. FLOOR 2: The "Zipper" (Sobe e Desce Apertado, Y = 25..33, Moving R -> L)
	# =========================================================================
	# Base Floor at Y = 32
	for x in range(11, 69):
		layer.set_cell(Vector2i(x, 32), 8, Vector2i(0, 0), 0)
	
	_set_spike_up(layer, 68, 31)

	# Entrance landing at X = 64..68
	# Zipper Teeth alternating ceiling stalactwites and floor hurdles:
	for x in range(65, 50, -6):
		# Floor Tooth 1 - 3 (comes up to Y=30, spike at Y=29)
		_build_floor_tooth(layer, x, 31, 3)
		# Ceiling Tooth 1 - 3 (comes down to Y=28, spike at Y=29)
		_build_ceiling_tooth(layer, x - 3, 25, 5)
	
	# Floor Tooth mountain 3
	_build_floor_tooth(layer, 47, 31, 1)
	_build_floor_tooth(layer, 46, 31, 2)
	_build_floor_tooth(layer, 45, 31, 3)
	_build_floor_tooth(layer, 44, 31, 3)
	_build_floor_tooth(layer, 43, 31, 3)
	_build_floor_tooth(layer, 42, 31, 2)
	_build_floor_tooth(layer, 41, 31, 1)

	# Zipper Teeth alternating that leads directly into Shaft 2 without obstacles!:
	for x in range(38, 11, -6):
		# Floor Tooth 1 - 8 (comes up to Y=30, spike at Y=29)
		_build_floor_tooth(layer, x, 31, 3) 
		# Ceiling Tooth 1 - 8 (comes down to Y=28, spike at Y=29)
		_build_ceiling_tooth(layer, x - 3, 25, 5)

	# =========================================================================
	# 6. SHAFT 2: Vertical Climb (Left Side: X = 2..10, Y = 15..30)
	# =========================================================================
	# Left wall lined with spikes pointing RIGHT into the shaft
	for y in range(16, 30):
		_set_spike_right(layer, 2, y)

	# Right wall of shaft: NO BLOCKING SPIKES AT Y = 16..24 (Doorway to Floor 3 is OPEN!)
	for x in range(10, 1, -1):
		_set_spike_up(layer, x, 33)
		
	# === Stepping stones climbing up to Floor 3 ===
	_build_platform_composite(layer, 4, 6, 28)
	_build_platform_composite(layer, 4, 6, 25)
	
	# Straight jump
	_build_platform_composite(layer, 2, 2, 22)
	_set_spike_right(layer, 3, 22)
	
	_set_spike_left(layer, 5, 22)
	_build_platform_composite(layer, 6, 8, 22)
	_set_spike_right(layer, 9, 22)
		
	_set_spike_left(layer, 5, 19)
	_build_platform_composite(layer, 6, 8, 19)
	_set_spike_right(layer, 9, 19)
	
	# =========================================================================
	# 7. FLOOR 3: The 5-Platform Gauntlet (Moving Left -> Right, Y = 15..23)
	# =========================================================================
	# Bed of spikes moved 1 block down to Y = 23 (more vertical breathing room)
	for x in range(11, 78):
		_set_spike_up(layer, x, 23)

	# ONLY 5 Challenging Platforms across the entire span:
	# Platform 1: Landing at X = 11..14 (Y = 20)
	_build_platform_composite(layer, 12, 15, 20)
	_set_spike_left(layer, 11, 20)
	# Platform 2: X = 23..25 (Y = 20) - 8-tile gap!
	_build_platform_composite(layer, 23, 26, 20)
	_set_spike_left(layer, 22, 20)

	# Platform 3: X = 34..36 (Y = 20) - 8-tile gap!
	_build_platform_composite(layer, 34, 37, 20)
	_set_spike_left(layer, 33, 20)


	# Platform 4: X = 45..47 (Y = 20) - 8-tile gap!
	_build_platform_composite(layer, 45, 48, 20)
	_set_spike_left(layer, 44, 20)


	# Platform 5: X = 56..58 (Y = 20) - 8-tile gap!
	_build_platform_composite(layer, 56, 59, 20)
	_set_spike_left(layer, 55, 20)

	# Exit Landing to Shaft 3: X = 66..68 (Y = 20)
	_build_platform_composite(layer, 67, 69, 20)
	_set_spike_left(layer, 66, 20)

	# Ceiling spikes with solid blocks above them (no loose spikes in the air)
	for sx in [18, 29, 40, 51, 62]:
		layer.set_cell(Vector2i(sx, 15), 4, Vector2i(0, 0), 0)
		_set_spike_down(layer, sx, 16)

	# =========================================================================
	# 8. SHAFT 3: Vertical Climb (Right Side: X = 69..77, Y = 4..19)
	# =========================================================================
	# Right wall lined with spikes pointing LEFT into the shaft
	for y in range(5, 19):
		_set_spike_left(layer, 77, y)

	# Left wall at X = 69: NO BLOCKING SPIKES (Doorway into Floor 4 at Y=8 is OPEN!)
	# Stepping stones climbing up to Floor 4
	_build_platform_composite(layer, 72, 74, 15)

	# =========================================================================
	# 9. FLOOR 4: The Summit (Moving Right -> Left, Y = 3..13)
	# =========================================================================
	# Spikes across the floor of Floor 4 (Row 13)
	for x in range(11, 69):
		_set_spike_up(layer, x, 13)

	# Ceiling spikes with solid blocks above them (Row 3 ceiling)
	for x in range(11, 78):
		_set_spike_down(layer, x, 3)

	# Hanging stalactite hazards: solid block at Y=4 with spike at Y=5 (No loose spikes!)
	for sx in [61, 53, 45, 37, 29, 21, 13]:
		layer.set_cell(Vector2i(sx, 3), 4, Vector2i(0, 0), 0) # Solid block
		_set_spike_down(layer, sx, 4) # Spike attached below
		_set_spike_up(layer, sx, 7) # Spike attached above
		layer.set_cell(Vector2i(sx, 8), 4, Vector2i(0, 0), 0) # Solid block
		_set_spike_right(layer, sx + 1, 8)
		_set_spike_left(layer, sx - 1, 8)
		

	# Floating stepping platforms at Y = 8
	_build_platform_composite(layer, 65, 65, 9)
	_build_platform_composite(layer, 57, 57, 12)
	_build_platform_composite(layer, 49, 49, 9)
	_build_platform_composite(layer, 41, 41, 12)
	_build_platform_composite(layer, 33, 33, 9)
	_build_platform_composite(layer, 25, 25, 12)
	_build_platform_composite(layer, 17, 17, 9) # Final launch platform!

	# =========================================================================
	# 10. GOAL SANCTUM (Upper-Left: X = 2..11, Y = 4..9)
	# =========================================================================
	# Pedestal floor
	for x in range(3, 11):
		_set_spike_up(layer, x, 8)
		layer.set_cell(Vector2i(x, 9), 8, Vector2i(0, 0), 0) # Outter top
	layer.set_cell(Vector2i(2, 9), 9, Vector2i(0, 0), 0)     # Corner TL

	# Left wall of sanctum
	for y in range(4, 9):
		layer.set_cell(Vector2i(2, y), 8, Vector2i(0, 0), 3)

	# Ceiling of sanctum
	for x in range(2, 11):
		layer.set_cell(Vector2i(x, 3), 8, Vector2i(0, 0), 1)

	# RIGHT WALL AT X = 10 / 11 IS COMPLETELY REMOVED!
	# The Star chamber is wide open for the player to leap in from X = 16!

# =============================================================================
# HELPER FUNCTIONS (Tileset variations, Spikes, and Composites)
# =============================================================================
func _set_spike_up(layer: TileMapLayer, x: int, y: int) -> void:
	layer.set_cell(Vector2i(x, y), 6, Vector2i(0, 0), 0) # Normal

func _set_spike_down(layer: TileMapLayer, x: int, y: int) -> void:
	# Flip H + Flip V = 180 degree rotation
	layer.set_cell(Vector2i(x, y), 6, Vector2i(0, 0), FLIP_H | FLIP_V) 

func _set_spike_left(layer: TileMapLayer, x: int, y: int) -> void:
	# Flip V + Transpose = Counter-Clockwise rotation
	layer.set_cell(Vector2i(x, y), 6, Vector2i(0, 0), FLIP_V | TRANSPOSE) 

func _set_spike_right(layer: TileMapLayer, x: int, y: int) -> void:
	# Flip H + Transpose = Clockwise rotation
	layer.set_cell(Vector2i(x, y), 6, Vector2i(0, 0), FLIP_H | TRANSPOSE)

func _build_divider(layer: TileMapLayer, start_x: int, end_x: int, y: int) -> void:
	for x in range(start_x, end_x + 1):
		layer.set_cell(Vector2i(x, y), 8, Vector2i(0, 0), 0)     # Top edge: clean outter plate
		layer.set_cell(Vector2i(x, y + 1), 4, Vector2i(0, 0), 0) # Bottom edge: broken station with wires

func _build_platform_composite(layer: TileMapLayer, start_x: int, end_x: int, y: int) -> void:
	var width = end_x - start_x + 1
	if width == 1:
		layer.set_cell(Vector2i(start_x, y), 4, Vector2i(0, 0), 0)
	elif width == 2:
		layer.set_cell(Vector2i(start_x, y), 9, Vector2i(0, 0), 0)     # Corner TL
		layer.set_cell(Vector2i(end_x, y), 9, Vector2i(0, 0), 1)       # Corner TR
	else:
		layer.set_cell(Vector2i(start_x, y), 9, Vector2i(0, 0), 0)     # Corner TL
		for x in range(start_x + 1, end_x):
			layer.set_cell(Vector2i(x, y), 8, Vector2i(0, 0), 0)       # Outter Top
		layer.set_cell(Vector2i(end_x, y), 9, Vector2i(0, 0), 1)       # Corner TR

func _build_ceiling_tooth(layer: TileMapLayer, x: int, top_y: int, height: int) -> void:
	for y in range(top_y, top_y + height):
		layer.set_cell(Vector2i(x, y), 10, Vector2i(0, 0), 0) # Filling column
	_set_spike_down(layer, x, top_y + height)                 # Downward spike at tip

func _build_floor_tooth(layer: TileMapLayer, x: int, bottom_y: int, height: int) -> void:
	for y in range(bottom_y - height + 1, bottom_y + 1):
		layer.set_cell(Vector2i(x, y), 10, Vector2i(0, 0), 0) # Filling column
	_set_spike_up(layer, x, bottom_y - height)                # Upward spike at tip
