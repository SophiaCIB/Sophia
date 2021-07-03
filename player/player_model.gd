extends KinematicBody

var last_action: Dictionary = {}
var action_log: Array = []

#movement
var debug_console_opened: bool = false
const GRAVITY = -40
var vel = Vector3()
const MAX_SPEED = 12
const JUMP_SPEED = 15
const ACCEL = 4.5
var dir = Vector3()
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40

# Player Stats
var health: float = 100
var dead: bool = false
var team: int
var stats: Dictionary = {
	'health': 100,
	'dead': false,
	'team': 0,
	'money': 0,
	'kills': 0,
	'assists': 0,
	'deaths': 0,
	'points': 0,
	'headshot_percentage': 0,
	'blinded_enemies': 0,
	'grenade_damage': 0,
	'damage': 0,
}

# Player Config
var MOUSE_SENSITIVITY: float = 0.05

export var camera_path: NodePath
onready var camera = get_node(camera_path)

export var weapon_helper_path: NodePath
onready var weapon_helper: Node = get_node(weapon_helper_path)

export var rotation_helper_path: NodePath
onready var rotation_helper: Node = get_node(rotation_helper_path)

export var hud_path: NodePath
onready var hud: Node = get_node(hud_path)

#signals
signal drop_weapon


func init(player_id: int, team: int):
	self.team = team
	set_network_master(player_id)
	set_name(str(player_id))
	add_to_group("team" + str(team))
	add_to_group("hitable")
	if is_network_master():
		#cannot be changed to camera.make_current() because of init, maybe it has to be moved into _ready()
		$Rotation_Helper/Recoil_Helper/Camera.make_current()
	else:
		$Rotation_Helper/Recoil_Helper/Camera.current = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#hud.health_status_changed(health)
	#signals
	weapon_helper.connect("dropWeapon", self, "forwardDropWeapon")
	weapon_helper.connect("shoot", self, "forwardShoot")


