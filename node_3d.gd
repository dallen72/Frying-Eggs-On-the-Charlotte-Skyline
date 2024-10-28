extends Node3D

const MAX_PAN_ANGLE_BEFORE_RESET = 0.3
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
var score
var hiScore
var instruction_count


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	random_num_generator = RandomNumberGenerator.new()
	
	_pan_was_just_reset = false	
	_pan_is_being_flipped = false
	_pan_is_being_moved_under_ball = false
	_game_started = false
	score = 1
	hiScore = 0
	instruction_count = 0
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func start_game():
	$rig/ball.apply_impulse(Vector3(0, 0, 0.5))
	$menu.hide()
	$scoreText.show()
	_game_started = true
	disableClickOnDesktop()	
			

func disableClickOnDesktop():
	if ( not (OS.has_feature("web_android") or OS.has_feature("web_ios")) ):
		$TouchScreenButton.hide()

			
			
func _physics_process(delta: float) -> void:
	if (not _game_started):
		processMenuInput()
	else:
		score += 1
		run_game_loop(delta)


func processMenuInput():	
	if (Input.is_action_just_pressed("ui_accept")):
		if (instruction_count < 6):
			instruction_count = $menu.updateInstructionsOnScreen(instruction_count)
		else:
			start_game()

	
func processGameplayInput():
	if (Input.is_action_just_pressed("ui_accept")):
		$panCalibrateTimer.start()

	if (Input.is_action_just_released("ui_accept")):
		if ( ! _pan_was_just_reset):
			flip_pan()
		_pan_was_just_reset = false
		$panCalibrateTimer.stop()
	

func run_game_loop(delta):    
	$scoreText.text = "SCORE : " + str(score) + " points"
	processGameplayInput()
			
	if (_pan_is_being_flipped == true):
		continue_flipping_pan(_angle_x, _angle_z)

	if (get_node_or_null("rig/ball")):
		if (true):#if ( ! _pan_is_rotating):
			if (_pan_is_being_moved_under_ball):
				$rig/ball.gravity_scale = 1
				_pan_is_being_moved_under_ball = false
				$rig.velocity = Vector3()
		
		if ($rig/ball.position.length() > 3.0):
			resetBall()


func resetBall():
	$rig/ball.queue_free()
	await $rig/ball.tree_exited
	if (score > hiScore):
		hiScore = score
		$hiScoreText.show()
		$hiScoreText.text = "HI SCORE : " + str(hiScore) + " points"
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


func _on_pan_calibrate_timer_timeout() -> void:	
	if (get_node_or_null("rig/ball")):
		if ($rig/pan.position.y - $rig/ball.position.y > 1):
			resetBall()
			return
		else:
			_pan_is_being_moved_under_ball = true
			_move_pan_under_ball()
		_pan_was_just_reset = true
			
		
# move the pan under the ball to like you would if you were balacing a ping pong paddle
func _move_pan_under_ball():	
	const OFFSET_PUSHING_BALL_DOWN = Vector3(0,-1    ,0)
	$rig/ball.apply_impulse(4*($rig/ballSpawn.position - $rig/ball.position) + OFFSET_PUSHING_BALL_DOWN)
	print("debug, pan moved under ball")

	$rig/ball.gravity_scale = 1
	_pan_is_being_moved_under_ball = false
	$rig.velocity = Vector3()
	
	score -= 100
	
	if ($rig/pan.rotation.x > 0.2 or $rig/pan.rotation.z > MAX_PAN_ANGLE_BEFORE_RESET):
		resetPan()

func resetPan():
	_previous_rotation_x = $rig/pan.rotation.x
	_previous_rotation_z = $rig/pan.rotation.z
	_angle_z = 0.1
	_angle_x = 0.1
	_elapsed = 0.01
	_pan_is_being_flipped = true	
