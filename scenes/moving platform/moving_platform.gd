extends TileMapLayer

@export var direction:Vector2=Vector2(0,80)
@onready var start_position:=position
@onready var timer=$Timer
@export var period:=2.0
@export var loop:=true
@export var delay:=0.0

func _ready() -> void:
	if delay>0.0:
		await get_tree().create_timer(delay).timeout
	delay=0.0
	timer.start(period)

func _physics_process(delta: float) -> void:
	if delay==0.0:
		if loop:
			position-=direction*sin(timer.time_left/timer.wait_time*2*PI)*delta/timer.wait_time*PI
		else:
			position+=direction*delta/timer.wait_time


func _on_timer_timeout() -> void:
	if not loop:
		collision_enabled=false
		set_deferred("position",start_position)
		set_deferred(&"collision_enabled",true)
