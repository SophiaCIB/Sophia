extends Node
enum team {A, B}

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	set_network_master(1)
	#init_game()

func attach_weapon(weapon, pos, dir) -> void:
	weapon.set_transform(pos)
	weapon.dropWeapon(dir)
	add_child(weapon)

remote func add_player(team : int, player_id : int) -> void:
	if multiplayer.get_rpc_sender_id() == 1 or get_tree().get_network_unique_id():
		print("add_player ", team, " ", player_id)
		var player = load("res://player/player_model.tscn").instance()
		#player.set_name(str(player_id))
		#player.set_network_master(player_id)
		player.connect("drop_weapon", self, "attach_weapon")
		add_child(player)
		player.init(player_id, team)
		print(player_id)

		#set spawning location
		player.translation = GlobalMapInformation.get_player_spawn(player)
		#player.spawn()
		if not player_id == get_tree().get_network_unique_id():
			#GlobalPlayersInformation.other_players.push_back(get_node(player.name))
			pass
		GameState.changed()

func set_win_condition(path : String) -> void:
	var file = File.new()
	file.open(path, file.READ)
	var text = file.get_as_text()
	var json = JSON.parse(text)
	#TODO

func spawn_all_player():
	for player in GameState.team_a:
		player.spawn()
	for player in GameState.team_b:
		player.spawn()

puppet func restart_round():
	GlobalMapInformation.free_spawns()
	spawn_all_player()
	#TODO
	#reset ammunition etc
	#reset scene

func _process(delta) -> void:
	if not GameState.team_a_is_alive():
		restart_round()
	if not GameState.team_b_is_alive():
		restart_round()
	pass

func init_game():
	#rpc('add_player', team.A, get_tree().get_network_unique_id())
	print("hello")
	add_player(team.A, get_tree().get_network_unique_id())
	for player in ServerState.player_id:
		print("player ", player)
		rpc('add_player', team.B, player)
	GameState.changed()
	# muss noch auf alle spieler angepasst werden
	GameState.rpc('reset_tick', ServerState.ping)
		#add_player(team.B, player)
	#restart_round()

func reset_game():
	restart_round()
	for player in GameState.team_a:
		player.queue_free()
	for player in GameState.team_b:
		player.queue_free()
	GameState.changed()

func _player_connected(id):
	#add_player(team.B, id)
	pass
