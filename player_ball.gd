extends CharacterBody3D


@export var SPEED = 1.0
@export var FRICTION = 0.1
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var strength := 0
@export var rotation_speed = 50

@export var score = 0

var strength_factor = 1
var max_strength = 100

var increasing = true
var is_shoot = false

@onready var cam = $Camera_Controller/Camera_Target/Camera3D

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	cam.current = is_multiplayer_authority()

func friction():
	velocity = velocity.move_toward(Vector3.ZERO, FRICTION)


func _physics_process(delta):
	if Input.is_key_pressed(KEY_SHIFT):
		rotation_speed = 100

	if Input.is_key_pressed(KEY_ESCAPE):
		$"-./".exit_game(name.to_int())
		get_tree().quit()

	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		print(collision_info)
		velocity = velocity.bounce(collision_info.get_normal())
	# Handle camera follow
	$Camera_Controller.position = lerp($Camera_Controller.position,position,0.1)

	var display_tag = str(score)
	$ScoreText.text = display_tag

	# Show strength
	get_parent().get_node("StrengthBar").get_node("ProgressBar").value = strength

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle movement
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	$Camera_Controller.rotation.y = rotation.y
	$Camera_Controller.rotation.z = rotation.z
	
	# if Input.is_action_pressed("left") || Input.is_action_pressed("right"):
	# 	if direction:
	# 		last_direction = direction
	# 		var d = direction.x / rotation_speed
	# 		$Node3D.rotate_y(d)

	if Input.is_action_pressed("right"):
		rotation.y -= deg_to_rad(rotation_speed * delta)  # Rotate right
	if Input.is_action_pressed("left"):
		rotation.y += deg_to_rad(rotation_speed * delta)  # Rotate left
	if Input.is_action_pressed("up"):
		rotation.x += deg_to_rad(rotation_speed * delta)  # Rotate left
	if Input.is_action_pressed("down"):
		rotation.x -= deg_to_rad(rotation_speed * delta)  # Rotate left
	

	# Handle getting shot
	if Input.is_action_pressed("shoot") and !is_shoot:
		if increasing:
			strength += strength_factor
			if strength >= max_strength:
				strength = max_strength
				increasing = false
		else:
			strength -= strength_factor
			if strength <= 0:
				strength = 0
				increasing = true

	if Input.is_action_just_released("shoot") and !is_shoot:
		score += 1
		var forward_direction = -transform.basis.z.normalized()
		velocity = forward_direction * SPEED * strength
		
		# velocity.x = direction.x + SPEED * strength / 10
		# velocity.y = direction.y + SPEED * strength / 10
		# velocity.z = direction.z + SPEED * strength / 10
		# accelerate(velocity)

		print(velocity)
		strength = 0
		is_shoot = true

	if is_on_floor():
		friction()

	if velocity == Vector3(0,0,0):
		is_shoot = false

	# velocity = direction.normalized() * SPEED
	move_and_slide()
