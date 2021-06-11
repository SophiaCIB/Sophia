extends KinematicBody

var action_log : Dictionary = {}

#movement
var skip : bool = false
const GRAVITY = -40
var vel = Vector3()
# puppet var puppet_vel = Vector3()
const MAX_SPEED = 12
const JUMP_SPEED = 15
const ACCEL = 4.5
var dir = Vector3()
# puppet var puppet_dir = Vector3()
# puppet var puppet_pos = Vector3()
# puppet var puppet_rot_x = Vector3()
# puppet var puppet_rot_y = Vector3()
const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

# Player Stats
var health : float = 100
var dead : bool = false
var team : int


# Player Config
var MOUSE_SENSITIVITY : float = 0.05

export var camera_path : NodePath 
onready var camera = get_node(camera_path)

export var weapon_helper_path : NodePath
onready var weapon_helper : Node = get_node(weapon_helper_path)

export var rotation_helper_path : NodePath
onready var rotation_helper : Node = get_node(rotation_helper_path)

export var hud_path : NodePath
onready var hud : Node = get_node(hud_path)

#signals
signal drop_weapon



func init(player_id : int, team : int):
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
			skip = true
		
		if !skip:
			if Input.is_action_pressed("movement_forward"):
				input_movement_vector.y += 1
			if Input.is_action_pressed("movement_backward"):
				input_movement_vector.y -= 1
			if Input.is_action_pressed("movement_left"):
				input_movement_vector.x -= 1
			if Input.is_action_pressed("movement_right"):
				input_movement_vector.x += 1
			if Input.is_action_just_pressed("weapon_drop") && weapon_helper.handedWeapon.droppable == true:
				var weapon = load("res://weapons/sci-fi-gun/SciFiGun.tscn").instance()
				var pos = rotation_helper.get_global_transform()
				var dir : Vector2 = Vector2(-self.rotation_degrees.y, rotation_helper.rotation_degrees.x)
				action_log["weapon_drop_pos"] = pos
				action_log["weapon_drop_dir"] = dir
				emit_signal("drop_weapon", weapon, pos, dir)

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
				skip = false
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# ----------------------------------
		#rset("puppet_dir", dir)
		#rset("puppet_vel", vel)
		#action_log[GameState.tick]["dir"] = dir
		#action_log[GameState.tick]["vel"] = vel
		

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
		action_log["pos"] = global_transform.origin
	else:
		if not action_log.get("pos") == null:
			global_transform.origin = action_log["pos"]
		else:
			global_transform.origin = Vector3(0,0,0)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and is_network_master():
		#rpc_unreliable("rotate_on_mouse_input", event.relative.x, event.relative.y)
		rotate_on_mouse_input(event.relative.x, event.relative.y)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED && is_network_master():
		if Input.is_action_pressed("weapon_shoot"):
			action_log["weapon_shoot"] = true
			weapon_helper.shoot()
			#weapon_helper.rpc_unreliable('shoot')
		else:
			action_log.erase('weapon_shoot')
		if Input.is_action_pressed("weapon_reload"):
			weapon_helper.weapon_reload()
			action_log["weapon_reload"] = true			
			#weapon_helper.rpc_unreliable('reload')
		else:
			action_log.erase('weapon_reload')
		if !Input.is_action_pressed("weapon_shoot"):
			#weapon_helper.decrease_latest_recoil()
			#rpc_unreliable('weapon_helper.decrease_latest_recoil')
			pass
	elif not is_network_master():
		if not action_log.get("weapon_shoot") == null:
			weapon_helper.shoot()
			#weapon_helper.rpc_unreliable('shoot')
		if not action_log.get("weapon_reload") == null:
			weapon_helper.weapon_reload()		
			#weapon_helper.rpc_unreliable('reload')
		if action_log.get("decrease_latest_recoil") == null:
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
		action_log["rotation_rotation_degrees"] = self.rotation_degrees
		action_log["rotation_rotation_camera_rot"] = camera_rot
	else:
		self.rotation_degrees = action_log["rotation_rotation_degrees"]
		rotation_helper.rotation_degrees = action_log["rotation_rotation_camera_rot"]

func forwardDropWeapon(weapon, pos, dir):
	emit_signal("dropWeapon", weapon, pos, dir)

func forwardShoot(pos, dir):
	emit_signal("shoot", pos, dir)

remote func hit(damage : float) -> void:
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

remote func update_action(action : Dictionary):
	if multiplayer.get_rpc_sender_id() == 1:
		action_log = action

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	if is_network_master():
		action_log['tick'] = GameState.tick
		ServerState.rpc_unreliable_id(1, 'update_action', action_log)
