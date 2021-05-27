extends Area
enum teams {ATTACKER, DEFENDER, ALL}
export(teams) var spawing_area = teams.ALL
var occupied : bool = false

func _ready() -> void:
	GlobalMapInformation.register_spawn(self)


func _on_spawing_area_body_entered(body):
	if body.is_in_group("hitable"):
		occupied = true


func _on_spawing_area_body_exited(body):
	if body.is_in_group("hitable"):
		occupied = true
