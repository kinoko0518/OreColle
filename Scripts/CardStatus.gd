extends Resource
class_name CardData

enum Rarelity { Common, Sleeve, BossSleeve, BossRare }
@export var default_hp:int
@export var card_texture:CompressedTexture2D
@export var rarelity:Rarelity

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
