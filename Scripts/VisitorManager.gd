extends Node2D
class_name VisitorManager

@onready var character = $Character

signal entrance_complete
signal exit_complete

func walk_in() -> void:
	character.global_position = Vector2(-32, 77)
	character.play("Walk")
	
	var tween = create_tween()
	tween.tween_property(character, "global_position", Vector2(295, 77), 2.0)
	tween.finished.connect(func():
		character.play("Idle")
		entrance_complete.emit()
	)

func walk_out(decision: String) -> void:
	character.play("Walk")
	var tween = create_tween()
	
	if decision == "approved":
		tween.tween_property(character, "global_position", Vector2(670, 77), 2.0)
	elif decision == "denied":
		character.flip_h = true 
		tween.tween_property(character, "global_position", Vector2(-32, 77), 2.0)
		
	tween.finished.connect(func():
		if decision == "denied":
			character.flip_h = false
		exit_complete.emit()
	)
