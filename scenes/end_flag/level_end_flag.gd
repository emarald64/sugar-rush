extends Area2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%Checker.region_rect.position.y+=delta*4
