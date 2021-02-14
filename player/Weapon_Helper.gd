extends Spatial
var mainWeapon : Node
var secondaryWeapon : Node
var knife : Node
var handedWeapon : Node

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

func dropHandedWeapon() -> void:
	#handedWeapon.queue_free()
	#has to be changed to generic weapon
	var weapon = load("res://weapons/sci-fi-gun/SciFiGun.tscn").instance()
	#var weapon = handedWeapon.duplicate()
	var pos = rotationHelper.get_global_transform()
	var dir = Vector2(-player.rotation_degrees.y, rotationHelper.rotation_degrees.x)
	emit_signal("dropWeapon", weapon, pos, dir) 

func setSecondaryWeapon(weapon) -> void:
	add_child(weapon)
	secondaryWeapon = get_node(weapon.name)

func recoil() -> void:
	recoilHelper.rotation_degrees.x += baseKnockback.x + handedWeapon.recoil_pattern[handedWeapon.latest_recoil].y / 2 
	recoilHelper.rotation_degrees.y += baseKnockback.y + handedWeapon.recoil_pattern[handedWeapon.latest_recoil].x / 2
	handedWeapon.latest_recoil += 1

func checkForHit() -> void:
	if rayCast.is_colliding():
		var collider = rayCast.get_collider()
		if collider.is_in_group("team" + str(1 - player.team)):
			collider.queue_free()

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
		#position and rotation of Bullet Exit
		notifyShoot()
		#knockback
		recoil()
		#print(recoilHelper.rotation_degrees.x)
		#print(clamp(rotationHelper.rotation_degrees.x + recoilHelper.rotation_degrees.x, -90, 90))
		checkForHit()
	elif Input.is_action_pressed("weapon_reload") && !handedWeapon.reloading:
		handedWeapon.reload()
	
	if !Input.is_action_pressed("weapon_shoot"):
		handedWeapon.decrease_latest_recoil = true
