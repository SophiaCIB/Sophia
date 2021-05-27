extends KinematicBody
#movement
const GRAVITY = -40
var vel = Vector3()
const MAX_SPEED = 12
const JUMP_SPEED = 15
const ACCEL = 4.5
var dir = Vector3()
const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

# Player Stats
var playable : bool = false
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
signal dropWeapon
signal shoot



func init(playable : bool, team : int):
	self.playable = playable
	self.team = team
	add_to_group("team" + str(team))
	add_to_group("hitable")
	if playable:
		#cannot be changed to camera.make_current() because of init, maybe it has to be moved into _ready()
		$Rotation_Helper/Recoil_Helper/Camera.make_current()
	else:
		$Rotation_Helper/Recoil_Helper/Camera.current = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hud.health_status_changed(health)
	#signals
	weapon_helper.connect("dropWeapon", self, "forwardDropWeapon")
	weapon_helper.connect("shoot", self, "forwardShoot")

func _physics_process(delta):
	if 	playable:
		process_input(delta)
		process_movement(delta)

func process_input(delta):
	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
	if Input.is_action_just_pressed("weapon_drop"):
		weapon_helper.dropHandedWeapon()

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

func process_movement(delta):
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

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -89.99, 89.99)
		rotation_helper.rotation_degrees = camera_rot

func forwardDropWeapon(weapon, pos, dir):
	emit_signal("dropWeapon", weapon, pos, dir)

func forwardShoot(pos, dir):
	emit_signal("shoot", pos, dir)

func hit(damage : float) -> void:
	health -= damage
	if health <= 0:
		dead = true
		health = 0


func spawn() -> void:
	translation = GlobalMapInformation.get_player_spawn(self)
	dead = false
