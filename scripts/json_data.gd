extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var item_data: Dictionary
var ingredient_data: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	item_data = LoadData("res://data/ItemData.json")
	#ingredient_data = LoadData("res://data/IngredientData.json")
	
func LoadData(file_path):
	var json_data
	var file_data = FileAccess.open(file_path, FileAccess.READ)
	var json = JSON.new()
	json_data = json.parse_string(file_data.get_as_text())
	print(str(file_path) + ": " + str(json_data))
	return json_data

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
