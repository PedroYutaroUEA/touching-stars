extends Node

@onready var jump_sfx: AudioStreamPlayer = $JumpSFX
@onready var death_sfx: AudioStreamPlayer = $DeathSFX
@onready var win_sfx: AudioStreamPlayer = $WinSFX

func play_jump() -> void:
	if jump_sfx.stream:
		jump_sfx.play()

func play_death() -> void:
	if death_sfx.stream:
		death_sfx.play()

func play_win() -> void:
	if win_sfx.stream:
		win_sfx.play()
