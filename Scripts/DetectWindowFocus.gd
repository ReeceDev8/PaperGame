extends Node

func _ready():
	get_viewport().focus_entered.connect(_on_window_focus_in)
	get_viewport().focus_exited.connect(_on_window_focus_out)

func _on_window_focus_in():
	get_tree().paused = false

func _on_window_focus_out():
	get_tree().paused = true
