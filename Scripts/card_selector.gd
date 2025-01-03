extends HFlowContainer
class_name CardList

signal selected(_card_data:CardData)

var cardlist:Array[CardData]
func load_cardlist() -> Array[CardData]:
	var res:Array[CardData]
	var card_list:PackedStringArray
	if DirAccess.dir_exists_absolute("user://Cards"):
		card_list = DirAccess.get_directories_at("user://Cards")
		for c in card_list:
			res.append(ResourceLoader.load("user://Cards/"+c+"/"+c+".tres"))
	return res

func _ready():
	cardlist = load_cardlist()
	for c in cardlist:
		var card = VBoxContainer.new()
		
		var card_name = Label.new()
		card_name.text = c.name
		card.add_child(card_name)
		
		var card_disp = TextureRect.new()
		card_disp.set_script(preload("res://Scripts/SelectableCard.gd"))
		card_disp.clicked.connect(func(_card_data): selected.emit(_card_data))
		card_disp.custom_minimum_size = Vector2(200, 0)
		card_disp.carddata     = c
		card_disp.expand_mode  = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		card_disp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		card_disp.texture      = ImageTexture.create_from_image(Image.load_from_file(c.texture_path))
		card_disp.material     = c.get_material()
		card.add_child(card_disp)
		
		add_child(card)
