extends TextureRect

@export var doc_type: String = "Main"

var dragging = false
var mouse_offset = Vector2.ZERO

var pickup_sounds = [preload("res://Assets/Audio/Paper_slide1.wav"),
					preload("res://Assets/Audio/Paper_slide2.wav")
					]

var main_screen

func _ready():
	pivot_offset = size / 2.0
	main_screen = get_tree().current_scene

func _process(_delta):
	var global_mouse_pos = get_global_mouse_position()
	var mouse_y = global_mouse_pos.y
	var local_mouse_pos = get_local_mouse_position()

	# Create the bounding box of the paper's boundaries 
	var paper_rect = Rect2(Vector2.ZERO, size)
	
	# Determine if the mouse is visually hovering over the paper
	var is_hovering_paper = paper_rect.has_point(local_mouse_pos)
	
	# Determine if the paper is currently off-desk
	var is_off_desk = mouse_y < 160
	
	
	if dragging:
		# If dragging, only change scale if we cross the off-desk line
		if is_off_desk:
			scale = scale.lerp(Vector2(0.5,0.5), 0.05)
		else:
			scale = scale.lerp(Vector2(1.1, 1.1), 0.1) # Keep it enlarged on desk
			
	else:
		# If NOT dragging, scale based on hovering and desk position
		if is_off_desk:
			# Not hovering or off-desk? Reset to normal scale
			scale = scale.lerp(Vector2(1.0, 1.0), 0.1)
		elif is_hovering_paper:
			# Hovering AND on desk? Enlarge 
			scale = scale.lerp(Vector2(1.1, 1.1), 0.1)
		else:
			# On desk, not hovering? Normal scale.
			scale = scale.lerp(Vector2(1.0, 1.0), 0.1)


func _gui_input(event):
	# Detect left click press
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			mouse_offset = event.position 
			get_parent().move_child(self, -1)
			
			play_random_pickup()
		else:
			dragging = false
			check_for_hand_off()

	# Detect mouse movement while dragging
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - mouse_offset


func check_for_hand_off():
	var mouse_y = get_global_mouse_position().y
	
	if mouse_y < 160:
		if main_screen and main_screen.has_method("process_hand_off"):
			set_process_input(false)
			main_screen.process_hand_off(doc_type, self)
		else:
			create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)


func play_random_pickup():
	var temp_player = AudioStreamPlayer.new()
	add_child(temp_player)
	var random_sound = pickup_sounds[randi() % pickup_sounds.size()]
	temp_player.stream = random_sound
	temp_player.play()
	temp_player.finished.connect(temp_player.queue_free)
