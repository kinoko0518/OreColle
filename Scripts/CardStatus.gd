extends Resource
class_name CardData

enum Rarelity { Common, Sleeve, BossSleeve, BossRare }

@export_subgroup("Card Info")
@export var name:String
@export var texture_path:String
@export_subgroup("Card Status")
@export var rarelity:Rarelity
@export var status:Dictionary[String, float]
@export_subgroup("Flags")
@export var is_infinity:bool

func get_material():
	var material = preload("res://card.tres").duplicate()
	if rarelity == Rarelity.Common:
		material.set_shader_parameter("background_tex", preload("res://Backgrounds/normal.png"))
		material.set_shader_parameter("colour", Color("373737"))
	elif rarelity == Rarelity.Sleeve:
		material.set_shader_parameter("background_tex", preload("res://Backgrounds/rame.jpg"))
		material.set_shader_parameter("colour", Color("ffffff"))
	elif rarelity == Rarelity.BossSleeve:
		material.set_shader_parameter("background_tex", preload("res://Backgrounds/rame.jpg"))
		material.set_shader_parameter("colour", Color("ffa0ea"))
	elif rarelity == Rarelity.BossRare:
		material.set_shader_parameter("background_tex", preload("res://Backgrounds/rame.jpg"))
		material.set_shader_parameter("colour", Color("ff007c"))
	return material

func get_texture() -> ImageTexture:
	return ImageTexture.create_from_image(Image.load_from_file(texture_path))
