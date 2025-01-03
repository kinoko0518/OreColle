extends VBoxContainer
class_name Card

@export_subgroup("Card Info")
@export var card_data:CardData

signal clicked(clicked_card:Card)

var card
var status = HBoxContainer.new()

var is_mouse_inside = false
var status_spinboxes:Dictionary[String, SpinBox]


static func create_from_card_data(_card_data:CardData) -> Card:
	var res = Card.new()
	res.constract_basement()
	res.load_carddata(_card_data)
	return res

func change_ui_visible(value:bool):
	for i in range(status_spinboxes.keys().size()):
		status_spinboxes[status_spinboxes.keys()[i]].visible = value

func add_status(_name:String, value:float):
	var spinbox = SpinBox.new()
	spinbox.value = value
	spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spinbox.allow_greater = true
	status.add_child(spinbox)
	spinbox.prefix = _name + ":"
	status_spinboxes[_name] = spinbox

func constract_basement() -> void:
	mouse_entered.connect(func(): is_mouse_inside = true)
	mouse_exited.connect(func(): is_mouse_inside = false)
	
	card         =       TextureRect.new()
	
	card.expand_mode           = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	card.stretch_mode          = TextureRect.STRETCH_KEEP_ASPECT
	card.custom_minimum_size.y = 400
	
	add_child(card); add_child(status)

func load_carddata(_card_data:CardData):
	card_data = _card_data
	card.texture = card_data.get_texture()
	card.material = card_data.get_material()
	for key in card_data.status.keys():
		add_status(key, card_data.status[key])

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("summon_return") and is_mouse_inside:
		clicked.emit(self)
