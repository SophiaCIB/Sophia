extends Spatial
var mainWeapon : Node
var secondaryWeapon : Node
var knife : Node
var handedWeapon : Node

onready var bullet_decal = preload("res://weapons/bullet/bullet_impact.tscn")

var baseKnockback : Vector2 = Vector2(2, 0)
export var playerPath : NodePath
onready var player : Node = get_node(playerPath)

export var rotationHelperPath : NodePath
onready var rotationHelper : Node = get_node(rotationHelperPath)

export var rayCastPath : NodePath
onready var rayCast : Node = get_node(rayCastPath)

export var recoilHelperPath : NodePath
onready var recoilHelper : Node = get_node(recoilHelperPath)

#signals
signal dropWeapon
signal shoot

func _ready() -> void:
	var scifigun = load("res://weapons/sci-fi-gun/SciFiGun.tscn").instance()
	setMainWeapon(scifigun)

func _process(delta) -> void:
	if player.is_network_master():
		shoot()
	decreaseLatestRecoil()

func setMainWeapon(weapon) -> void:
	add_child(weapon)
	mainWeapon = get_node(weapon.name)
	handedWeapon = mainWeapon

func setSecondaryWeapon(weapon) -> void:
	add_child(weapon)
	secondaryWeapon = get_node(weapon.name)

func dropHandedWeapon() -> void:
	#handedWeapon.queue_free()
	#has to be changed to generic weapon
	var weapon = load("res://weapons/sci-fi-gun/SciFiGun.tscn").instance()
	#var weapon = handedWeapon.duplicate()
	var pos = rotationHelper.get_global_transform()
	var dir = Vector2(-player.rotation_degrees.y, rotationHelper.rotation_degrees.x)
	emit_signal("dropWeapon", weapon, pos, dir) 

func recoil() -> void:
	#should be between 0 and 1
	var ghostMultiplier : float = 0.5
	recoilHelper.rotation_degrees.x += baseKnockback.x + handedWeapon.recoil_pattern[handedWeapon.latest_recoil].y * ghostMultiplier
	recoilHelper.rotation_degrees.y += baseKnockback.y + handedWeapon.recoil_pattern[handedWeapon.latest_recoil].x * ghostMultiplier
	rayCast.rotation_degrees.x += handedWeapon.recoil_pattern[handedWeapon.latest_recoil].y * (1 - ghostMultiplier)
	rayCast.rotation_degrees.y += handedWeapon.recoil_pattern[handedWeapon.latest_recoil].x * (1- ghostMultiplier)
	handedWeapon.latest_recoil += 1

func checkForHit() -> void:
	var dmg : float = handedWeapon.base_damage
	var hit_objects : Array = []
	var excluded_objects : Array = [self]
	var space_state = get_world().direct_space_state
	
	#between exc(0) and exc(1)
	# 1 = good penetration / 0 = weak penetration 
	var weapon_strength_of_penetration : float = handedWeapon.armor_penetration
	
	#between exc(0) and inc[1]
	# 1 = nicely penetratable / 0 = hardly penetratable
	# has to be adjusted to custom material type of hit object
	var object_penetrability : float = 0.5

	var damage_falloff : int = handedWeapon.damage_falloff
	
	#set max shooting distance
	rayCast.cast_to = Vector3(0, 0, -damage_falloff)

	#ray cast pointed away
	while rayCast.is_colliding():
		hit_objects.append({
			"object": rayCast.get_collider(), 
			"entry_point": rayCast.get_collision_point(),
			"entry_point_normal": rayCast.get_collision_normal(),
			"exit_point": null,
			"exit_point_normal": null,
			"length": 0,
			"bullet_damage": 0,
		})
		rayCast.add_exception(hit_objects.back()["object"])
		rayCast.force_raycast_update()
	rayCast.clear_exceptions()

	#ray cast pointed towards
	hit_objects.invert()
	for n in range(hit_objects.size()):
		var object : Dictionary = hit_objects[n]
		var ray : Dictionary = space_state.intersect_ray(
			#object["entry_point"],
			rayCast.global_transform.origin - rayCast.global_transform.basis.z * damage_falloff, 
			rayCast.global_transform.origin, 
			excluded_objects
		)
		object["exit_point"] = ray["position"]
		object["exit_point_normal"] = ray["normal"]
		excluded_objects.append(object["object"])
		object["length"] = (object["entry_point"] - object["exit_point"]).length()
	hit_objects.invert()

	#debug
	var hud = get_node("../Camera/HUD") #has to be node path
	hud.set_points(hit_objects)
	#hud.points = [{"entry_point": rayCast.global_transform.origin + -rayCast.global_transform.basis.z * 100, "exit_point": null}]

	#hit player
	var amount_of_decals : int = 2
	for object in hit_objects:
		#damage calculation
		if not dmg > 0:
			amount_of_decals -= 1
		#print(object) "team" + str(1 - player.team)
		if object["object"].is_in_group("hitable"):
			#object.hit()
			print("hit")
			object["object"].hit(dmg)
		else:
			addDecal(object, amount_of_decals)
		object["bullet_damage"] = dmg
		dmg *= pow(object_penetrability * weapon_strength_of_penetration, object["length"])
			

