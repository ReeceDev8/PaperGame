extends TextureRect

@export var doc_type: String = "Main"
@onready var hand_sprite: Sprite2D = get_tree().get_first_node_in_group("hand_sprite")
@onready var main_screen: Control = $"."
@export var document_primary_texture: Texture2D
@export var document_grabbed_texture: Texture2D

var dragging: bool = false
var base_size: Vector2

var pickup_sounds = [
	preload("res://Assets/Audio/Paper_slide1.wav"),
	preload("res://Assets/Audio/Paper_slide2.wav")
]

func _ready():
	base_size = size 
	pivot_offset = base_size / 2.0
	main_screen = get_tree().current_scene

func _process(_delta):
	var global_mouse_pos = get_global_mouse_position()
	var mouse_y = global_mouse_pos.y
	var local_mouse_pos = get_local_mouse_position()

	var paper_rect = Rect2(Vector2.ZERO, size)
	var is_hovering_paper = paper_rect.has_point(local_mouse_pos)
	var is_off_desk = mouse_y < 160
	
	if dragging:
		global_position = global_mouse_pos - (pivot_offset * scale)
		
		# Handle scaling when off-desk
		if is_off_desk and main_screen.current_decision != "none":
			scale = scale.lerp(Vector2(0.5, 0.5), 0.05)
		else:
			scale = scale.lerp(Vector2(1.75, 1.75), 0.08)
	else:
		# If NOT dragging, scale based on hovering and desk position
		if is_off_desk:
			scale = scale.lerp(Vector2(1.0, 1.0), 0.1)
		elif is_hovering_paper:
			scale = Vector2(1.0, 1.0)
		else:
			scale = Vector2(1.0, 1.0)

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			hand_sprite.visible = false
			
			if document_grabbed_texture: 
				texture = document_grabbed_texture
				
			dragging = true
			get_parent().move_child(self, -1)
			
			pivot_offset = size / 2.0
			global_position = get_global_mouse_position() - (pivot_offset * scale)
			
			play_random_pickup()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			hand_sprite.visible = true
			
			if document_primary_texture: 
				texture = document_primary_texture
				
			size = base_size
			pivot_offset = base_size / 2.0
			
			dragging = false
			check_for_hand_off()

func check_for_hand_off():
	var mouse_y = get_global_mouse_position().y
	
	if mouse_y < 160:
		if main_screen and main_screen.has_method("process_hand_off"):
			set_process_input(false)
			main_screen.process_hand_off(doc_type, self)
		else:
			create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

func _on_mouse_entered() -> void:
	hand_sprite.set_hover_state(true)

func _on_mouse_exited() -> void:
	hand_sprite.set_hover_state(false)

func play_random_pickup():
	var temp_player = AudioStreamPlayer.new()
	add_child(temp_player)
	var random_sound = pickup_sounds[randi_range(0, pickup_sounds.size() - 1)]
	temp_player.stream = random_sound
	temp_player.play()
	temp_player.finished.connect(temp_player.queue_free)
