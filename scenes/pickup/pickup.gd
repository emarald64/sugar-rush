extends Area2D

func disable()->void:
	hide()
	monitorable=false
	
func enable()->void:
	show()
	monitorable=true
