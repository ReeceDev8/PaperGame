class_name TimeSystem extends Node

@export var date_time: DateTime
@export var ticks_per_second: int = 6

func _process(delta: float) -> void:
	if TimeManager.is_time_paused:
		return
	
	date_time.increase_by_sec(delta * ticks_per_second)
