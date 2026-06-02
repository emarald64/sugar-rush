extends ColorRect

static var level_times:PackedInt32Array=PackedInt32Array()
static var death_counts:PackedInt32Array=PackedInt32Array()
const level_count=2

static func _static_init() -> void:
	level_times.resize(level_count)
	death_counts.resize(level_count)

func load_level(button)->void:
	get_tree().change_scene_to_file("res://scenes/levels/"+button.name+".tscn")
