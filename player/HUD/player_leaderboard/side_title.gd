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

export var money_path : NodePath 
onready var money_node = get_node(money_path)

export var kd_path : NodePath 
onready var kd_node = get_node(kd_path)

export var kills_path : NodePath 
onready var kills_node = get_node(kills_path)

export var assists_path : NodePath 
onready var assists_node = get_node(assists_path)

export var deaths_path : NodePath 
onready var deaths_node = get_node(deaths_path)

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

func set_money(money : int):
	money_node.set_text(str(money))

func set_kd(kd : float):
	kd_node.set_text(str(kd))

func set_kills(kills : int):
	kills_node.set_text(str(kills))

func set_assists(assists : int):
	assists_node.set_text(str(assists))

func set_deaths(deaths : int):
	deaths_node.set_text(str(deaths))

func set_points(points : int):
	points_node.set_text(str(points))

func update_all(stats : Dictionary):
	set_money(stats.get('money'))
	if stats.get('deaths') == 0:
		set_kd(0.0)
	else:	
		set_kd(stats.get('kills') / stats.get('deaths'))
	set_kills(stats.get('kills'))
	set_assists(stats.get('assists'))
	set_deaths(stats.get('deaths'))
	set_points(stats.get('points'))
