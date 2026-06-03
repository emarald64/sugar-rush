extends Area2D

func disable()->void:
	hide()
	set_deferred(&"monitorable",false)
	
func reset()->void:
	show()
	set_deferred(&"monitorable",true)
