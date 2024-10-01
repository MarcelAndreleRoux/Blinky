extends Node2D

@onready var track_1 = $Track1

# Play music or sound effect by name
func play_audio(name: String, volume: float = 1.0):
	var audio_player = get_node(name)
	if audio_player and audio_player is AudioStreamPlayer2D:
		audio_player.volume_db = volume
		audio_player.play()
	else:
		print("Audio node not found or incorrect type:", name)

# Stop audio by name
func stop_audio(name: String):
	var audio_player = get_node(name)
	if audio_player and audio_player is AudioStreamPlayer2D:
		audio_player.stop()
	else:
		print("Audio node not found or incorrect type:", name)
