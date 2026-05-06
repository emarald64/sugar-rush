extends CharacterBody2D

const MAX_SPEED = 300.0
const ACCEL = 800
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = clampf(velocity.x+(direction * ACCEL * delta * (1 if signf(direction)==signf(velocity.x) else 2)),-MAX_SPEED,MAX_SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCEL*delta*2)
	$Polygon2D.skew=velocity.x*-0.001
	$Polygon2D.position.y=8-cos($Polygon2D.skew)*8

	move_and_slide()
