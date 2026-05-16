extends Node

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		close()

func close()->void:
	get_tree().paused=false
	queue_free()

func to_title()->void:
	get_tree().paused=false
	get_tree().call_deferred(&"change_scene_to_file","res://scenes/title/title_screen.tscn")
