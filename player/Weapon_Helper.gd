extends Spatial
var mainWeapon
var secondaryWeapon
var knife
var handedWeapon

func _ready():
	var scifigun = load("res://weapons/sci-fi-gun/SciFiGun.tscn").instance()
	setMainWeapon(scifigun)
	print(scifigun)

func setMainWeapon(weapon):
	add_child(weapon)
	mainWeapon = get_node(weapon.name)
	handedWeapon = mainWeapon

func dropHandedWeapon():
	#handedWeapon.queue_free()
	var scifigun = load("res://weapons/sci-fi-gun/SciFiGun.tscn").instance()
	var map = get_tree().get_root().get_tree().get_root().get_node("Map")

	map.add_child(scifigun)
	var droppedWeapon = map.get_node(scifigun.name)
	droppedWeapon.set_transform(self.get_global_transform())
	print(droppedWeapon.get_global_transform())
	droppedWeapon.dropWeapon(Vector3(-get_parent().get_parent().rotation_degrees.y, get_parent().rotation_degrees.x, 0))
	#droppedWeapon.dropWeapon(get_parent().global_transform)

func setSecondaryWeapon(weapon):
	add_child(weapon)
	secondaryWeapon = get_node(weapon.name)

func _input(event):
	if Input.is_action_pressed("weapon_shoot") && handedWeapon.next_shot:
		handedWeapon.next_shot = false
		handedWeapon.last_shot = 0
		handedWeapon.setAnimation()


