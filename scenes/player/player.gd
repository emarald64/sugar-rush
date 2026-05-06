extends CharacterBody2D

const MAX_SPEED = 300.0
const ACCEL = 600
const JUMP_VELOCITY = -200.0
const JUMP_ACCEL = -600.0
const MAX_JUMP_TIME=.5
const STOP_MULT=3;
const MAX_FALL_SPEED=1000;
const WALL_JUMP_VELOCITY=225;
const WALL_SLIDE_SPEED=75;

var jumpTime:=0.0
var animating:=false
var started_timer:=false
var hasJumped:=false

func _physics_process(delta: float) -> void:
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
			if is_on_wall_only():
				if Input.is_action_just_pressed("jump"):
					$"Freeze Direction Time".start()
					velocity=Vector2(-signf(direction),-1.5)*WALL_JUMP_VELOCITY
				else:
					velocity.y=minf(velocity.y,WALL_SLIDE_SPEED)
			else:
				velocity.x = clampf(velocity.x+(direction * ACCEL * delta * (1 if signf(direction)==signf(velocity.x) else STOP_MULT)),-MAX_SPEED,MAX_SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, ACCEL*delta*STOP_MULT)

	move_and_slide()
