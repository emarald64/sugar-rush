extends ColorRect

func load_level(index:int)->void:
	get_tree().change_scene_to_file("res://scenes/levels/"+str(index)+".tscn")
