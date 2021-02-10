extends AnimationTree

func _ready():
	connect("animation_finished", self, "endAnimation")

func endAnimation():
	print("klappt")