extends Control

@onready var name_label = $NameLabel
@onready var expiration_label = $ExpirationLabel
@onready var ID_label = $IDLabel
@onready var approved_stamp = $ApprovedStamp
@onready var denied_stamp = $DeniedStamp
@onready var sex_label = $SexLabel

func setup_document(person_name: String, exp_date: String, doc_ID: String):
	
	var sex_options: Array[String] = ["M", "F"]
	
	name_label.text = "[right]" + person_name + "[/right]"
	
	sex_label.text = sex_options[randi() % sex_options.size()]
	
	expiration_label.text = exp_date
	
	ID_label.text = doc_ID

func apply_stamp(type: String):
	var target_stamp : TextureRect = null
	
	if type == "approved":
		target_stamp = approved_stamp
	elif type == "denied":
		target_stamp = denied_stamp
		
	if target_stamp:
		var stamp_tween = create_tween()
		stamp_tween.tween_property(target_stamp, "modulate:a", 1.0, 0.15).set_trans(Tween.TRANS_QUAD)
