extends RigidBody

class_name Weapon

var weapon_id : String = ""
#shots per minute
var rate_of_fire : float = 0
#in currency
var prize : int = 1000
#in bullets
var magazine_capacity : int  = 0
#in bullets
var spare_bullets : int = 0
var bullets_left_in_mag : int = magazine_capacity
#0 automatic, 1 burst, 2 single
var firing_modes = [0, 1, 2]
#in seconds
var reload_time = 2.5
var reloading : bool = false
var track_reloading_time : float = 0
#in percent
var movement_speed : int = 100 
#percent
var kill_award : int = 0
#percent
var base_damage : int = 0
#percent
var armor_penetration : int = 0
#last time a shot was fired
var last_shot : float = 0
var next_shot : bool = true
#knockback Mutliplyer for defaulknockback
var recoil_pattern : PoolVector2Array
var latest_recoil : int = 0
var decrease_latest_recoil : bool = false
var decrese_recoil_steps : Vector2 = Vector2(0.0, 0.0)

export var recoil_helper_path : NodePath
onready var recoil_helper : Node = get_node(recoil_helper_path)
#animationplayer
var animationplayer

# func _init(
# 	weapon_id : String, 
# 	rate_of_fire : float, 
# 	prize : int, 
# 	magazine_capacity : int,
# 	bullets_to_reload : int, 
# 	firing_modes : Array, 
# 	reload_time : float, 
# 	movement_speed : float, 
# 	kill_award : int, 
# 	damage : int, 
# 	armor_penetration : int,
# 	recoilPattern : PoolVector2Array
# 	):
# 	self.weapon_id = weapon_id
# 	self.rate_of_fire = rate_of_fire
# 	self.prize = prize
# 	self.magazine_capacity = magazine_capacity
# 	self.bullets_to_reload = bullets_to_reload
# 	self.bullets_left_in_mag = magazine_capacity
# 	self.firing_modes = firing_modes
# 	self.reload_time = reload_time
# 	self.movement_speed = movement_speed
# 	self.kill_award = kill_award
# 	self.damage = damage
# 	self.armor_penetration = armor_penetration
# 	self.recoilPattern = recoilPattern

func _process(delta) -> void:
	prepareNextShoot(delta)
	checkForFinishedReloading(delta)

func prepareNextShoot(delta) -> void:
	if !next_shot && last_shot < 1/rate_of_fire:
		last_shot += delta
	else:
		last_shot = 0
		next_shot = true

func checkForFinishedReloading(delta) -> void:
	if reloading:
		track_reloading_time += delta
		print(track_reloading_time)
	if track_reloading_time >= reload_time:
		reloading = false
		track_reloading_time = 0

func setAnimation() -> void:
	$Animation_Helper/AnimationTree.set("parameters/shot_animation/active", true)

func dropWeapon(dir) -> void:
	var weaponThrowMultiplyer = 10
	dir = Vector3(sin(deg2rad(dir.x)) * cos(deg2rad(dir.y)), sin(deg2rad(dir.y)), -cos(deg2rad(dir.x)) * cos(deg2rad(dir.y)))
	dir = dir.normalized() * weaponThrowMultiplyer
	apply_central_impulse(dir)
	$Animation_Helper/AnimationTree.active = false

#rückgabetyp möglicherweise falsch
func getBulletTransform() -> Transform2D:
	return $Bullet_Helper.get_global_transform()

func reload() -> void:
	if bullets_left_in_mag == magazine_capacity:
		print("still full")
	elif spare_bullets > 0:
		print("reloading")
		var need_Bullets : int = magazine_capacity - bullets_left_in_mag
		reloading = true
		if spare_bullets >= need_Bullets:
			bullets_left_in_mag = magazine_capacity
			spare_bullets -= need_Bullets
		else:
			bullets_left_in_mag = spare_bullets
			spare_bullets = 0
	else:
		print("no bullets to reload")
	
