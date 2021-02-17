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
	if player.playable:
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
	#between 0 and 1
	var strength_of_penetration : float = 0.5
	
	#ray cast pointed away
	while rayCast.is_colliding():
		hit_objects.append({
			"object": rayCast.get_collider(), 
			"entry_point": rayCast.get_collision_point(),
			"exit_point": null,
			"length": 0,
			"bullet_damage": 0
		})
		rayCast.add_exception(hit_objects.back()["object"])
		rayCast.force_raycast_update()
	rayCast.clear_exceptions()

	#ray cast pointed towards
	hit_objects.invert()
	for n in range(hit_objects.size() - 1):
		var object : Dictionary = hit_objects[n]
		var next : Dictionary = hit_objects[n + 1]
		next["exit_point"] = space_state.intersect_ray(
			object["entry_point"], 
			rayCast.global_transform.origin, 
			excluded_objects
		)["position"]
		excluded_objects.append(next["object"])
		next["length"] = (next["entry_point"] - next["exit_point"]).length()
		#damage calculation
		dmg *= pow(strength_of_penetration, next["length"])
		next["bullet_damage"] = dmg
	hit_objects.invert()

	#debug
	var hud = get_node("../Camera/HUD")
	hud.points = hit_objects

	#hit player
	for object in hit_objects:
		print(object)
		if object["object"].is_in_group("team" + str(1 - player.team)):
			#object.hit()
			print("hit")
		else:
			#addDecal(object["object"])
			# add bullet hole decal
			print("decal")	

func addDecal(collider) -> void:
	var decal = bullet_decal.instance()
	collider.add_child(decal)
	decal.global_transform.origin = rayCast.get_collision_point()
	decal.look_at(rayCast.get_collision_point() + rayCast.get_collision_normal(), Vector3.UP)

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
