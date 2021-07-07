extends Control


const style = "classic"
const alpha = 1
const thickness = 1
const size = 5
const gap = 1 + thickness
#not supported
const outline_enabled = false
const outline = 100
const color =  Color( 0, 1, 0, alpha )
const dot_enabled = false

var left
var right
var up
var down
var dot

func _ready():
	left = $left
	right = $right
	up = $up
	down = $down
	dot = $dot
	setWings()

func setWings():
	#dot visibility
	dot.visible = dot_enabled
	
	#color of crosshair
	left.color = color
	right.color = color
	up.color = color
	down.color = color
	dot.color = color

	#size of crosshair
	left.margin_left *= size 
	right.margin_right *= size
	up.margin_top *= size
	down.margin_bottom *= size

	dot.margin_left *= size 
	dot.margin_right *= size
	dot.margin_top *= size
	dot.margin_bottom *= size

	#thickness
	left.margin_top *= thickness
	left.margin_bottom *= thickness
	right.margin_top *= thickness
	right.margin_bottom *= thickness

	up.margin_right *= thickness
	up.margin_left *= thickness
	down.margin_right *= thickness
	down.margin_left *= thickness

	#gap
	left.margin_right *= gap 
	right.margin_left *= gap
	up.margin_bottom *= gap
	down.margin_top *= gap
	
