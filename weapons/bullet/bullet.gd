extends KinematicBody
var vel 

func shoot(vel):
	self.vel = vel

func _process(delta):
	move_and_slide(vel * delta)
