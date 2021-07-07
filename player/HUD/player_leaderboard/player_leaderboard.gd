extends Control

onready var attacker_stats : Node = get_node('TabContainer/Stats/GridContainer2/Attacker')
onready var attacker_advanced : Node = get_node('TabContainer/Advanced/GridContainer3/Attacker')
onready var defender_stats : Node = get_node('TabContainer/Stats/GridContainer2/Defender')
onready var defender_advanced : Node = get_node('TabContainer/Advanced/GridContainer3/Defender')

func _ready():
	GameState.connect('changed', self, 'add_player')
	for player in GameState.team_a:
		var entry_stats : Node = load('res://player/HUD/player_leaderboard/entry_stats.tscn').instance()
		entry_stats.set_name(player.name)
		var entry_advanced : Node = load('res://player/HUD/player_leaderboard/entry_advanced.tscn').instance()
		entry_advanced.set_name(player.name)
		attacker_stats.add_child(entry_stats)
		attacker_advanced.add_child(entry_advanced)
	for player in GameState.team_b:
		var entry_stats : Node = load('res://player/HUD/player_leaderboard/entry_stats.tscn').instance()
		entry_stats.set_name(player.name)
		var entry_advanced : Node = load('res://player/HUD/player_leaderboard/entry_advanced.tscn').instance()
		entry_advanced.set_name(player.name)
		defender_stats.add_child(entry_stats)
		defender_advanced.add_child(entry_advanced)

func reload_all_information():
	for player in GameState.team_a:
		attacker_stats.get_node(player.name).update_all(player.stats)
		attacker_advanced.get_node(player.name).update_all(player.stats)
	for player in GameState.team_b:
		defender_stats.get_node(player.name).update_all(player.stats)
		defender_advanced.get_node(player.name).update_all(player.stats)
	
func add_player():
	print("information recieved")
	
	for player in GameState.team_a:
		print(attacker_stats.get_node(player.name) == null && attacker_advanced.get_node(player.name) == null)
		if attacker_stats.get_node(player.name) == null && attacker_advanced.get_node(player.name) == null:
			var entry_stats : Node = load('res://player/HUD/player_leaderboard/entry_stats.tscn').instance()
			entry_stats.set_name(player.name)
			var entry_advanced : Node = load('res://player/HUD/player_leaderboard/entry_advanced.tscn').instance()
			entry_advanced.set_name(player.name)
			attacker_stats.add_child(entry_stats)
			attacker_advanced.add_child(entry_advanced)
			reload_all_information()
	for player in GameState.team_b:
		if defender_stats.get_node(player.name) == null && defender_advanced.get_node(player.name) == null:
			var entry_stats : Node = load('res://player/HUD/player_leaderboard/entry_stats.tscn').instance()
			entry_stats.set_name(player.name)
			var entry_advanced : Node = load('res://player/HUD/player_leaderboard/entry_advanced.tscn').instance()
			entry_advanced.set_name(player.name)
			defender_stats.add_child(entry_stats)
			defender_advanced.add_child(entry_advanced)
