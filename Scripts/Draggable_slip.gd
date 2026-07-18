extends TextureRect

var dragging = false
var mouse_offset = Vector2.ZERO
var slip_node = self
var trash_sound = preload("res://Assets/Audio/Slip_Trash.ogg")
var pickup_sounds = [preload("res://Assets/Audio/Paper_slide1.wav"),
					preload("res://Assets/Audio/Paper_slide2.wav")
					]

func _ready():
	pivot_offset = size / 2.0

func _process(_delta):
	var local_mouse_pos = get_local_mouse_position()
	var paper_rect = Rect2(Vector2.ZERO, size)
	var is_hovering = paper_rect.has_point(local_mouse_pos)
	
	if dragging:
		scale = scale.lerp(Vector2(1.1, 1.1), 0.1)
	else:
		var target_scale = Vector2(1.1, 1.1) if is_hovering else Vector2(1.0, 1.0)
		scale = scale.lerp(target_scale, 0.1)

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			mouse_offset = event.position
			get_parent().move_child(self, -1)
			play_random_pickup()
		else:
			dragging = false
			check_for_disposal()

	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - mouse_offset

func check_for_disposal():
	var temp_player = AudioStreamPlayer.new()
	add_child(temp_player)
	var mouse_y = get_global_mouse_position().y
	var start_y = slip_node.global_position.y
	var drop_target_y = start_y + 120
	if mouse_y < 160:
		temp_player.stream = trash_sound
		temp_player.play()
		var tween = create_tween().set_parallel(true)
		tween.tween_property(slip_node, "global_position:y", drop_target_y, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(slip_node, "modulate:a", 0.0, 0.2)
		await tween.finished
		queue_free()
		temp_player.finished.connect(temp_player.queue_free)

func play_random_pickup():
	var temp_player = AudioStreamPlayer.new()
	add_child(temp_player)
	var random_sound = pickup_sounds[randi() % pickup_sounds.size()]
	temp_player.stream = random_sound
	temp_player.play()
	temp_player.finished.connect(temp_player.queue_free)
