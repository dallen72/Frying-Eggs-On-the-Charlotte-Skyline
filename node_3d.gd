extends Node3D

signal pan_should_rotate_now

var _pan_is_rotating
var _elapsed
var _angle_x
var _angle_z
const MAX_ANGLE = PI/6
var random_num_generator
var _previous_rotation_x
var _previous_rotation_z
var _pan_is_being_flipped

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_auto_pan_rotate()
		
	_pan_is_being_flipped = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _physics_process(delta: float) -> void:
	if (_pan_is_rotating == true):
		rotate_pan(_angle_x, _angle_z)
		
	if (Input.is_action_just_pressed("ui_accept")):
		flip_pan()
		
	if (Input.is_action_pressed("ui_accept")):
		$panCalibrateTimer.start()

	if (_pan_is_being_flipped == true):
		continue_flipping_pan(_angle_x, _angle_z)


func _initialize_auto_pan_rotate():
	$panRotationTimer.start()
	_pan_is_rotating = false
	_elapsed = 0.0
	_previous_rotation_x = 0.0
	_previous_rotation_z = 0.0
	random_num_generator = RandomNumberGenerator.new()
	_angle_x = 	random_num_generator.randf_range(-1*MAX_ANGLE, MAX_ANGLE)
	_angle_z = 	random_num_generator.randf_range(-1*MAX_ANGLE, MAX_ANGLE)
	if (abs(_angle_x) > 0.1):
		_angle_x = 0.2
	elif (abs(_angle_z) > 0.1):
		_angle_z = 0.2


func flip_pan():
	_previous_rotation_x = $pan.rotation.x
	_previous_rotation_z = $pan.rotation.z
	_angle_z = -1 * $pan.rotation.z + random_num_generator.randf_range(-0.1, 0.1)
	_angle_x = -1 * $pan.rotation.x + random_num_generator.randf_range(-0.1, 0.1)
	_elapsed = 0.01
	_pan_is_being_flipped = true


func continue_flipping_pan(angle_x, angle_z):
	var starting_angle_z = $pan.rotation.z
	var starting_angle_x = $pan.rotation.x
	$pan.rotation = Vector3(lerp_angle(starting_angle_x, angle_x, _elapsed), 0, lerp_angle(starting_angle_z, angle_z, _elapsed))
	_elapsed += 0.1
	var x_is_reached = false
	var z_is_reached = false
	if (_previous_rotation_x <= angle_x and $pan.rotation.x >= angle_x):
		x_is_reached = true
	elif (_previous_rotation_x >= angle_x and $pan.rotation.x <= angle_x):
		x_is_reached = true
	if (_previous_rotation_z <= angle_z and $pan.rotation.z >= angle_z):
		z_is_reached = true
	elif (_previous_rotation_z >= angle_z and $pan.rotation.z <= angle_z):
		z_is_reached = true
	elif (
		abs($pan.rotation.z) > MAX_ANGLE
		or abs($pan.rotation.x) > MAX_ANGLE):
		_pan_is_being_flipped = false

	if (x_is_reached and z_is_reached):
		_pan_is_being_flipped = false

#	var target_angle = $pan.global_position.angle_to_point(target)
	#$pan.rotation = Vector3(0, 0, 0) # x between pi/6 and -pi/6
	#$pan.rotation = Vector3(0, 0, 0) # x and z between pi/6 and -pi/6

#	$pan.rotate_z(deg_to_rad(lerp(0, 0, PI/6)))
	


func rotate_pan(angle_x, angle_z):
	var starting_angle_z = $pan.rotation.z
	var starting_angle_x = $pan.rotation.x
	$pan.rotation = Vector3(lerp_angle(starting_angle_x, angle_x, _elapsed), 0, lerp_angle(starting_angle_z, angle_z, _elapsed))
	_elapsed += 0.1
	if (_previous_rotation_x < angle_x and $pan.rotation.x >= angle_x):
		_pan_is_rotating = false
	elif (_previous_rotation_x > angle_x and $pan.rotation.x <= angle_x):
		_pan_is_rotating = false
	if (_previous_rotation_z < angle_z and $pan.rotation.z >= angle_z):
		_pan_is_rotating = false
	elif (_previous_rotation_x > angle_x and $pan.rotation.z <= angle_z):
		_pan_is_rotating = false
	elif (
		abs($pan.rotation.z) > MAX_ANGLE
		or abs($pan.rotation.x) > MAX_ANGLE):
		_pan_is_rotating = false


func _on_pan_rotation_timer_timeout() -> void:
	_pan_is_rotating = true


func _on_pan_calibrate_timer_timeout() -> void:
	if 3 seconds passed:
		_move_pan_under_ball()
		
		
func _move_pan_under_ball():
	# move the pan under the ball to like you would if you were balacing a ping pong paddle
