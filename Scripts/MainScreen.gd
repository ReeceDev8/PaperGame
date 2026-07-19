extends Control

var document_blueprint = preload("res://Papers/Document.tscn")
var paperslip_blueprint = preload("res://Papers/paper_slip.tscn")
var persdoc_blueprint = preload("res://Papers/personal_doc.tscn")

@onready var desk_area = $Environment/DeskArea 
@onready var print_player = $PrintPlayer
@onready var print1_player = $Print1Player
@onready var bell_player = $Interface/BellButton/BellPlayer
@onready var stamp_player = $StampSound
@onready var scanner_sound = $ScannerSound
@onready var scanner_anim = $VisitorSystem/ScannerAnim
@onready var bell = $Interface/BellButton/Bell
@onready var dialogue_manager: DialogueManager = $DialogueSystem
@onready var visitor_manager: VisitorManager = $VisitorSystem

enum GameState { WAITING_FOR_VISITOR, CALLED_FOR_VISITOR, VISITOR_ARRIVED, DOCUMENT_ACTIVE, VISITOR_LEAVING }
var current_state = GameState.WAITING_FOR_VISITOR
var current_document_instance = null
var current_slip_instance = null
var current_persdoc_instance = null
var current_decision : String = "none"
var current_visitor_year : String = ""
var handed_over_docs = []

func _ready():
	current_state = GameState.WAITING_FOR_VISITOR
	
	if not visitor_manager.entrance_complete.is_connected(_on_visitor_arrived):
		visitor_manager.entrance_complete.connect(_on_visitor_arrived)
	if not visitor_manager.exit_complete.is_connected(_on_turn_reset):
		visitor_manager.exit_complete.connect(_on_turn_reset)

func _on_beautiful_bell_pressed():
	bell_player.play()
	bell.frame = 1
	await get_tree().create_timer(0.15).timeout
	bell.frame = 0
	if current_state != GameState.WAITING_FOR_VISITOR: return
	current_state = GameState.CALLED_FOR_VISITOR
	
	await get_tree().create_timer(0.3).timeout
	visitor_manager.walk_in()

func _on_visitor_arrived():
	current_state = GameState.VISITOR_ARRIVED

func _on_button_pressed():
	if current_state != GameState.VISITOR_ARRIVED: return
	current_state = GameState.DOCUMENT_ACTIVE
	
	scanner_sound.play()
	await get_tree().create_timer(1.5).timeout
	scanner_anim.modulate.a = 1.0
	scanner_anim.play("ScannerState1")
	await get_tree().create_timer(3.8).timeout
	scanner_anim.modulate.a = 0.0
	
	var random_year: String = ""
	var random_name = FileReader.get_random_name()
	if randf() > 0.2:
		random_year = str(randi_range(1910, 1920))
	else:
		random_year = str(randi_range(1892, 1909))
	var random_ID = _generate_random_ID(6)
	current_visitor_year = random_year
	spawn_new_document(random_name, random_year, random_ID)
	

func spawn_new_document(name_data: String, date_data: String, doc_ID: String):
	current_document_instance = document_blueprint.instantiate()
	desk_area.add_child(current_document_instance)
	print_player.play()
	
	dialogue_manager.show_greeting()
	
	current_persdoc_instance = persdoc_blueprint.instantiate()
	desk_area.add_child(current_persdoc_instance)
	current_persdoc_instance.modulate.a = 0
	
	RulesEngine.maindoc_ID = doc_ID
	RulesEngine.maindoc_name = name_data
	
	if current_document_instance.has_node("Text"):
		current_document_instance.get_node("Text").setup_document(name_data, date_data, doc_ID)
	
	if current_persdoc_instance.has_node("Text"):
		current_persdoc_instance.get_node("Text").setup_persdoc(name_data, doc_ID)
	
	current_document_instance.global_position = Vector2(250, 50)
	current_document_instance.z_index = 0
	current_persdoc_instance.global_position = Vector2(150, 150)
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(current_document_instance, "global_position", Vector2(250, 162), 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(current_persdoc_instance, "global_position", Vector2(150, 162), .5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(1)
	tween.tween_property(current_persdoc_instance, "modulate:a", 1.0, .2).set_delay(1.0)
	
	tween.finished.connect(func():
		if current_document_instance:
			current_document_instance.z_index = 4
	)

func _on_approve_button_pressed():
	if current_state == GameState.DOCUMENT_ACTIVE:
		stamp_current_document("approved")

func _on_deny_button_pressed():
	if current_state == GameState.DOCUMENT_ACTIVE:
		stamp_current_document("denied")
	
func stamp_current_document(decision: String):
	if current_state != GameState.DOCUMENT_ACTIVE or !current_document_instance: return
	current_decision = decision
	
	if current_document_instance.has_node("Text"):
		current_document_instance.get_node("Text").apply_stamp(decision)
	stamp_player.play()
	
func process_hand_off(doc_type: String, doc_node: Node):
	if current_decision == "none": return
	
	animate_document_handoff(doc_node)
	# 1. Add this document to the list if not already there
	if not handed_over_docs.has(doc_type):
		handed_over_docs.append(doc_type)
	
	# 2. Check if we have both
	if handed_over_docs.has("Main") and handed_over_docs.has("Pers"):
		start_dismissal()
	else:
		print("Waiting for the other document...")
	
func animate_document_handoff(doc_node: Node):
	var start_y = doc_node.global_position.y
	var drop_target_y = start_y + 120
	
	var anim = create_tween().set_parallel(true)
	anim.tween_property(doc_node, "global_position:y", drop_target_y, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	anim.tween_property(doc_node, "modulate:a", 0.0, 0.2)
	# Clean up only this specific node when it's done
	anim.finished.connect(doc_node.queue_free)

func start_dismissal():
	current_state = GameState.VISITOR_LEAVING
	
	dialogue_manager.show_dismissal(current_decision)
	visitor_manager.walk_out(current_decision)
	await get_tree().create_timer(1.5).timeout
	administer_slip()
	handed_over_docs.clear()
	
func administer_slip():
	var evaluation : String = ""
	current_slip_instance = paperslip_blueprint.instantiate()
	desk_area.add_child(current_slip_instance)
	current_slip_instance.global_position = Vector2(260, 330)
	var valid = RulesEngine.evaluate_documents(current_visitor_year, current_decision)
	
	if valid:
		evaluation = "Correct"
		current_slip_instance.get_node("SlipText").setup_slip(evaluation)
	else: 
		evaluation = "Incorrect"
		current_slip_instance.get_node("SlipText").setup_slip(evaluation)
		
	var tween = create_tween()
	print1_player.play()
	tween.tween_property(current_slip_instance, "global_position", Vector2(260, 270), 3.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_turn_reset():
	if is_instance_valid(current_document_instance):
		current_document_instance.queue_free()
	current_decision = "none"
	RulesEngine.maindoc_ID = ""
	RulesEngine.persdoc_ID = ""
	dialogue_manager.clear()
	_ready()

func _generate_random_ID(length: int):
	var random_ID: String = ""
	var numbers: String = "0123456789"
	var letters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	for i in range(length):
		if (i % 2 == 0):
			var random_letter = randi_range(0,  letters.length() - 1)
			random_ID += letters[random_letter]
		else: 
			var random_number = randi_range(0,  numbers.length() - 1)
			random_ID += numbers[random_number]
	return random_ID
