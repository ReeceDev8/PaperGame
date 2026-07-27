extends Control

@onready var stats_label: RichTextLabel = $VBoxContainer/StatsLabel
@onready var correct_label: RichTextLabel = $VBoxContainer/CorrectLabel
@onready var incorrect_label: RichTextLabel = $VBoxContainer/IncorrectLabel
@onready var salary_label: RichTextLabel = $VBoxContainer/SalaryLabel
@onready var debt_label: RichTextLabel = $VBoxContainer/DebtLabel
@onready var blocker_label: RichTextLabel = $VBoxContainer/BlockerLabel
@onready var money_label: RichTextLabel = $VBoxContainer/MoneyLabel
@onready var SceneTransitionAnimation = $SceneTransitionAnimation/AnimationPlayer

var stats = "Stats"
var number_correct = globals.number_correct
var number_incorrect = globals.number_incorrect
var money_earned = globals.money_earned
var debt_payment: int = 20
var curr_total_money = globals.total_money + money_earned - debt_payment
var labels_amount: int = 5
var label_array: Array[RichTextLabel] = []

func _ready() -> void:
	print("PostDayScreen ready, instance ", get_instance_id())
	label_array = [correct_label,
						incorrect_label,
						salary_label,
						debt_label,
						money_label]
						
	stats_label.text = "[center]" + stats + "[/center]"
	correct_label.text = "Correct Evaluations: " + str(number_correct)
	incorrect_label.text = "Incorrect Evaluations: " + str(number_incorrect)
	salary_label.text = "Salary: $" + str(money_earned)
	debt_label.text = "Debt Payment: -$" + str(debt_payment)
	money_label.text = "Total Money: $" + str(curr_total_money)
	
	for label in label_array:
		label.self_modulate.a = 0
	
	animate_text()

func animate_text() -> void:
	for label in label_array:
		await get_tree().create_timer(1.0).timeout
		label.self_modulate.a = 1

func _on_next_day_button_pressed() -> void:
	globals.number_correct = 0
	globals.number_incorrect = 0
	globals.money_earned = 0
	globals.total_money = curr_total_money
	SceneTransitionAnimation.play("fade_in")
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
