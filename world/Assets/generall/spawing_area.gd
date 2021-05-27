extends Area
enum teams {ATTACKER, DEFENDER, ALL}
export(teams) var spawing_area = teams.ALL
var occupied : bool = false

func _ready() -> void:
	GlobalMapInformation.register_spawn(self)