func addDecal(object : Dictionary, amount_of_decals: int) -> void:
	if amount_of_decals > 0:
		var entry_decal = bullet_decal.instance()
		object["object"].add_child(entry_decal)
		entry_decal.global_transform.origin = object["entry_point"]
		entry_decal.look_at(object["entry_point"] + object["entry_point_normal"], Vector3.UP)
		
		if amount_of_decals > 1:
			var exit_decal = bullet_decal.instance()
			object["object"].add_child(exit_decal)
			exit_decal.global_transform.origin = object["exit_point"]
			exit_decal.look_at(object["exit_point"] + object["exit_point_normal"], Vector3.UP)

func checkForReload() -> bool:
	if handedWeapon.bullets_left_in_mag > 0:
		#remove one bullet out of mag if shot
		handedWeapon.bullets_left_in_mag -= 1
		print(handedWeapon.bullets_left_in_mag, "/", handedWeapon.spare_bullets)
		return false
	else:
		#reload if mag is empty
		handedWeapon.decrease_latest_recoil = true
		handedWeapon.reload()
		print(handedWeapon.bullets_left_in_mag, "/", handedWeapon.spare_bullets)
		return true

func notifyShoot() -> void:
	var pos = handedWeapon.getBulletTransform()
	var dir = Vector2(-player.rotation_degrees.y, rotationHelper.rotation_degrees.x)
	#signal for spawning bullet
	emit_signal("shoot", pos, dir)

func prepareShoot() -> void:
	handedWeapon.next_shot = false
	handedWeapon.last_shot = 0
	handedWeapon.setAnimation()

func decreaseLatestRecoil() -> void:
	if handedWeapon.decrease_latest_recoil && handedWeapon.latest_recoil > 0 && handedWeapon.decrese_recoil_steps == Vector2(0.0, 0.0):
		handedWeapon.decrese_recoil_steps.x = recoilHelper.rotation_degrees.x / handedWeapon.latest_recoil
		handedWeapon.decrese_recoil_steps.y = recoilHelper.rotation_degrees.y / handedWeapon.latest_recoil
		# print("calc new steps")
		# print(handedWeapon.decrese_recoil_steps)
		# print("latest recoil ", handedWeapon.latestRecoil)
	if handedWeapon.decrease_latest_recoil && handedWeapon.latest_recoil > 0 && recoilHelper.rotation_degrees.x <= handedWeapon.decrese_recoil_steps.x * (handedWeapon.latest_recoil - 1) && recoilHelper.rotation_degrees.y <= handedWeapon.decrese_recoil_steps.y * (handedWeapon.latest_recoil - 1):
		handedWeapon.latest_recoil -= 1
		# print("lower latest recoil")
		# print(handedWeapon.latestRecoil)
	
	if handedWeapon.decrease_latest_recoil && recoilHelper.rotation_degrees.x == 0 && recoilHelper.rotation_degrees.y == 0 && handedWeapon.decrese_recoil_steps != Vector2(0.0, 0.0):
		handedWeapon.decrese_recoil_steps = Vector2(0.0, 0.0)
		# print("set back to 0")

func shoot() -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_pressed("weapon_shoot") && handedWeapon.next_shot && !handedWeapon.reloading:
			if checkForReload():
				return
			handedWeapon.decrease_latest_recoil = false
			prepareShoot()
			notifyShoot()
			checkForHit()
			recoil()
		elif Input.is_action_pressed("weapon_reload") && !handedWeapon.reloading:
			handedWeapon.reload()
		
		if !Input.is_action_pressed("weapon_shoot"):
			handedWeapon.decrease_latest_recoil = true
