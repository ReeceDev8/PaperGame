extends Control

@onready var slip_text = $slip_text
@onready var name_check = $Check1
@onready var date_check = $Check2
@onready var ID_check = $Check3
@onready var bloodtype_check = $Check4
@onready var name_X = $X1
@onready var date_X = $X2
@onready var ID_X = $X3
@onready var bloodtype_X = $X4

func setup_slip(evaluation):
	
	slip_text.text = "[center]" + evaluation + "[/center]"
	
	name_check.modulate.a = 1.0 if RulesEngine.name_valid else 0.0
	name_X.modulate.a     = 0.0 if RulesEngine.name_valid else 1.0
	
	date_check.modulate.a = 1.0 if RulesEngine.date_valid else 0.0
	date_X.modulate.a     = 0.0 if RulesEngine.date_valid else 1.0
	
	ID_check.modulate.a   = 1.0 if RulesEngine.ID_valid else 0.0
	ID_X.modulate.a       = 0.0 if RulesEngine.ID_valid else 1.0
	
	bloodtype_check.modulate.a   = 1.0 if RulesEngine.bloodtype_valid else 0.0
	bloodtype_X.modulate.a       = 0.0 if RulesEngine.bloodtype_valid else 1.0
