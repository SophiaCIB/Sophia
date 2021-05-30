extends Node
enum argument_types {INT, FLOAT, STRING, ARRAY}

var callable_by_command : Array = [
	['start', [argument_types.INT]],
	['connect_to', [argument_types.STRING, argument_types.INT]],
	['init_game', []]
]

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	set_network_master(1)
	#start(2)

# Player info, associate ID to data
var player_id = {}
# Info we send to other players
var my_info = { name = "Johnson Magenta", favorite_color = Color8(255, 0, 255) }

func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	print("player connected")
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	pass

func _connected_ok():
	pass

func _server_disconnected():
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.

remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_id[id] = info


	# Call function to update lobby UI here

func start(max_players : int) -> String:
	var peer = NetworkedMultiplayerENet.new()
	var port : int = 28111
	peer.create_server(port, max_players)
	get_tree().network_peer = peer
	return 'server started with ' + str(max_players) + " on port " + str(port) 

func connect_to(SERVER_IP : String, SERVER_PORT : int) -> String:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer
	return 'connecting to server'

master func init_game() -> String:
	#if is_network_master():
	#	rpc("init_game")
	get_tree().get_root().get_node("GameStateManager").init_game()
	return "initalizing game"
