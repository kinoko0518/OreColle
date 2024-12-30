extends VBoxContainer
class_name Card

@export_subgroup("Card Info")
@export var card_data:CardData

@export_subgroup("Card Status")
@export var belongment:Pos

enum Pos { Hand, Field, Graveyard }
var card:TextureRect
var is_mouse_inside = false
var status_spinboxes:Dictionary[String, SpinBox]

@onready var hand  = %Hand
@onready var field = %Field

func change_ui_visible(value:bool):
	for i in range(status_spinboxes.keys().size()):
		status_spinboxes[status_spinboxes.keys()[i]].visible = value

func add_status(name:String):
	var spinbox = SpinBox.new()
	spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spinbox.allow_greater = true
	add_child(spinbox)
	spinbox.prefix = name + ":"
	status_spinboxes[name] = spinbox

func get_card_height():
	return (%FieldScroll.anchor_bottom - %FieldScroll.anchor_top) * get_window().size.y

func apply_belongment(pos):
	print(pos, " : ", Input.is_action_just_pressed("summon_return"))
	if pos == Pos.Hand:
		reparent(hand)
		card.flip_v   = true
		card.flip_h   = true
		change_ui_visible(false)
		self.position = hand.size
	if pos == Pos.Field:
		reparent(field)
		rotation    = 0
		card.flip_v = false
		card.flip_h = false
		change_ui_visible(true)
	belongment = pos

func load_carddata(carddata:CardData):
	card.texture = carddata.card_texture
	card.material = carddata.get_material()
	status_spinboxes["HP"].max_value = carddata.default_hp
	status_spinboxes["HP"].value = carddata.default_hp

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("summon_return") and is_mouse_inside:
		if belongment ==  Pos.Hand:
			apply_belongment(Pos.Field)
		elif belongment == Pos.Field:
			apply_belongment(Pos.Hand)

func constract() -> void:
	card = TextureRect.new()
	card.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	card.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(card)
	add_status("HP")
	add_status("攻撃力")
	add_status("防御力")
	custom_minimum_size.y = get_card_height()
	apply_belongment(self.belongment)
	load_carddata(card_data)

func _ready() -> void:
	mouse_entered.connect(func(): is_mouse_inside = true)
	mouse_exited.connect(func(): is_mouse_inside = false)
	constract()
