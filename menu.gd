extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func updateInstructionsOnScreen(instruction_count):
	instruction_count += 1
	if (instruction_count == 1):
		$Control/MarginContainer/VBoxContainer/mainInstruction.text = "Press the SPACE BAR to move the pan. Don't let the Egg Fall!"
	if (instruction_count == 2):
		$Control/MarginContainer/VBoxContainer/mainInstruction.text = "The longer you balance the ball, the more points you get..."
	if (instruction_count == 3):
		$Control/MarginContainer/VBoxContainer/mainInstruction.text = "But when the ball falls, you lose points"
	elif (instruction_count == 4 ):
		$Control/MarginContainer/VBoxContainer/mainInstruction.text = "Hold and release the SPACE BAR to move the pan under the Egg"
	elif (instruction_count == 5 ):
		$Control/MarginContainer/VBoxContainer/mainInstruction.text = "Can you get 3,000 points?"
	elif (instruction_count == 6 ):
		$Control/MarginContainer/VBoxContainer/mainInstruction.hide()
	print("debug, instruction_count: " + str(instruction_count     ))
	return instruction_count
