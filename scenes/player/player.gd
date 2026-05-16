class_name Player extends CharacterBody2D

const MAX_SPEED = 225.0
const ACCEL = 450
const JUMP_VELOCITY = -250.0
const JUMP_ACCEL = -950.0
const MAX_JUMP_TIME=.3
const STOP_MULT=3;
const MAX_FALL_SPEED=1000;
const WALL_JUMP_VELOCITY=Vector2(150,-400);
const WALL_SLIDE_SPEED=75;
const SUGAR_RUSH_MULT=1.75

var wall_normal:=0
@export var animating:=false
var jumpTime:=0.0
var started_timer:=false
var hasJumped:=false
@export var can_wall_jump:=true
var deaths:=0
@onready var start_time:=Time.get_ticks_msec()

@onready var current_cp:Node2D=$StartPos

func _ready()->void:
	$StartPos.position=global_position

func _process(_delta: float) -> void:
	$TextureProgressBar.value=$"sugar rush timer".time_left
	$TextureProgressBar.tint_progress=Color.from_hsv($"sugar rush timer".time_left/6,1,1)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("respawn") and not animating:
		play_respawn_animation()
	
	if not is_on_floor():
		#if $AnimatedSprite2D.frame==0 or jumpTime<maxJumpTime:$AnimatedSprite2D.frame=2
		if not animating:
			velocity.y=min((get_gravity().y * delta)+velocity.y,MAX_FALL_SPEED)
		if not started_timer:
			$coyoteTimer.start()
			started_timer=true
	else:
		hasJumped=false
		started_timer=false
		#$coyoteTimer.stop()
		#$"wall jump leiency".stop()
		$"Freeze Direction Time".stop()
			
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or not $coyoteTimer.is_stopped()):
		velocity.y=min(JUMP_VELOCITY,velocity.y)
		$coyoteTimer.stop()
		hasJumped=true
		started_timer=true
		jumpTime=0
	elif Input.is_action_pressed("jump") and jumpTime<MAX_JUMP_TIME and hasJumped:
		velocity.y+=JUMP_ACCEL*delta
		jumpTime+=delta
	
	if is_on_wall():
		$"Freeze Direction Time".stop()

	$Polygon2D.skew=velocity.x*-0.001
	$Polygon2D.position.y=8-cos($Polygon2D.skew)*8

	if $"Freeze Direction Time".is_stopped():
		var direction := Input.get_axis("move_left", "move_right")
		#print(direction)
		if direction:
			if is_on_wall_only() and signf(get_wall_normal().x)==-signf(direction) and can_wall_jump:
				# wall slide
				#$"wall jump leiency".start()a
				velocity.y=minf(velocity.y,WALL_SLIDE_SPEED)
			else:
				velocity.x = clampf(velocity.x+(direction * ACCEL * delta * (1 if signf(direction)==signf(velocity.x) else STOP_MULT)) * (1 if $"sugar rush timer".is_stopped() else SUGAR_RUSH_MULT),-MAX_SPEED * (1 if $"sugar rush timer".is_stopped() else SUGAR_RUSH_MULT),MAX_SPEED * (1 if $"sugar rush timer".is_stopped() else SUGAR_RUSH_MULT))
		else:
			velocity.x = move_toward(velocity.x, 0, ACCEL*delta*STOP_MULT * (1 if $"sugar rush timer".is_stopped() else SUGAR_RUSH_MULT))

	if not is_on_floor():
		wall_normal=get_wall_check_normal()
		#print(wall_normal)
		if wall_normal!=0 and can_wall_jump:
			if Input.is_action_just_pressed("jump"):
				# wall jump
				$"Freeze Direction Time".start()
				velocity=Vector2(wall_normal,1)*WALL_JUMP_VELOCITY

	if not animating:move_and_slide()

func get_wall_check_normal()->int:
	if $"wall jump checks/left".has_overlapping_bodies():
		return 1
	if $"wall jump checks/right".has_overlapping_bodies(): 
		return -1
	return 0

func play_respawn_animation()->void:
	$"sugar rush timer".paused=true
	$AnimationPlayer.play(&"death")

func respawn()->void:
	$"sugar rush timer".paused=false
	$"sugar rush timer".stop()
	#$TextureProgressBar.scale=Vector2.ONE
	$TextureProgressBar.hide()
	global_position=current_cp.global_position
	$Polygon2D.scale=Vector2.ONE
	velocity=Vector2.ZERO
	get_tree().call_group(&"enable on respawn",&"enable")
	deaths+=1
	
	$Camera2D.align()
	
func on_pickup(pickup:Area2D)->void:
	match pickup.get_meta(&"pickup"):
		&"candy":
			$"sugar rush timer".start()
			$TextureProgressBar.show()
			pickup.disable()
		&"end":
			animating=true
			var popup=preload("res://scenes/level end popup/level_end_popup.tscn").instantiate()
			popup.deaths=deaths
			popup.time_ms=Time.get_ticks_msec()-start_time
			get_parent().add_child(popup)

func on_checkpoint()->void:
	$"sugar rush timer".stop()
	$TextureProgressBar.hide()
