extends "res://weapons/weapon.gd"

# weapon_id : String, 
# rate_of_fire : float, 
# prize : int, 
# magazine_capacity : int,
# bullets_to_reload : int, 
# firing_modes : Array, 
# reload_time : float, 
# movement_speed : float, 
# kill_award : int, 
# damage : int, 
# armor_penetration : int,
# recoilPattern : PoolVector2Array
# func _init().("scifigun", 10.0, 2000, 30, 90, [1], 30, 30, 100, 100, 100, PoolVector2Array(
# 	[
# 		Vector2(0, 0), Vector2(0, 1), 
# 		Vector2(0, 1), Vector2(1, 2), 
# 		Vector2(1, 2), Vector2(1, 2),
# 		Vector2(0, 2), Vector2(0, 2),
# 		Vector2(0, 2), Vector2(0, 2),
# 		Vector2(0, 2), Vector2(0, 2),
# 		Vector2(0, 2), Vector2(0, 2),
# 		Vector2(0, 2), Vector2(0, 2),
# 		Vector2(0, 2), Vector2(0, 2),
# 		Vector2(0, 2), Vector2(0, 2),
# 		Vector2(0, 2), Vector2(0, 2),
# 		Vector2(0, 2), Vector2(0, 2),
# 		Vector2(0, 2), Vector2(0, 2),
# 		Vector2(0, 2), Vector2(0, 2),
# 		Vector2(0, 2), Vector2(0, 2),
# 		])):
# 	pass

func _ready():
	weapon_id = "scifigun"
	rate_of_fire = 10.0
	prize = 2000 
	magazine_capacity = 30
	spare_bullets = 90
	firing_modes = [1]
	reload_time = 2.5 
	movement_speed = 30 
	kill_award = 100 
	base_damage = 100 
	armor_penetration = 100
	bullets_left_in_mag = magazine_capacity
	recoil_pattern = PoolVector2Array(
		[
			Vector2(0, 0), Vector2(0, 1), 
			Vector2(0, 1), Vector2(1, 2), 
			Vector2(1, 2), Vector2(1, 2),
			Vector2(0, 2), Vector2(0, 2),
			Vector2(0, 2), Vector2(0, 2),
			Vector2(0, 2), Vector2(0, 2),
			Vector2(0, 2), Vector2(0, 2),
			Vector2(0, 2), Vector2(0, 2),
			Vector2(20, 2), Vector2(20, 2),
			Vector2(20, 2), Vector2(20, 2),
			Vector2(20, 2), Vector2(20, 2),
			Vector2(0, 2), Vector2(0, 2),
			Vector2(0, 2), Vector2(0, 2),
			Vector2(0, 2), Vector2(0, 2),
			Vector2(0, 2), Vector2(0, 2),
			])
