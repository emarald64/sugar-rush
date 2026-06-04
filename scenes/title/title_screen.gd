class_name TitleScreen extends ColorRect

static var level_times:PackedInt32Array=PackedInt32Array()
static var death_counts:PackedInt32Array=PackedInt32Array()
const level_count=2
const save_path="user://save"

static func _static_init() -> void:
	level_times.resize(level_count)
	death_counts.resize(level_count)
	
	# load save
	if FileAccess.file_exists(save_path) and FileAccess.get_size(save_path)==level_count*8:
		print("save exists")
		var save_file=FileAccess.open(save_path,FileAccess.READ)
		for i in range(level_count):
			level_times[i]=save_file.get_32()
		for i in range(level_count):
			death_counts[i]=save_file.get_32()

func _ready() -> void:
	var total_time:=0
	var total_deaths:=0
	for level in range(level_count):
		total_time+=level_times[level]
		total_deaths+=death_counts[level]
		if level_times[level]>0:
			var level_button_contents:Control=%levels.get_child(level).get_child(0)
			level_button_contents.get_node("check").modulate=Color.WHITE
			var on_complete=level_button_contents.get_node("on_complete")
			on_complete.show()
			on_complete.get_node("Death Count").text=": "+str(death_counts[level])
			on_complete.get_node("Time").text=": "+formatTime(level_times[level])
			
	%DeathCount.text="Deaths: "+str(total_deaths)
	%TotalTime.text="Time: "+formatTime(total_time)

func load_level(button)->void:
	get_tree().change_scene_to_file("res://scenes/levels/"+button.name+".tscn")

static func save()->void:
	var save_file=FileAccess.open(save_path,FileAccess.WRITE)
	for time in level_times:
		save_file.store_32(time)
	for deaths in death_counts:
		save_file.store_32(deaths)

static func formatTime(time:int)-> String:
	var msec=floori(time%1000/10.0)
	@warning_ignore("integer_division")
	var sec=time/1000%60
	@warning_ignore("integer_division")
	var minutes=time/60000
	return str(minutes)+':'+("0" if sec<10 else "")+str(sec)+'.'+("0" if msec<10 else "")+str(msec)
