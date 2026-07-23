extends Node
class_name SoundManager

@export var trash_sound: AudioStream
@export var stamp_sound: AudioStream
@export var bell_sound: AudioStream
@export var scanner_sound: AudioStream
@export var maindoc_print_sound: AudioStream
@export var report_print_sound: AudioStream

func play_sfx(stream: AudioStream) -> void:
	var temp_player = AudioStreamPlayer.new()
	add_child(temp_player)
	temp_player.stream = stream
	temp_player.finished.connect(temp_player.queue_free)
	temp_player.play()
