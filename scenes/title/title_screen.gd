extends ColorRect

func load_level(button)->void:
	get_tree().change_scene_to_file("res://scenes/levels/"+button.name+".tscn")
