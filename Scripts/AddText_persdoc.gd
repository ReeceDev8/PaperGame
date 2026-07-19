extends Control

@onready var name_label = $NameLabel
@onready var bloodtype_label = $BloodTypeLabel
@onready var ID_label = $IDLabel

func setup_persdoc(person_name: String, doc_ID: String):
	
	var bloodtype_options: Array[String] = ["A", "B", "O"]
	var posorneg_options: Array[String] = ["+", "-"]
	var current_name: String = _modify_name_chance(person_name)
	var persdoc_ID: String = _modify_person_ID(doc_ID, person_name, current_name)
	var bloodtype: String = bloodtype_options[randi_range(0,  bloodtype_options.size() - 1)] + posorneg_options[randi_range(0,  posorneg_options.size() - 1)] 
	
	RulesEngine.persdoc_name = current_name
	RulesEngine.persdoc_ID = persdoc_ID
	RulesEngine.current_blood_type = bloodtype
	
	name_label.text = "[right]" + current_name + "[/right]"
	bloodtype_label.text = bloodtype
	ID_label.text = persdoc_ID

func _modify_name_chance(person_name: String) -> String:
	var person_name_Array: PackedStringArray = person_name.split("")
	
	if randf() > 0.3:
		return person_name
	
	if person_name_Array.has("i"):
		for i in range(person_name_Array.size()):
			if person_name_Array[i] == "i":
				person_name_Array[i] = "e"
				return "".join(person_name_Array)
	else:
		var last_name_index: int = person_name_Array.find(" ")
		if last_name_index != -1 and last_name_index + 3 < person_name_Array.size():
			var j = last_name_index + 2
			var temp: String = person_name_Array[j]
			person_name_Array[j] = person_name_Array[j + 1]
			person_name_Array[j + 1] = temp
			return "".join(person_name_Array)
	return person_name

func _modify_person_ID(doc_ID: String, person_name: String, current_name: String) -> String:
	var doc_ID_Array: PackedStringArray = doc_ID.split("")
	var letters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	if randf() > 0.3:
		return doc_ID
	
	if ((current_name == person_name) or randf() > 0.5):
		doc_ID_Array[randi_range(0, doc_ID_Array.size() - 1)] = letters[randi_range(0,  letters.length())]
		doc_ID = "".join(doc_ID_Array)
		return doc_ID
	else:
		return doc_ID
