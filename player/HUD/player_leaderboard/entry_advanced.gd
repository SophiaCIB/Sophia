tool
extends Control

enum sides {ATTACKER, DEFENDER, PLAYER}

export(sides) var side : int
export var dead : bool

export var panel_path : NodePath 
onready var panel = get_node(panel_path)

export var ping_path : NodePath 
onready var ping_node = get_node(ping_path)

export var player_name_path : NodePath 
onready var player_name_node = get_node(player_name_path)

export var headshot_percentage_path : NodePath 
onready var headshot_percentage_node = get_node(headshot_percentage_path)

export var blinded_enemies_path : NodePath 
onready var blinded_enemies_node = get_node(blinded_enemies_path)

export var grenade_damage_path : NodePath 
onready var grenade_damage_node = get_node(grenade_damage_path)

export var damage_path : NodePath 
onready var damage_node = get_node(damage_path)

export var r2_path : NodePath 
onready var r2_node = get_node(r2_path)

export var points_path : NodePath 
onready var points_node = get_node(points_path)

func _ready() -> void:
	var style = StyleBoxFlat.new()
	if side == sides.ATTACKER:
		style.set_bg_color(Color(0.2, 1, 0, 0.39))
		panel.add_stylebox_override('panel', style)
	if side == sides.DEFENDER:
		style.set_bg_color(Color(0, 0.1, 0.35, 0.75))
		panel.add_stylebox_override('panel', style)
	if side == sides.PLAYER:
		style.set_bg_color(Color(0, 0, 0, 0.38))
		panel.add_stylebox_override('panel', style)

func set_ping(ping : int):
	ping_node.set_text(str(ping))

func set_player_name(player_name : String):
	player_name_node.set_text(player_name)

func set_headshot_percentage(headshot_percentage : float):
	headshot_percentage_node.set_text(str(headshot_percentage))

func set_blinded_enemies(blinded_enemies : int):
	blinded_enemies_node.set_text(str(blinded_enemies))

func set_grenade_damage(grenade_damage : float):
	grenade_damage_node.set_text(str(grenade_damage))

func set_damage(damage : float):
	damage_node.set_text(str(damage))

func set_r2(r2 : float):
	r2_node.set_text(str(r2))

func set_points(points : int):
	points_node.set_text(str(points))

func update_all(stats : Dictionary):
	set_headshot_percentage(stats.get('headshot_percentage'))
	set_blinded_enemies(stats.get('blinded_enemies'))
	set_grenade_damage(stats.get('grenade_damage'))
	set_damage(stats.get('damage'))
	set_points(stats.get('points'))
