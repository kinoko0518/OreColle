extends Node
class_name Player

signal card_summoned(summoned_card:Card)
signal card_returned(returned_card:Card)

var current_deck:Deck
@export var status:Dictionary[String, float] = {"HP":100}

@onready var field     = $VBoxContainer3/FieldScroll/Field
@onready var hand      = $Hand
@onready var deck_list = $VBoxContainer3/ScrollContainer/VBoxContainer

var holding_card:Card
var cards:Array[CardData]
var card_height = 400

func get_fields() -> Array[Card]:
	var res:Array[Card] = []
	for card in field.get_children().filter(func(target): if target is Card: return target): res.append(card)
	return res

func get_hands() -> Array[Card]:
	var res:Array[Card] = []
	for card in hand.get_children().filter(func(target): if target is Card: return target): res.append(card)
	return res

func get_difense():
	var sum:float = 0
	for card in get_fields():
		if "DFS" in card.status.keys(): sum += card.status["DFS"]
	return sum

func get_hp():
	return status["HP"] + get_difense()

func to_hand(card:Card):
	card.reparent(hand)
	card.card.flip_h = true
	card.card.flip_v = true
	card.custom_minimum_size.y = card_height
	card.position = hand.size
	card.change_ui_visible(false)

func to_field(card:Card):
	card.reparent(field)
	card.card.flip_h = false
	card.card.flip_v = false
	card.change_ui_visible(true)
	card_summoned.emit(card)

func drag_card(card:Card):
	card.reparent(self, true)
	holding_card = card
	card.card.flip_h = false
	card.card.flip_v = false
	card.rotation = 0
	card_returned.emit(card)

func reset_game():
	for child in field.get_children(): child.queue_free()
	for child in hand.get_children():  child.queue_free()

func load_deck(deck:Deck):
	reset_game()
	for path in deck.card_path: cards.append(ResourceLoader.load(path))
	for card in cards:
		hand.add_child(Card.create_from_card_data(card))
	for card in get_hands():
		to_hand(card)
		card.clicked.connect(func(clicked_card): drag_card(clicked_card))

signal deck_selected(selected_deck:Deck)
func select_deck():
	deck_list.visible = true
	for child in deck_list.get_children():
		if child is Button: child.queue_free()
	for deck_filename in DirAccess.get_files_at("user://Decks"):
		var button  = Button.new()
		button.text = deck_filename.rsplit(".")[0]
		button.button_down.connect(func(): deck_selected.emit(ResourceLoader.load("user://Decks/"+deck_filename)))
		deck_list.add_child(button)
	var selected_deck:Deck = await deck_selected
	current_deck = selected_deck
	load_deck(selected_deck)
	deck_list.visible= false

func _ready():
	$VBoxContainer3/VBoxContainer2/Button.button_down.connect(select_deck)
	$VBoxContainer3/VBoxContainer2/Button2.button_down.connect(func(): load_deck(current_deck))

func _process(_delta):
	if holding_card:
		holding_card.position = get_window().get_mouse_position() - holding_card.size / 2
		if Input.is_action_just_pressed("summon_return"):
			var mouse_pos = get_window().get_mouse_position()
			var fieldllocal_mousepos = (mouse_pos - Vector2(get_window().size) / 2) - field.get_parent().position + Vector2(0, card_height / 2)
			var field_minus = -field.size / 2
			var field_plus = field.size / 2
			var is_field_x_inside = field_minus.x <= fieldllocal_mousepos.x and fieldllocal_mousepos.x <= field_plus.x
			var is_field_y_inside = field_minus.y <= fieldllocal_mousepos.y and fieldllocal_mousepos.y <= field_plus.y
			var hand_localpos = mouse_pos - (hand.position + hand.size)
			var hand_distance = sqrt(pow(hand_localpos.x, 2) + pow(hand_localpos.y, 2))
			# 上の処理ほど優先度が高い
			# 手札に戻す処理
			if hand_distance <= get_window().size.x * (350.0 / 1152.0):
				to_hand(holding_card)
			# フィールドに召喚する処理
			elif  is_field_x_inside and is_field_y_inside:
				to_field(holding_card)
			holding_card = null
