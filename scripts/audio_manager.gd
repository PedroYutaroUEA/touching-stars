extends Node

@onready var jump_sfx: AudioStreamPlayer = $JumpSFX
@onready var death_sfx: AudioStreamPlayer = $DeathSFX
@onready var win_sfx: AudioStreamPlayer = $WinSFX

var _ui_click_player: AudioStreamPlayer
var _test_sfx_player: AudioStreamPlayer

func _ready() -> void:
	# Ensure bus routing
	if jump_sfx:
		jump_sfx.bus = &"SFX"
	if death_sfx:
		death_sfx.bus = &"SFX"
	if win_sfx:
		win_sfx.bus = &"SFX"
		
	# Setup synthetic UI audio players for instant feedback
	_ui_click_player = AudioStreamPlayer.new()
	_ui_click_player.bus = &"SFX"
	_ui_click_player.stream = _create_synthetic_beep(880.0, 0.05, 0.4)
	add_child(_ui_click_player)
	
	_test_sfx_player = AudioStreamPlayer.new()
	_test_sfx_player.bus = &"SFX"
	_test_sfx_player.stream = _create_synthetic_beep(523.25, 0.12, 0.5)
	add_child(_test_sfx_player)

func play_jump() -> void:
	if jump_sfx and jump_sfx.stream:
		jump_sfx.play()
	else:
		play_test_beep(600.0, 0.08)

func play_death() -> void:
	if death_sfx and death_sfx.stream:
		death_sfx.play()
	else:
		play_test_beep(220.0, 0.2)

func play_win() -> void:
	if win_sfx and win_sfx.stream:
		win_sfx.play()
	else:
		play_test_beep(1046.5, 0.3)

func play_ui_click() -> void:
	if _ui_click_player:
		_ui_click_player.play()

func play_test_beep(freq: float = 659.25, duration: float = 0.1) -> void:
	if _test_sfx_player:
		_test_sfx_player.stream = _create_synthetic_beep(freq, duration, 0.5)
		_test_sfx_player.play()

# Generate a clean lightweight procedural 8-bit PCM wave sample
func _create_synthetic_beep(freq: float, duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var num_samples: int = int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(num_samples)
	
	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		# Sine wave with exponential decay envelope
		var envelope: float = 1.0 - (float(i) / float(num_samples))
		var wave: float = sin(t * freq * TAU)
		var sample_val: int = int(clampi(int(wave * envelope * volume * 127.0) + 128, 0, 255))
		data[i] = sample_val
		
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = data
	return wav
