extends Node

@export var date_time: DateTime = preload("res://Scenes/game_time.tres")

var is_time_paused = false

func pause_time() -> void:
	is_time_paused = true

func resume_time() -> void:
	is_time_paused = false

func toggle_pause() -> void:
	is_time_paused = not is_time_paused

func reset_time() -> void:
	if date_time:
		date_time.seconds = 0
		date_time.minutes = 0
		date_time.hours = 0
		date_time.days = 0
		date_time.delta_time = 0.0
