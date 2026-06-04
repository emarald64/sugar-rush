extends Node

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		close()

func close()->void:
	get_tree().paused=false
	queue_free()

func to_title()->void:
	var tree=get_tree()
	tree.paused=false
	tree.call_deferred(&"change_scene_to_file","res://scenes/title/title_screen.tscn")

func restart()->void:
	var tree=get_tree()
	tree.paused=false
	tree.reload_current_scene()
