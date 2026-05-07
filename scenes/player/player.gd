extends CharacterBody2D

const MAX_SPEED = 300.0
const ACCEL = 600
const JUMP_VELOCITY = -200.0
const JUMP_ACCEL = -600.0
const MAX_JUMP_TIME=.25
const STOP_MULT=3;
const MAX_FALL_SPEED=1000;
const WALL_JUMP_VELOCITY=200;
const WALL_SLIDE_SPEED=75;

@export var animating:=false
var jumpTime:=0.0
var started_timer:=false
var hasJumped:=false
@export var can_wall_jump:=true;

@onready var current_cp:Node2D=$StartPos

func _ready()->void:
	$StartPos.position=global_position

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("respawn") and not animating:
		$AnimationPlayer.play(&"death")
	
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
		$coyoteTimer.stop()
		$"wall jump leiency".stop()
		$"Freeze Direction Time".stop()
			
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or not $coyoteTimer.is_stopped()):
		velocity.y=min(JUMP_VELOCITY,velocity.y)
		$coyoteTimer.stop()
		hasJumped=true
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
			var into_wall=is_on_wall_only() and signf(get_wall_normal().x)==-signf(direction)
			if (into_wall or not $"wall jump leiency".is_stopped()) and can_wall_jump:
				if Input.is_action_just_pressed("jump"):
					# wall jump
					$"Freeze Direction Time".start()
					velocity=Vector2(signf(get_wall_normal().x),-2)*WALL_JUMP_VELOCITY
				elif into_wall:
					# wall slide
					$"wall jump leiency".start()
					velocity.y=minf(velocity.y,WALL_SLIDE_SPEED)
			else:
				velocity.x = clampf(velocity.x+(direction * ACCEL * delta * (1 if signf(direction)==signf(velocity.x) else STOP_MULT)),-MAX_SPEED,MAX_SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, ACCEL*delta*STOP_MULT)

	if not animating:move_and_slide()

func respawn()->void:
	global_position=current_cp.global_position
	$Polygon2D.scale=Vector2.ONE
	velocity=Vector2.ZERO