func process_input(delta):
	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	if is_network_master():
		var input_movement_vector = Vector2()
		if Input.is_action_just_released("open_debug_console"):
			debug_console_opened = true

		if ! debug_console_opened:
			if Input.is_action_pressed("movement_forward"):
				input_movement_vector.y += 1
			if Input.is_action_pressed("movement_backward"):
				input_movement_vector.y -= 1
			if Input.is_action_pressed("movement_left"):
				input_movement_vector.x -= 1
			if Input.is_action_pressed("movement_right"):
				input_movement_vector.x += 1
			if (
				Input.is_action_just_pressed("weapon_drop")
				&& weapon_helper.handedWeapon.droppable == true
			):
				var weapon = load("res://weapons/sci-fi-gun/SciFiGun.tscn").instance()
				var pos = rotation_helper.get_global_transform()
				var dir: Vector2 = Vector2(
					-self.rotation_degrees.y, rotation_helper.rotation_degrees.x
				)
				last_action["weapon_drop_pos"] = pos
				last_action["weapon_drop_dir"] = dir
				emit_signal("drop_weapon", weapon, pos, dir)
			if Input.is_action_just_pressed('ui_leaderboard'):
				hud.set_leaderboard_visibility(true)
			if Input.is_action_just_released('ui_leaderboard'):
				hud.set_leaderboard_visibility(false)

			# Jumping
			if is_on_floor():
				if Input.is_action_just_pressed("movement_jump"):
					vel.y = JUMP_SPEED

		input_movement_vector = input_movement_vector.normalized()

		# Basis vectors are already normalized.
		dir += -cam_xform.basis.z * input_movement_vector.y
		dir += cam_xform.basis.x * input_movement_vector.x
		# ----------------------------------

		# Capturing/Freeing the cursor
		if Input.is_action_just_pressed("ui_cancel"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				debug_console_opened = false
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# ----------------------------------
		#rset("puppet_dir", dir)
		#rset("puppet_vel", vel)
		#last_action[GameState.tick]["dir"] = dir
		#last_action[GameState.tick]["vel"] = vel


func process_movement(delta):
	if is_network_master():
		dir.y = 0
		dir = dir.normalized()

		vel.y += delta * GRAVITY

		var hvel = vel
		hvel.y = 0

		var target = dir
		target *= MAX_SPEED

		var accel
		if dir.dot(hvel) > 0:
			accel = ACCEL
		else:
			accel = DEACCEL

		hvel = hvel.linear_interpolate(target, accel * delta)
		vel.x = hvel.x
		vel.z = hvel.z
		vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
		#rset("puppet_pos", global_transform.origin)
		last_action["pos"] = global_transform.origin
	else:
		if not last_action.get("pos") == null:
			global_transform.origin = last_action["pos"]
		else:
			global_transform.origin = Vector3(0, 0, 0)


func _input(event):
	if (
		event is InputEventMouseMotion
		and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
		and is_network_master()
	):
		#rpc_unreliable("rotate_on_mouse_input", event.relative.x, event.relative.y)
		rotate_on_mouse_input(event.relative.x, event.relative.y)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED && is_network_master():
		if Input.is_action_pressed("weapon_shoot"):
			last_action["weapon_shoot"] = true
			weapon_helper.shoot()
			#weapon_helper.rpc_unreliable('shoot')
		else:
			last_action.erase('weapon_shoot')
		if Input.is_action_pressed("weapon_reload"):
			weapon_helper.weapon_reload()
			last_action["weapon_reload"] = true
			#weapon_helper.rpc_unreliable('reload')
		else:
			last_action.erase('weapon_reload')
		if ! Input.is_action_pressed("weapon_shoot"):
			#weapon_helper.decrease_latest_recoil()
			#rpc_unreliable('weapon_helper.decrease_latest_recoil')
			pass
	elif not is_network_master():
		if not last_action.get("weapon_shoot") == null:
			weapon_helper.shoot()
			#weapon_helper.rpc_unreliable('shoot')
		if not last_action.get("weapon_reload") == null:
			weapon_helper.weapon_reload()
			#weapon_helper.rpc_unreliable('reload')
		if last_action.get("decrease_latest_recoil") == null:
			#weapon_helper.decrease_latest_recoil()
			#rpc_unreliable('weapon_helper.decrease_latest_recoil')
			pass


func rotate_on_mouse_input(event_x, event_y):
	if is_network_master():
		rotation_helper.rotate_x(deg2rad(event_y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event_x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -89.99, 89.99)
		rotation_helper.rotation_degrees = camera_rot
		#rset('puppet_rot_y', self.rotation_degrees)
		#rset('puppet_rot_x', camera_rot)
		last_action["rotation_rotation_degrees"] = self.rotation_degrees
		last_action["rotation_rotation_camera_rot"] = camera_rot
	else:
		self.rotation_degrees = last_action["rotation_rotation_degrees"]
		rotation_helper.rotation_degrees = last_action["rotation_rotation_camera_rot"]


func forwardDropWeapon(weapon, pos, dir) -> void:
	emit_signal("dropWeapon", weapon, pos, dir)


func forwardShoot(pos, dir):
	emit_signal("shoot", pos, dir)


remote func hit(damage: float) -> void:
	if multiplayer.get_rpc_sender_id() == 1:
		health -= damage
		if health <= 0:
			dead = true
			health = 0
		print("i have been hit", health)

remote func spawn() -> void:
	if multiplayer.get_rpc_sender_id() == 1:
		translation = GlobalMapInformation.get_player_spawn(self)
		dead = false

#remote func update_action(action : Dictionary) -> void:
#	if multiplayer.get_rpc_sender_id() == 1:
#		last_action = action


func server_confirmation_recieved(action: Dictionary):
	# while action_log.size() > 0 and action_log[0].get('tick') > action.get(['tick']):
	# 	action_log.remove(0)
	# if action_log[0].get('tick') == action.get(['tick']):
	# 	if not action_log[0].hash() == action.hash():
	# 		pass
	pass


func _physics_process(delta: float) -> void:
	process_input(delta)
	process_movement(delta)
	if is_network_master():
		last_action['tick'] = GameState.tick
		action_log.append(last_action)
		print(last_action)
		ServerState.rpc_unreliable_id(1, 'update_action', last_action)
