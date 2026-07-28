extends Control

@onready var close_button = $close_menu
@onready var options_menu = $OptionsMenu
@onready var main_buttons = $VBoxContainer
@onready var SceneTransitionAnimation = $SceneTransitionAnimation/AnimationPlayer
@onready var menu_button = $"../Interface/menu_button"
@onready var hand_sprite: Sprite2D = $"../CanvasLayer/Sprite2D"


func _ready() -> void:
	visible = false
	
	options_menu.visible = false

func _on_options_pressed() -> void:
	main_buttons.visible = false
	options_menu.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if options_menu.visible:
			_on_options_back_pressed()
		else:
			toggle_menu()
		get_viewport().set_input_as_handled()

func toggle_menu() -> void:
	self.visible = not self.visible
	
	get_tree().paused = visible
	
	menu_button.visible = not visible
	
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		hand_sprite.visible = false
		main_buttons.visible = true
		options_menu.visible = false
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		hand_sprite.visible = true

func _on_close_menu_pressed() -> void:
	toggle_menu()

func _on_options_back_pressed() -> void:
	options_menu.visible = false
	main_buttons.visible = true

func _on_main_menu_pressed() -> void:
	SceneTransitionAnimation.play("fade_in")
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_menu_button_pressed() -> void:
	toggle_menu()
