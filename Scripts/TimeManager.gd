extends Node

@export var date_time: DateTime = preload("res://Scenes/game_time.tres")
@export var ticks_per_second: int = 288
var is_time_paused = false
#var _debug_accum: float = 0.0
#const DEBUG_INTERVAL: float = 0.5

func _physics_process(delta: float) -> void:
	if is_time_paused:
		return
	
	date_time.increase_by_sec(delta * ticks_per_second)
	
	#_debug_accum += delta
	#if _debug_accum >= DEBUG_INTERVAL:
		#_debug_accum -= DEBUG_INTERVAL
		#print("Time Manager: " + str(date_time.days) + ":" + str(date_time.hours) + ":" + str(date_time.minutes) + ":" + str(date_time.seconds))

func pause_time() -> void:
	is_time_paused = true

func resume_time() -> void:
	is_time_paused = false

func toggle_pause() -> void:
	is_time_paused = not is_time_paused

func reset_time() -> void:
	if date_time:
		date_time.reset()
