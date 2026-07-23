extends Node
class_name AnimationManager 

func animate_bell(sprite: AnimatedSprite2D) -> void:
	sprite.frame = 1
	await get_tree().create_timer(0.15).timeout
	sprite.frame = 0

func animate_scanner(sprite: AnimatedSprite2D) -> void:
	await get_tree().create_timer(1.5).timeout
	sprite.modulate.a = 1.0
	sprite.play("ScannerState1")
	await get_tree().create_timer(3.8).timeout
	sprite.modulate.a = 0.0

func animate_maindoc_spawn(doc_node: TextureRect) -> void:
	var tween = create_tween()
	tween.tween_property(doc_node, "global_position", Vector2(250, 162), 2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(func():
		if doc_node:
			doc_node.z_index = 4
	)
	await tween.finished

func animate_persdoc_spawn(persdoc_node: Node) -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(persdoc_node, "global_position", Vector2(150, 162), .5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(persdoc_node, "modulate:a", 1.0, .2)
	await tween.finished

func animate_report_spawn(report_node: Node) -> void:
	var tween = create_tween()
	tween.tween_property(report_node, "global_position", Vector2(260, 270), 3.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

func animate_document_handoff(doc_node: Node):
	var start_y = doc_node.global_position.y
	var drop_target_y = start_y + 120
	
	var anim = create_tween().set_parallel(true)
	anim.tween_property(doc_node, "global_position:y", drop_target_y, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	anim.tween_property(doc_node, "modulate:a", 0.0, 0.2)
	anim.finished.connect(doc_node.queue_free)
