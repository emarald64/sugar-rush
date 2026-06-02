extends Node

var deaths:=0
var time_ms:=0
var level_index:int

func _ready()->void:
	$VBoxContainer/Counters.text="Deaths: "+str(deaths)+"      Time: "+formatTime(time_ms)

func level_select() -> void:
	get_tree().call_deferred(&"change_scene_to_file","res://scenes/title/title_screen.tscn")

func next_level() -> void:
	get_tree().call_deferred(&"change_scene_to_file","res://scenes/levels/"+str(+1)+".tscn")

static func formatTime(time:int)-> String:
	var msec=floori(time%1000/10.0)
	@warning_ignore("integer_division")
	var sec=time/1000%60
	@warning_ignore("integer_division")
	var minutes=time/60000
	return str(minutes)+':'+("0" if sec<10 else "")+str(sec)+'.'+("0" if msec<10 else "")+str(msec)
