extends Node
enum team {A, B}


func _ready():
	addPlayer(true, team.A)
	addPlayer(false, team.B)
	#addPlayer(false, team.B)
	#addPlayer(false, team.ATTACKER)
	#setWinCondition('res://game/defuse.json')

func attachWeapon(weapon, pos, dir) -> void:
	weapon.set_transform(pos)
	weapon.dropWeapon(dir)
	add_child(weapon)

func addPlayer(playable : bool, team : int) -> void:
	var player = load("res://player/Player.tscn").instance()
	player.connect("dropWeapon", self, "attachWeapon")
	player.init(playable, team)
	add_child(player)

	#set spawning location
	player.translation = GlobalMapInformation.get_player_spawn(player)
	#player.spawn()
	if not playable:
		#GlobalPlayersInformation.other_players.push_back(get_node(player.name))
		GameState.changed()

func setWinCondition(path : String) -> void:
	var file = File.new()
	file.open(path, file.READ)
	var text = file.get_as_text()
	var json = JSON.parse(text)

func spawnAllPlayer():
	for player in GameState.team_a:
		player.spawn()
	for player in GameState.team_b:
		player.spawn()

func restartRound():
	GlobalMapInformation.free_spawns()
	spawnAllPlayer()
	#$Map_Helper.reload_current_scene()

func _process(delta) -> void:
	if not GameState.team_a_is_alive():
		restartRound()
	elif not GameState.team_b_is_alive():
		restartRound()
