extends Control

@onready var deck_cardlist = $VBoxContainer/ScrollContainer2/HFlowContainer
@onready var add_button = $VBoxContainer/HBoxContainer/Button

var selected:CardData
func select_card() -> CardData:
	var cardlist = CardList.new()
	cardlist.anchor_top = 1
	cardlist.anchor_bottom = 2
	cardlist.anchor_left = 0
	cardlist.anchor_right = 1
	add_child(cardlist)
	create_tween().tween_property(self, "anchor_top", -1, 1).set_trans(Tween.TRANS_QUART)
	create_tween().tween_property(self, "anchor_bottom", 0, 1).set_trans(Tween.TRANS_QUART)
	cardlist.selected.connect(func(_card_data:CardData): selected = _card_data)
	await cardlist.selected
	create_tween().tween_property(self, "anchor_top", 0, 1).set_trans(Tween.TRANS_QUART)
	add_card(selected)
	await create_tween().tween_property(self, "anchor_bottom", 1, 1).set_trans(Tween.TRANS_QUART).finished
	cardlist.queue_free()
	return selected

func add_card(card_data:CardData):
	var vbox = VBoxContainer.new()
	vbox.set_meta("CardData", card_data)
	
	var name_label = Label.new()
	name_label.text = card_data.name
	vbox.add_child(name_label)
	
	var card = TextureRect.new()
	card.texture = card_data.get_texture()
	card.material = card_data.get_material()
	card.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	card.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	card.custom_minimum_size.y = 300
	vbox.add_child(card)
	
	var delete = Button.new()
	delete.text = "カードを削除"
	delete.button_down.connect(func(): vbox.queue_free())
	vbox.add_child(delete)
	
	deck_cardlist.add_child(vbox)

func generate_deckresource() -> Deck:
	var deck = Deck.new()
	deck.deck_name = $VBoxContainer/HBoxContainer/LineEdit.text
	for card in deck_cardlist.get_children():
		var card_name = (card.get_meta("CardData") as CardData).name
		deck.card_path.append("user://Cards/" + card_name + "/" + card_name + ".tres")
	return deck

signal deck_selected(selected_deck:Deck)
func select_deck():
	$VBoxContainer/ScrollContainer/HBoxContainer2.visible = true
	for button in $VBoxContainer/ScrollContainer/HBoxContainer2.get_children():
		if button is Button: button.queue_free()
	for deck_filename in DirAccess.get_files_at("user://Decks"):
		var button  = Button.new()
		button.text = deck_filename.rsplit(".")[0]
		button.button_down.connect(func(): deck_selected.emit(ResourceLoader.load("user://Decks/"+deck_filename)))
		$VBoxContainer/ScrollContainer/HBoxContainer2.add_child(button)
	var selected_deck = await deck_selected
	$VBoxContainer/ScrollContainer/HBoxContainer2.visible = false
	load_deck(selected_deck)

func load_deck(deck:Deck):
	$VBoxContainer/HBoxContainer/LineEdit.text = deck.deck_name
	for child in $VBoxContainer/ScrollContainer/HBoxContainer2.get_children():
		if child is Button: child.queue_free()
	for card in deck_cardlist.get_children():
		card.queue_free()
	for path in deck.card_path: add_card(ResourceLoader.load(path))

func save_deck(deck:Deck):
	DirAccess.make_dir_recursive_absolute("user://Decks")
	ResourceSaver.save(deck, "user://Decks/" + deck.deck_name + ".tres")

func _ready():
	$VBoxContainer/HBoxContainer/Button2.button_down.connect(
		func():
			save_deck(generate_deckresource())
	)
	$VBoxContainer/HBoxContainer/Button3.button_down.connect(select_deck)
	while true:
		await add_button.button_down
		var _selected = await select_card()
