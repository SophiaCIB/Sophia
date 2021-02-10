extends RigidBody

class_name Weapon

var weapon_id = ""
#shots per minute
var rate_of_fire = 0
#in currency
var prize = 1000
#in rounds
var magazine_capacity = 0
#0 automatic, 1 burst, 2 single
var firing_modes = [0, 1, 2]
#in seconds
var reload_time = 2.5
#in percent
var movement_speed = 100 
#percent
var kill_award = 0
#percent
var damage = 0
#percent
var armor_penetration = 0
#last time a shot was fired
var last_shot = 0
var next_shot = true
#animationplayer
var animationplayer

func _init(weapon_id, rate_of_fire, prize, magazine_capacity, firing_modes, reload_time, movement_speed, kill_award, damage, armor_penetration):
	self.weapon_id = weapon_id
	self.rate_of_fire = rate_of_fire
	self.prize = prize
	self.magazine_capacity = magazine_capacity
	self.firing_modes = firing_modes
	self.reload_time = reload_time
	self.movement_speed = movement_speed
	self.kill_award = kill_award
	self.damage = damage
	self.armor_penetration = armor_penetration
	self.animationplayer = animationplayer

func _process(delta):
	if !next_shot && last_shot < 1/rate_of_fire:
		last_shot += delta
	else:
		last_shot = 0
		next_shot = true

func setAnimation():
	$AnimationTree.set("parameters/shot_animation/active", true)

func dropWeapon(dir):
	# print(Vector3(rad2deg(dir.x), rad2deg(dir.y), rad2deg(dir.z)))
	# add_central_force(Vector3(rad2deg(dir.x), rad2deg(dir.y), rad2deg(dir.z)))
	print(dir)
	dir = Vector3(sin(deg2rad(dir.x)) * 10, sin(deg2rad(dir.y + 30)) * 10, -cos(deg2rad(dir.x)) * 10)
	# #dir = Vector3(0, 0, 1000)
	# print(dir)
	apply_central_impulse(dir)
	$AnimationTree.active = false
