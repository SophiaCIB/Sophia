extends Control

var points : Array = [] setget set_points
var map : Node 
var debug_bullet_penetration : bool = true

export var camera_path : NodePath
onready var camera : Node = get_node(camera_path)

export var healt_bar_path : NodePath
onready var health_bar : Node = get_node(healt_bar_path)

#drawing strings
var font = load('res://player/HUD/fonts/standard.tres')

func _draw():
	#draw bullet penetration
	var color = Color(0, 1, 0)
	for point in points:
		#print(points.size())
		if not camera.is_position_behind(point["entry_point"]) || not camera.is_position_behind(point["exit_point"]):
			if not point["exit_point"] == null:
				draw_line(
					camera.unproject_position(point["entry_point"]), 
					camera.unproject_position(point["exit_point"]), 
					color, 
					5)
				draw_string(font, camera.unproject_position(point["entry_point"]), str(point["bullet_damage"]))
			else:
				draw_circle(
					camera.unproject_position(point["entry_point"]),
					5,
					color)
	
	#draw other players tags
	
	for player in GlobalPlayersInformation.other_players:
		var pos = player.translation + Vector3(0, 2, 0)
		if not camera.is_position_behind(pos):
			draw_string(
				font, 
				camera.unproject_position(pos), 
				str(ceil(player.health))
				)


func _process(delta):
	if debug_bullet_penetration:
		update()
	else:
		pass

func health_status_changed(health : float) -> void:
	health_bar.set_text(str(ceil(health)))

func set_points(new_Points : Array) -> void:
	points = new_Points
