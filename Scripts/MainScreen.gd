extends Control

var document_blueprint = preload("res://Papers/Document.tscn")
var paperslip_blueprint = preload("res://Papers/paper_slip.tscn")
var persdoc_blueprint = preload("res://Papers/personal_doc.tscn")
var trash_sound = preload("res://Assets/Audio/Slip_Trash.ogg")

@onready var desk_area = $Environment/DeskArea 
@onready var print_player = $PrintPlayer
@onready var print1_player = $Print1Player
@onready var bell_player = $Interface/BellButton/BellPlayer
@onready var stamp_player = $StampSound
@onready var scanner_sound = $ScannerSound
@onready var scanner = $VisitorSystem/ScannerAnim
@onready var bell = $Interface/BellButton/Bell
@onready var dialogue_manager: DialogueManager = $DialogueSystem
@onready var visitor_manager: VisitorManager = $VisitorSystem
@onready var animation_manager: AnimationManager = $AnimationManager

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
	animation_manager.animate_bell(bell)
	
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
	await animation_manager.animate_scanner(scanner)
	
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
	
	animation_manager.animate_maindoc_spawn(current_document_instance)
	await get_tree().create_timer(1.0).timeout
	animation_manager.animate_persdoc_spawn(current_persdoc_instance)
	

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
	
	var temp_player = AudioStreamPlayer.new()
	add_child(temp_player)
	temp_player.stream = trash_sound
	temp_player.play()
	animation_manager.animate_document_handoff(doc_node)
	temp_player.finished.connect(temp_player.queue_free)
	
	# 1. Add this document to the list if not already there
	if not handed_over_docs.has(doc_type):
		handed_over_docs.append(doc_type)
	
	# 2. Check if we have both
	if handed_over_docs.has("Main") and handed_over_docs.has("Pers"):
		start_dismissal()
	else:
		print("Waiting for the other document...")
	


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
		
	
	animation_manager.animate_report_spawn(current_slip_instance)
	print1_player.play()
	

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
			var random_letter = randi() % letters.length()
			random_ID += letters[random_letter]
		else: 
			var random_number = randi() % numbers.length()
			random_ID += numbers[random_number]
	return random_ID
