extends Control
var points : Array = []
var debug_bullet_penetration : bool = true

export var camera_path : NodePath
onready var camera : Node = get_node(camera_path)

func _draw():
	var color = Color(0, 1, 0)
	for point in points:
		if not point["exit_point"] == null:
			draw_line(
				camera.unproject_position(point["entry_point"]), 
				camera.unproject_position(point["exit_point"]), 
				color, 
				5)
		else:
			draw_circle(
				camera.unproject_position(point["entry_point"]),
				5,
				color)

func _process(delta):
	if debug_bullet_penetration:
		update()
	else:
		pass
