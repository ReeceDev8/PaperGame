extends Sprite2D

@export var mouse_offset: Vector2 = Vector2(16, 24)
@export var hand_clenched_texture: Texture2D
@export var hand_open_texture: Texture2D


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position() + mouse_offset
	

func set_hover_state(is_hovering: bool) -> void:
	if is_hovering:
		if hand_open_texture: texture = hand_open_texture
	else:
		if hand_clenched_texture: texture = hand_clenched_texture
