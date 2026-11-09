
extends CharacterBody2D

# ----------------------------------------
# Movement configuration
# ----------------------------------------

@export var acceleration: float = 500.0
@export var max_speed: float = 400.0
@export var reverse_speed: float = 150.0
@export var friction: float = 300.0

# Steering
@export var steering_speed: float = 2.5

# Grip and drifting
@export var normal_grip: float = 8.0
@export var drift_grip: float = 2.5
@export var handbrake_deceleration: float = 650.0

var current_speed: float = 0.0
var lateral_speed: float = 0.0


func _physics_process(delta: float) -> void:
	handle_acceleration(delta)
	handle_steering(delta)
	apply_movement(delta)


# ----------------------------------------
# Acceleration and braking
# ----------------------------------------

func handle_acceleration(delta: float) -> void:
	if Input.is_action_pressed("accelerate"):
		current_speed += acceleration * delta

	elif Input.is_action_pressed("brake"):
		if current_speed > 0.0:
			current_speed = move_toward(
				current_speed,
				0.0,
				acceleration * delta
			)
		else:
			current_speed -= acceleration * delta

	else:
		current_speed = move_toward(
			current_speed,
			0.0,
			friction * delta
		)

	if Input.is_action_pressed("handbrake"):
		current_speed = move_toward(
			current_speed,
			0.0,
			handbrake_deceleration * delta
		)

	current_speed = clampf(
		current_speed,
		-reverse_speed,
		max_speed
	)


# ----------------------------------------
# Steering
# ----------------------------------------

func handle_steering(delta: float) -> void:
	if absf(current_speed) < 5.0:
		return

	var steering_direction := Input.get_axis(
		"steer_left",
        "steer_right"
	)

	var steering_factor := clampf(
		absf(current_speed) / max_speed,
		0.0,
		1.0
	)

	rotation += (
		steering_direction
		* steering_speed
		* steering_factor
		* signf(current_speed)
		* delta
	)


# ----------------------------------------
# Lateral movement and grip
# ----------------------------------------

func apply_movement(delta: float) -> void:
	var forward_direction := Vector2.UP.rotated(rotation)
	var right_direction := Vector2.RIGHT.rotated(rotation)

	# Extract sideways velocity from existing momentum.
	lateral_speed = velocity.dot(right_direction)

	# Select grip depending on handbrake state.
	var grip := normal_grip

	if Input.is_action_pressed("handbrake"):
		grip = drift_grip

	# Reduce sideways velocity.
	lateral_speed = lerpf(
		lateral_speed,
		0.0,
		clampf(grip * delta, 0.0, 1.0)
	)

	# Reconstruct world-space velocity.
	velocity = (
		forward_direction * current_speed
		+ right_direction * lateral_speed
	)

	move_and_slide()
