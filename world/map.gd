extends Node
enum team {ATTACKER, DEFENDER}


func _ready():
	# addPlayer(false, team.DEFENDER)
	addPlayer(true, team.ATTACKER)
	addPlayer(false, team.DEFENDER)
	

func attachWeapon(weapon, pos, dir) -> void:
	print("drop2")
	weapon.set_transform(pos)
	weapon.dropWeapon(dir)
	add_child(weapon)

func shootBullet(pos, dir) -> void:
	var bulletSpeedMultiplyer = 100
	var bullet = load("res://weapons/bullet/bullet.tscn").instance()
	bullet.set_transform(pos)
	dir = Vector3(sin(deg2rad(dir.x)), sin(deg2rad(dir.y)), -cos(deg2rad(dir.x))).normalized()
	bullet.apply_central_impulse(dir * bulletSpeedMultiplyer)
	add_child(bullet)

func addPlayer(playable : bool, team : int) -> void:
	var player = load("res://player/Player.tscn").instance()
	player.connect("dropWeapon", self, "attachWeapon")
	# player.connect("shoot", self, "shootBullet")
	player.init(playable, team)
	add_child(player)
