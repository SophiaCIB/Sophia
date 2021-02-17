extends Spatial
export var backSnaper : int = 15
export var linearMultiplyer : int = 2

export var weaponHelperPath : NodePath
onready var weaponHelper : Node = get_node(weaponHelperPath)

export var rayCastPath : NodePath
onready var rayCast : Node = get_node(rayCastPath)

func _process(delta):
	knockback(delta)
	pass

#should maybe not be active while shooting?
func knockback(delta) -> void:
	var shooting : int = 1
	var backAngle : Vector2
	if !weaponHelper.handedWeapon.decrease_latest_recoil:
		shooting = 0
	if rotation_degrees.x > 0:
		#backAngle.x = -delta * (backSnaper + rotation_degrees.x * linearMultiplyer * shooting)
		rotation_degrees.x -= delta * (backSnaper + rotation_degrees.x * linearMultiplyer * shooting)
		rayCast.rotation_degrees.x -= delta * (rayCast.rotation_degrees.x * shooting)
		if rotation_degrees.x < 0:
			rotation_degrees.x = 0
			rayCast.rotation_degrees.x = 0
	if rotation_degrees.y > 0:
		#backAngle.y = -delta * (backSnaper + rotation_degrees.y * linearMultiplyer * shooting)
		rotation_degrees.y -= delta * (backSnaper + rotation_degrees.y * linearMultiplyer * shooting)
		rayCast.rotation_degrees.y -= delta * (rayCast.rotation_degrees.y * shooting)
		if rotation_degrees.y < 0:
			rotation_degrees.y = 0
			rayCast.rotation_degrees.y = 0
