class_name MovingTextPlatform
extends AnimatableBody2D

enum PlatformType {
	SOLID,          # "STEPONME" - Normal floor
	LETHAL,         # "THISPLATFORMSKILLS" - Kills on touch from any side
	PASS_THROUGH    # "ITWASNTTHEWIND" - Visual only
}

@export var text: String = "STEPONME"
@export var platform_type: PlatformType = PlatformType.SOLID
@export var target_offset: Vector2 = Vector2(100, 0)
@export var move_duration: float = 2.0

@onready var label: Label = $Label
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hazard_area: Area2D = $HazardArea
@onready var hazard_shape: CollisionShape2D = $HazardArea/CollisionShape2D

var _timer: float = 0.0
var _color_toggle: bool = false
var _start_pos: Vector2
var _target_pos: Vector2

# Tween for movement
var _tween: Tween

func _ready() -> void:
	# Configure visual
	label.text = text
	
	# Adjust font size to 24 (1.5x player height of 16)
	label.add_theme_font_size_override("font_size", 24)
	
	# Compute actual text size to dynamically adjust collision boxes
	var font = label.get_theme_font("font")
	if not font:
		font = ThemeDB.fallback_font
	var font_size = label.get_theme_font_size("font_size")
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	
	# Position label centered
	label.position = -text_size / 2.0
	
	# Setup collision shape size
	var rect = RectangleShape2D.new()
	rect.size = text_size
	collision_shape.shape = rect
	
	var hazard_rect = RectangleShape2D.new()
	# Make lethal hitbox slightly larger or same size
	hazard_rect.size = text_size + Vector2(2, 2)
	hazard_shape.shape = hazard_rect
	
	# Setup physics based on type
	match platform_type:
		PlatformType.SOLID:
			collision_layer = 1
			collision_mask = 0
			hazard_area.monitoring = false
			hazard_area.monitorable = false
		PlatformType.LETHAL:
			collision_layer = 0
			collision_mask = 0
			hazard_area.monitoring = true
			hazard_area.monitorable = true
			# Connect hazard area directly to kill player
			hazard_area.body_entered.connect(_on_hazard_body_entered)
		PlatformType.PASS_THROUGH:
			collision_layer = 0
			collision_mask = 0
			hazard_area.monitoring = false
			hazard_area.monitorable = false
			
	# Setup Movement Tween
	_start_pos = global_position
	_target_pos = _start_pos + target_offset
	
	# Create looping ping-pong tween
	_tween = create_tween().set_loops().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_property(self, "global_position", _target_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "global_position", _start_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(delta: float) -> void:
	# Frantic color flashing
	_timer += delta
	if _timer >= 0.05:
		_timer = 0.0
		_color_toggle = !_color_toggle
		
		# Pink: FF69B4, Light Blue: 87CEFA
		if _color_toggle:
			label.modulate = Color("ff69b4") # Pink
		else:
			label.modulate = Color("87cefa") # Light Blue

func _on_hazard_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
