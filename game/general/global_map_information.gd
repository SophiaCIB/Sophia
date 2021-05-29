extends Node
enum teams {ATTACKER, DEFENDER, ALL}
var attacker_spawns : Array 
var defender_spawns : Array
var all_spawns : Array

var time : float
var score : Vector2

func register_spawn(spawn : Node) -> void:
	match spawn.spawing_area:
		teams.ATTACKER: attacker_spawns.append(spawn)
		teams.DEFENDER: defender_spawns.append(spawn)
		teams.ALL: all_spawns.append(spawn)

func free_spawns() -> void:
	for spawn in attacker_spawns:
		spawn.occupied = false
	for spawn in defender_spawns:
		spawn.occupied = false
	for spawn in defender_spawns:
		spawn.occupied = false

func get_player_spawn(player : Node) -> Vector3:
	randomize()
	var spawn_available = true
	match player.team:
		teams.ATTACKER:
			if attacker_spawns.size() > 0:
				var rand = randi() % (attacker_spawns.size())
				var rand_init = rand
				var spawn = attacker_spawns[rand]
				while(spawn.occupied):
					rand = (rand + 1) %  attacker_spawns.size()
					if rand == rand_init:
						spawn_available = false
						break
					spawn = attacker_spawns[rand]
				if(spawn_available):
					spawn.occupied = true
					return spawn.translation

		teams.DEFENDER:
			if defender_spawns.size() > 0:
				var rand = randi() % (defender_spawns.size())
				var rand_init = rand
				var spawn = defender_spawns[rand]
				while(spawn.occupied):
					rand = (rand + 1) %  defender_spawns.size()
					if rand == rand_init:
						spawn_available = false
						break
					spawn = defender_spawns[rand]
				if(spawn_available):
					spawn.occupied = true
					return spawn.translation

		teams.ALL:
			if all_spawns.size() > 0:
				var rand = randi() % (all_spawns.size())
				var rand_init = rand
				var spawn = all_spawns[rand]
				while(spawn.occupied):
					rand = (rand + 1) %  all_spawns.size()
					if rand == rand_init:
						spawn_available = false
						break
					spawn = all_spawns[rand]
				if(spawn_available):
					spawn.occupied = true
					return spawn.translation
	return Vector3(0,0,0)
