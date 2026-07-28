class_name DateTime extends Resource

@export_range(0, 59) var seconds: int = 0
@export_range(0, 59) var minutes: int = 0
@export_range(0, 59) var hours: int = 0
@export var days: int = 0

# Debug stuff
#var _debug_accum: float = 0.0
#const DEBUG_INTERVAL: float = 0.5

var delta_time: float = 0

func increase_by_sec(delta_seconds: float) -> void:
	#_debug_accum += delta_seconds
	#if _debug_accum >= DEBUG_INTERVAL:
		#_debug_accum -= DEBUG_INTERVAL
		#print("date_time : " + str(days) + ":" + str(hours) + ":" + str(minutes) + ":" + str(seconds))
	delta_time += delta_seconds
	
	if delta_time < 1:
		return
	
	var delta_int_seconds: int = int(delta_time)
	delta_time -= delta_int_seconds
	
	seconds += delta_int_seconds
	minutes += seconds / 60
	hours += minutes / 60
	days += hours / 24
	
	seconds = seconds % 60
	minutes = minutes % 60
	hours = hours % 24
	
	# print(str(days) + ":" + str(hours) + ":" + str(minutes) + ":" + str(seconds))

func reset() -> void:
	seconds = 0
	minutes = 0
	hours = 0
	delta_time = 0.0

func reset_all() -> void:
	seconds = 0
	minutes = 0
	hours = 0
	days = 0
	delta_time = 0.0
	
