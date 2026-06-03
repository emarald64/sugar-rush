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
#@export var can_wall_jump:=true
var deaths:=0
@export var noclip:=false
var used_noclip:=false

@onready var start_time:=Time.get_ticks_msec()
@onready var level:=get_parent()
@onready var sugar_rush_timer:=$"sugar rush timer"

@onready var current_cp:Node2D=$StartPos

func _ready()->void:
	$StartPos.position=global_position

func _process(_delta: float) -> void:
	$TextureProgressBar.value=sugar_rush_timer.time_left
	$TextureProgressBar.tint_progress=Color.from_hsv(sugar_rush_timer.time_left/4.5,1,1)
	if Input.is_action_just_pressed("pause"):
		var pause_screen=preload("res://scenes/pause screen/pause_screen.tscn").instantiate()
		get_parent().add_child(pause_screen)
		get_tree().paused=true

func _physics_process(delta: float) -> void:
	if not animating:
		if Input.is_action_just_pressed("noclip"):
			used_noclip=true
			noclip=not noclip
			collision_mask^=1
			$Hurtbox.collision_mask^=2
		
		if Input.is_action_just_pressed("respawn"):
			play_respawn_animation()
		
		if not is_on_floor():
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
		if Input.is_action_just_pressed("jump") and (is_on_floor() or not $coyoteTimer.is_stopped() or noclip):
			velocity.y=minf(JUMP_VELOCITY,velocity.y)
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
			var active_sugar_mult:=(1.0 if sugar_rush_timer.is_stopped() else SUGAR_RUSH_MULT)
			var adjusted_max_speed:=MAX_SPEED * active_sugar_mult
			var adjusted_accel:=ACCEL * active_sugar_mult
			if direction:
				if is_on_wall_only() and signf(get_wall_normal().x)==-signf(direction) and not sugar_rush_timer.is_stopped():
					# wall slide
					#$"wall jump leiency".start()a
					velocity.y=minf(velocity.y,WALL_SLIDE_SPEED)
				else:
					if absf(velocity.x)>adjusted_max_speed:
						velocity.x=move_toward(velocity.x,0,delta*ACCEL*(.5 if signf(velocity.x)==signf(direction) else STOP_MULT*active_sugar_mult))
					else:
						velocity.x = clampf(velocity.x+(direction * adjusted_accel * delta * (1.0 if signf(direction)==signf(velocity.x) else STOP_MULT*active_sugar_mult)),-adjusted_max_speed,adjusted_max_speed)
			else:
				velocity.x = move_toward(velocity.x, 0, adjusted_accel*delta*STOP_MULT*active_sugar_mult)

		if not is_on_floor():
			wall_normal=get_wall_check_normal()
			#print(wall_normal)
			if wall_normal!=0 and not sugar_rush_timer.is_stopped():
				if Input.is_action_just_pressed("jump"):
					# wall jump
					$"Freeze Direction Time".start()
					velocity=Vector2(wall_normal,1)*WALL_JUMP_VELOCITY

		move_and_slide()

func get_wall_check_normal()->int:
	if $"wall jump checks/left".has_overlapping_bodies():
		return 1
	if $"wall jump checks/right".has_overlapping_bodies(): 
		return -1
	return 0

func play_respawn_animation()->void:
	sugar_rush_timer.paused=true
	$AnimationPlayer.play(&"death")

func respawn()->void:
	sugar_rush_timer.paused=false
	sugar_rush_timer.stop()
	#$TextureProgressBar.scale=Vector2.ONE
	$TextureProgressBar.hide()
	global_position=current_cp.global_position
	$Polygon2D.scale=Vector2.ONE
	velocity=Vector2.ZERO
	get_tree().call_group(&"reset on respawn",&"reset")
	deaths+=1
	
	$Camera2D.align()
	
func on_pickup(pickup:Area2D)->void:
	match pickup.get_meta(&"pickup"):
		&"candy":
			sugar_rush_timer.start()
			$TextureProgressBar.show()
			pickup.disable()
		&"end":
			animating=true
			var popup_layer=preload("res://scenes/level end popup/level_end_popup.tscn").instantiate()
			var popup=popup_layer.get_child(0)
			var time:=Time.get_ticks_msec()-start_time
			var level_index:int=level.get_meta(&"level_index")
			
			if not used_noclip:
				if TitleScreen.level_times[level_index-1]==0:
					TitleScreen.death_counts[level_index-1]=deaths
					TitleScreen.level_times[level_index-1]=time
				else:
					TitleScreen.level_times[level_index-1]=mini(TitleScreen.level_times[level_index-1],time)
					TitleScreen.death_counts[level_index-1]=mini(TitleScreen.death_counts[level_index-1],deaths)
			
			popup.deaths=deaths
			popup.time_ms=time
			popup.level_index=level_index
			popup.used_noclip=used_noclip
			level.add_child(popup_layer)

func on_checkpoint()->void:
	sugar_rush_timer.stop()
	$TextureProgressBar.hide()
