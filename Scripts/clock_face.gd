extends Node2D

enum {HOUR, MINUTE}
const HOUR_HAND_LENGTH = 60
const MINUTE_HAND_LENGTH = 100

@onready var minute_hand: Line2D = $MinuteHand
@onready var hour_hand: Line2D = $HourHand
@export var flash_interval: float = 0.5
var flash_timer: float = 0.0



func _physics_process(delta: float) -> void:
	if TimeManager.date_time:
		minute_hand.set_point_position(1, calculate_hand_tip_location(MINUTE))
		hour_hand.set_point_position(1, calculate_hand_tip_location(HOUR))
		
		var flashing_time = TimeManager.date_time.hours >= globals.closing_hour - 1
		
		if flashing_time:
			flash_timer += delta
			if flash_timer >= flash_interval:
				flash_timer = 0.0
				if hour_hand.modulate.a == 1.0 and minute_hand.modulate.a == 1.0:
					hour_hand.modulate.a = 0.0
					minute_hand.modulate.a = 0.0
				else:
					hour_hand.modulate.a = 1.0
					minute_hand.modulate.a = 1.0

# Calculate the coordinates of the tip of the clock hand
func calculate_hand_tip_location(hand) -> Vector2:
	var length
	var angle
	
	var current_hour = TimeManager.date_time.hours
	var current_minute = TimeManager.date_time.minutes
	
	match hand:
		MINUTE:
			length = MINUTE_HAND_LENGTH
			angle = deg_to_rad(current_minute * 6.0)
		HOUR:
			length = HOUR_HAND_LENGTH
			angle = deg_to_rad(current_hour * 30.0 + current_minute * 0.5)
	
	var x = length * sin(angle)
	var y = -length * cos(angle)
	
	return Vector2(x, y)
