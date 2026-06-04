extends AnimatableBody2D

@export var direction:=Vector2(90,0)
@export var time:=1.0

@export_group("Returning")
@export var will_return:=true
@export var return_time:=2.0

@onready var startpos:=position
var returning:=false
var active:=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func activate()->void:
	if not active:
		$Sprite2D.texture=preload("res://assets/kenney_pixel-platformer/Tiles/tile_0010.png")
		active=true
		($"Start Return Timer" if will_return else $"Reset Timer").start(time)

func start_return()->void:
	#print("returning")
	returning=true
	$"Reset Timer".start(return_time)

func _physics_process(delta: float) -> void:
	if active:
		if returning:
			position-=direction*delta/return_time
		else:
			position+=direction*delta/time

func reset()->void:
	#print("platform reset")
	returning=false
	active=false
	set_deferred("position",startpos)
	$Sprite2D.texture=preload("res://assets/kenney_pixel-platformer/Tiles/tile_0030.png")
	if not will_return:
		collision_layer=0
		await get_tree().physics_frame
		collision_layer=1
	if $PlayerDetector.has_overlapping_bodies():
		#print("reactivate")
		activate()
	
func _process(_delta: float) -> void:
	var time_left=$"Reset Timer".time_left
	if active and time_left<=0.5:
		if fmod(time_left,0.2)<0.1:
			$Sprite2D.texture=preload("res://assets/kenney_pixel-platformer/Tiles/tile_0010.png")
		else:
			$Sprite2D.texture=preload("res://assets/kenney_pixel-platformer/Tiles/tile_0030.png")
