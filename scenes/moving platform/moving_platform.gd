extends Node2D

@export var direction:Vector2=Vector2(0,80)
@onready var start_position:=position
@onready var timer=$Timer
@export var period:=2.0

func _ready() -> void:
	timer.wait_time=period

func _physics_process(delta: float) -> void:
	position-=direction*sin(timer.time_left/timer.wait_time*2*PI)*delta/timer.wait_time*PI
