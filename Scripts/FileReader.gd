extends Node

var name_list: Array[Dictionary] = []

func _ready():
	import_resources_data()

func import_resources_data():
	var file_path = "res://Assets/Data/Name_list.txt"
	if not FileAccess.file_exists(file_path):
		push_error("Cannot find file: " + file_path)
		return

	var file = FileAccess.open(file_path, FileAccess.READ)

	if not file.eof_reached():
		file.get_csv_line()
		
	while not file.eof_reached():
		var data_set = file.get_csv_line()
		
		if data_set.size() >= 2:
			var first_name = data_set[0].strip_edges()
			var last_name = data_set[1].strip_edges()
			
			if first_name.is_empty() and last_name.is_empty():
				continue
				
			name_list.append({
				"first": first_name,
				"last": last_name
			})
			
	file.close()

func get_random_name() -> String:
	
	if name_list.is_empty():
		return "John Doe"
	
	var random_entry = name_list[randi_range(0, name_list.size() -1)]
	return random_entry["first"] + " " + random_entry["last"]
