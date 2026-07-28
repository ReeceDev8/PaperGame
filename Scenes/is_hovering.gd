extends Control

@onready var hand_sprite: Sprite2D = $"../CanvasLayer/Sprite2D"


func _on_mouse_entered() -> void:
	hand_sprite.set_hover_state(true)

func _on_mouse_exited() -> void:
	hand_sprite.set_hover_state(false)
