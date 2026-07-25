extends Control

@onready var SceneTransitionAnimation = $SceneTransitionAnimation/AnimationPlayer
@onready var main_buttons = $VBoxContainer
@onready var logo = $Logo
@onready var options_menu = $OptionsMenu

func _ready() -> void:
	options_menu.visible = false

func _on_play_pressed() -> void:
	SceneTransitionAnimation.play("fade_in")
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if options_menu.visible:
			_on_options_back_pressed()
			
			get_viewport().set_input_as_handled()

func _on_options_pressed() -> void:
	options_menu.visible = true
	logo.visible = false
	main_buttons.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_options_back_pressed() -> void:
	options_menu.visible = false
	main_buttons.visible = true
	logo.visible = true
