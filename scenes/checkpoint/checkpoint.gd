class_name Checkpoint extends Area2D

var active:=false;

func activate(player: Player) -> void:
	if not active:
		var old_cp=player.current_cp
		if old_cp is Checkpoint:
			old_cp.deactivate()
		elif old_cp.name==&"StartPos":
			old_cp.queue_free()
			
		$AnimatedSprite2D.play(&"Up")
		player.current_cp=self
		active=true

func deactivate()->void:
	active=false
	$AnimatedSprite2D.play(&"default")
