extends Control

signal back_pressed

@onready var back_button: Button = $VBoxContainer/BackButton

func _ready() -> void:
	pass

func _on_back_pressed() -> void:
	back_pressed.emit()
