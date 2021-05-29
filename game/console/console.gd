extends Control

var stack : Array = [""]
var stack_pointer : int = 1

enum argument_types {INT, FLOAT, STRING, BOOL}
var callable_objects = ['server']
var callable_by_command : Array = [
	['print', [argument_types.STRING]],
	['exit', []]
]

onready var input = get_node("panel/grid/input")
onready var output = get_node("panel/grid/output")

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func output_text(new_text) -> void:
	output.text += str(new_text, "\n")

func _on_input_text_entered(new_text : String) -> void:
	input.clear()
	output_text(new_text)
	stack.append(new_text)
	stack_pointer += 1
	var split_function_call : Array = new_text.split(" ")
	var file_name = split_function_call[0].to_lower()
	split_function_call.remove(0)
	if callable_objects.has(file_name):
		var function_name = split_function_call[0].to_lower()
		split_function_call.remove(0)
		var function_arguments = split_function_call
		var function_argument_types : Array
		for argument in function_arguments:
			function_argument_types.append(get_type(argument))
		function_arguments = convert_arguments(function_arguments, function_argument_types)
		if file_name == 'server':
			if ServerState.callable_by_command.has([function_name, function_argument_types]):
				output_text(ServerState.callv(function_name, function_arguments))
			else:
				output_text("invalid function call of object " + file_name)
		else:
			output_text("invalid object")
	else:
		var function_arguments = split_function_call
		var function_argument_types : Array
		for argument in function_arguments:
			function_argument_types.append(get_type(argument))
		function_arguments = convert_arguments(function_arguments, function_argument_types)
		if callable_by_command.has([file_name, function_argument_types]):
			output_text(self.callv(file_name, function_arguments))
		else:
			output_text("invalid function call of object " + file_name)

		
func convert_arguments(string : Array, type : Array) -> Array:
	var converted_arguments : Array 
	for i in range(string.size()):
		print(converted_arguments)
		if type[i] == argument_types.INT:
			converted_arguments.append(int(string[i]))
		if type[i] == argument_types.FLOAT:
			converted_arguments.append(float(string[i]))
		if type[i] == argument_types.STRING:
			converted_arguments.append(string[i])
		if type[i] == argument_types.BOOL:
			converted_arguments.append((string[i] == "true" or string[i] == "false"))
	return converted_arguments

func get_type(arugment : String):
	if arugment.is_valid_integer():
		return argument_types.INT
	if arugment.is_valid_float():
		return argument_types.FLOAT
	if arugment == "true" or arugment == "false":
		return argument_types.BOOL
	if not arugment.empty():
		return argument_types.STRING
	return

	
func process_input():
	if Input.is_action_just_released("open_debug_console"):
		self.visible = true
		input.grab_focus()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("ui_cancel"):
		self.visible = false
	if Input.is_action_just_pressed("stack_up_debug_console"):
		if stack_pointer - 1 >= 0:
			stack_pointer -= 1
		input.text = stack[stack_pointer]
	if Input.is_action_just_pressed("stack_down_debug_console"):
		if stack_pointer + 1 < stack.size():
			stack_pointer += 1
			input.text = stack[stack_pointer]
		elif stack_pointer + 1 == stack.size():
			stack_pointer = stack.size()
			input.text = ""

func exit() -> String:
	get_tree().quit()
	return 'bye'

func print(text : String) -> String:
	return text

func _player_connected(id):
	output_text("player connected " + str(id))

func _player_disconnected(id):
	output_text("player disconnected " + str(id))

func _connected_ok():
	output_text("conntected to server")

func _server_disconnected():
	output_text("disconnected")

func _connected_fail():
	output_text("cannot reach server")


func _physics_process(delta):
	process_input()
		
