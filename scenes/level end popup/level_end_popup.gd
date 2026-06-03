extends Node

var deaths:=0
var time_ms:=0
var level_index:int
var used_noclip:=false

func _ready()->void:
	if level_index>=TitleScreen.level_count:
		$"VBoxContainer/HBoxContainer/Next Level".hide()
	$VBoxContainer/Counters.text="Deaths: "+str(deaths)+"      Time: "+formatTime(time_ms)
	if used_noclip:
		$VBoxContainer/Counters.text+="   used noclip"

func level_select() -> void:
	get_tree().call_deferred(&"change_scene_to_file","res://scenes/title/title_screen.tscn")

func next_level() -> void:
	get_tree().call_deferred(&"change_scene_to_file","res://scenes/levels/"+str(level_index+1)+".tscn")

func restart()->void:
	get_tree().reload_current_scene()

static func formatTime(time:int)-> String:
	var msec=floori(time%1000/10.0)
	@warning_ignore("integer_division")
	var sec=time/1000%60
	@warning_ignore("integer_division")
	var minutes=time/60000
	return str(minutes)+':'+("0" if sec<10 else "")+str(sec)+'.'+("0" if msec<10 else "")+str(msec)
