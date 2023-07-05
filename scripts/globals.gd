extends Node

var enemies = ["skeleton", "skeleton_mage"]
var bosses = [load("res://entities/garoff.tscn")]
var trap_types = ["trap_pressure_plate"]
var player

var skeleton_scene = load("res://entities/skeleton.tscn")
var skeleton_mage_scene = load("res://entities/skeleton_mage.tscn")
var rat_scene = load("res://entities/rat.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
