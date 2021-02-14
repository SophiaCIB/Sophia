extends Spatial
export var backSnaper : int = 15
export var linearMultiplyer : int = 2

export var weaponHelperPath : NodePath
onready var weaponHelper : Node = get_node(weaponHelperPath)

func _process(delta):
	knockback(delta)
	pass

#should maybe not be active while shooting?
func knockback(delta) -> void:
	var shooting : int = 1
	if !weaponHelper.handedWeapon.decrease_latest_recoil:
		shooting = 0
	if rotation_degrees.x > 0:
		rotation_degrees.x -= delta * (backSnaper + rotation_degrees.x * linearMultiplyer * shooting)
		if rotation_degrees.x < 0:
			rotation_degrees.x = 0
	if rotation_degrees.y > 0:
		rotation_degrees.y -= delta * (backSnaper + rotation_degrees.y * linearMultiplyer * shooting)
		if rotation_degrees.y < 0:
			rotation_degrees.y = 0
