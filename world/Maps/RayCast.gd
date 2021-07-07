extends RayCast


func _process(delta):
	var arr : Array
	while is_colliding():
		print(get_collider())
		arr.append(get_collision_point())
		add_exception(get_collider())
		force_raycast_update()
	if not arr == []:
		print(arr)
	clear_exceptions()