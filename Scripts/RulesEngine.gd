extends Node

var maindoc_name: String = ""
var persdoc_name: String = ""
var maindoc_ID: String = ""
var persdoc_ID: String = ""
var current_blood_type: String = ""
var curr_date: int = 1910
var date_valid: bool = false
var name_valid: bool = false
var ID_valid: bool = false
var bloodtype_valid: bool = false

func evaluate_documents(current_visitor_year: String, current_decision: String) -> bool:
	date_valid = _check_date(current_visitor_year) 
	name_valid = _check_identity()
	ID_valid = _check_ID()
	bloodtype_valid = _check_blood_type()
	
	var document_is_valid: bool = date_valid and name_valid and ID_valid and bloodtype_valid
	var player_was_correct: bool = (document_is_valid== (current_decision == "approved"))
	return player_was_correct

func _check_date(current_visitor_year: String) -> bool:
	print(current_visitor_year + " " + str(curr_date))
	return int(current_visitor_year) >= curr_date

func _check_identity() -> bool:
	print(maindoc_name + " " + persdoc_name)
	if ((maindoc_name == "") and (persdoc_name == "")):
		print("Error: no document values arrived at rulesengine")
	return maindoc_name == persdoc_name

func _check_ID() -> bool:
	print(maindoc_ID + " " + persdoc_ID)
	if ((maindoc_ID == "") and (persdoc_ID == "")):
		print("Error: no document values arrived at rulesengine")
	return maindoc_ID == persdoc_ID

func _check_blood_type() -> bool:
	var accepted_blood_types: Array[String] = ["A+", "A-", "B+"]
	return accepted_blood_types.has(current_blood_type)
