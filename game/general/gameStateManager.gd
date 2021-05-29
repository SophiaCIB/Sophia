extends Node
enum team {A, B}

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	#init_game()

func attach_weapon(weapon, pos, dir) -> void:
	weapon.set_transform(pos)
	weapon.dropWeapon(dir)
	add_child(weapon)

remote func add_player(team : int, player_id : int) -> void:
	var player = load("res://player/Player.tscn").instance()
	player.set_name(str(player_id))
	player.set_network_master(player_id)
	player.connect("dropWeapon", self, "attach_weapon")
	player.init(team)
	print(get_tree().get_network_unique_id())
	add_child(player)

	#set spawning location
	player.translation = GlobalMapInformation.get_player_spawn(player)
	#player.spawn()
	if not player_id == get_tree().get_network_unique_id():
		#GlobalPlayersInformation.other_players.push_back(get_node(player.name))
		GameState.changed()

func set_win_condition(path : String) -> void:
	var file = File.new()
	file.open(path, file.READ)
	var text = file.get_as_text()
	var json = JSON.parse(text)

func spawn_all_player():
	for player in GameState.team_a:
		player.spawn()
	for player in GameState.team_b:
		player.spawn()

func restart_round():
	GlobalMapInformation.free_spawns()
	spawn_all_player()
	#$Map_Helper.reload_current_scene()

func _process(delta) -> void:
	if not GameState.team_a_is_alive():
		restart_round()
	elif not GameState.team_b_is_alive():
		restart_round()

remote func init_game():
	print("init game")
	add_player(team.A, get_tree().get_network_unique_id())
	for player in ServerState.player_info:
		add_player(team.B, player)

func _player_connected(id):
	add_player(team.B, id)
