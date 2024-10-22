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
var _pan_was_just_reset
var _pan_is_being_moved_under_ball
var Ball = preload("res://ball.tscn")
var _game_started
var _instruction_count
var score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	random_num_generator = RandomNumberGenerator.new()
	
	_pan_was_just_reset = false	
	_pan_is_being_flipped = false
	_pan_is_being_moved_under_ball = false
	_game_started = false
	_instruction_count = 0
	score = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _physics_process(delta: float) -> void:
	if ( ! _game_started):
		if (Input.is_action_pressed("ui_accept")):
			$rig/ball.apply_impulse(Vector3(0, 0, 0.5))
			$menu.hide()
			$instructionOne.show()
			_game_started = true
	else:
		score += 1
		$scoreText.text = "SCORE : " + str(score) + " points"
		run_game_loop(delta)


func run_game_loop(delta):   
	if (_pan_is_rotating == true):
			rotate_pan(_angle_x, _angle_z)
			
	if (Input.is_action_just_pressed("ui_accept")):
		$panCalibrateTimer.start()


	if (Input.is_action_just_released("ui_accept")):
		_pan_was_just_reset = false
		flip_pan()
		$panCalibrateTimer.stop()
		if (_instruction_count < 48):
			_instruction_count += 1
			
		if (_instruction_count == 12):
			$instructionOne.hide()
			$instructionTwo.show()
		if (_instruction_count == 20):
			$instructionTwo.hide()
			$instructionThree.show()
		if (_instruction_count == 28):
			$instructionThree.hide()
			$instructionFour.show()
		if (_instruction_count == 36):
			$instructionFour.hide()
			$instructionFive.show()
		elif (_instruction_count == 44 ):
			$instructionFive.hide()
			$scoreText.show()
		print("debug, instruction_count: " + str(_instruction_count     ))

	if (_pan_is_being_flipped == true):
		continue_flipping_pan(_angle_x, _angle_z)

	if (get_node_or_null("rig/ball")):
		if ( ! _pan_is_rotating):
			if (_pan_is_being_moved_under_ball):
				$rig/ball.gravity_scale = 1
				_pan_is_being_moved_under_ball = false
				$rig.velocity = Vector3()
		
		if (_pan_is_being_moved_under_ball == true):
			var direction_to_center = $rig/ball.position - Vector3(0, 0, -0.5) - $rig/ballSpawn.position
			$rig.velocity = direction_to_center
			print("debug, pan velocity: " + str($rig.velocity))
			$rig.move_and_slide() # TODO: delta time?

		if ($rig/ball.position.length() > 3.0):
			$rig/ball.queue_free()
			await $rig/ball.tree_exited
			score /= 2
			var ball = Ball.instantiate()
			$rig.add_child(ball)
			ball.name = "ball"


func flip_pan():
	print("debug, inside flip_pan")
	_previous_rotation_x = $rig/pan.rotation.x
	_previous_rotation_z = $rig/pan.rotation.z
	while true:
		_angle_z   = -1 * $rig/pan.rotation.z + random_num_generator.randf_range(-0.1, 0.1)
		print("debug, angle_z : " + str(_angle_z))
		if (abs(_angle_z) > 0.05):
			break 
	while true:
		_angle_x = -1 * $rig/pan.rotation.x + random_num_generator.randf_range(-0.1, 0.1)
		print("debug, angle_x: " + str(_angle_x))
		if (abs(_angle_x) > 0.05):
			break
	print("debug, angle_x: " + str(_angle_x))
	print("debug, angle_z: " + str(_angle_z))
	_elapsed = 0.01
	_pan_is_being_flipped = true


func continue_flipping_pan(angle_x, angle_z):
	var starting_angle_z = $rig/pan.rotation.z
	var starting_angle_x = $rig/pan.rotation.x
	$rig/pan.rotation = Vector3(lerp_angle(starting_angle_x, angle_x, _elapsed), 0, lerp_angle(starting_angle_z, angle_z, _elapsed))
	_elapsed += 0.1
	var x_is_reached = false
	var z_is_reached = false
	if (_previous_rotation_x <= angle_x and $rig/pan.rotation.x >= angle_x):
		x_is_reached = true
	elif (_previous_rotation_x >= angle_x and $rig/pan.rotation.x <= angle_x):
		x_is_reached = true
	if (_previous_rotation_z <= angle_z and $rig/pan.rotation.z >= angle_z):
		z_is_reached = true
	elif (_previous_rotation_z >= angle_z and $rig/pan.rotation.z <= angle_z):
		z_is_reached = true
	elif (
		abs($rig/pan.rotation.z) > MAX_ANGLE
		or abs($rig/pan.rotation.x) > MAX_ANGLE):
		_pan_is_being_flipped = false

	if (x_is_reached and z_is_reached):
		_pan_is_being_flipped = false

	
#	var target_angle = $pan.global_position.angle_to_point(target)
	#$pan.rotation = Vector3(0, 0, 0) # x between pi/6 and -pi/6
	#$pan.rotation = Vector3(0, 0, 0) # x and z between pi/6 and -pi/6

#	$pan.rotate_z(deg_to_rad(lerp(0, 0, PI/6)))
	


func rotate_pan(angle_x, angle_z):
	var starting_angle_z = $rig/pan.rotation.z
	var starting_angle_x = $rig/pan.rotation.x
	$rig/pan.rotation = Vector3(lerp_angle(starting_angle_x, angle_x, _elapsed), 0, lerp_angle(starting_angle_z, angle_z, _elapsed))
	_elapsed += 0.1
	if (_previous_rotation_x < angle_x and $rig/pan.rotation.x >= angle_x):
		_pan_is_rotating = false
	elif (_previous_rotation_x > angle_x and $rig/pan.rotation.x <= angle_x):
		_pan_is_rotating = false
	if (_previous_rotation_z < angle_z and $rig/pan.rotation.z >= angle_z):
		_pan_is_rotating = false
	elif (_previous_rotation_x > angle_x and $rig/pan.rotation.z <= angle_z):
		_pan_is_rotating = false
	elif (
		abs($rig/pan.rotation.z) > MAX_ANGLE
		or abs($rig/pan.rotation.x) > MAX_ANGLE):
		_pan_is_rotating = false


func _on_pan_rotation_timer_timeout() -> void:
	_pan_is_rotating = true


func _on_pan_calibrate_timer_timeout() -> void:
	_move_pan_under_ball()
	_pan_was_just_reset = true
	_pan_is_being_moved_under_ball = true
		
		
# move the pan under the ball to like you would if you were balacing a ping pong paddle
func _move_pan_under_ball():
	const UP_OFFSET_PUSHING_BALL_UP = Vector3(0,1,0)
	$rig/ball.apply_impulse(-2*($rig/ball.position - $rig/ballSpawn.position) + UP_OFFSET_PUSHING_BALL_UP)
	#$rig/ball.inertia = Vector3(0.1, 0.1, 0.1)
	print("debug, pan moved under ball")
