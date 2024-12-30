extends VBoxContainer
class_name Card

enum Rarelity { Common, Sleeve, BossSleeve, BossRare }
@export_subgroup("Card Info")
@export var cards_texture:CompressedTexture2D = preload("res://Cards/BitFish.png"):
	set(value):
		if not Engine.is_editor_hint(): await ready
		card.texture = value
		cards_texture = value
@export var rarelity:Rarelity:
	set(value):
		if not Engine.is_editor_hint(): await ready
		if value == Rarelity.Common:
			card.material.set_shader_parameter("background_tex", preload("res://Backgrounds/normal.png"))
			card.material.set_shader_parameter("colour", Color("373737"))
		elif value == Rarelity.Sleeve:
			card.material.set_shader_parameter("background_tex", preload("res://Backgrounds/rame.jpg"))
			card.material.set_shader_parameter("colour", Color("ffffff"))
		elif value == Rarelity.BossSleeve:
			card.material.set_shader_parameter("background_tex", preload("res://Backgrounds/rame.jpg"))
			card.material.set_shader_parameter("colour", Color("ffa0ea"))
		elif value == Rarelity.BossRare:
			card.material.set_shader_parameter("background_tex", preload("res://Backgrounds/rame.jpg"))
			card.material.set_shader_parameter("colour", Color("ff007c"))
		rarelity = value
@export var max_hp:int = 128:
	set(value):
		if not Engine.is_editor_hint(): await ready
		hp_spinbox.max_value = value
		hp_spinbox.suffix = "/" + str(max_hp)
		max_hp = value

@export_subgroup("Card Status")
@export var belongment:Pos

enum Pos { Hand, Field, Graveyard }
var card:TextureRect
var hp_spinbox:SpinBox
var is_mouse_inside = false

@onready var hand  = %Hand
@onready var field = %Field


func get_card_height():
	return (%FieldScroll.anchor_bottom - %FieldScroll.anchor_top) * get_window().size.y

func apply_belongment(pos):
	print(pos, " : ", Input.is_action_just_pressed("summon_return"))
	if pos == Pos.Hand:
		reparent(hand)
		hp_spinbox.visible = false
		card.flip_v   = true
		card.flip_h   = true
		self.position = hand.size
	if pos == Pos.Field:
		reparent(field)
		rotation    = 0
		hp_spinbox.visible = true
		card.flip_v = false
		card.flip_h = false
	belongment = pos

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("summon_return") and is_mouse_inside:
		if belongment ==  Pos.Hand:
			apply_belongment(Pos.Field)
		elif belongment == Pos.Field:
			apply_belongment(Pos.Hand)

func constract() -> void:
	card = TextureRect.new()
	card.material = preload("res://card.tres").duplicate()
	card.texture = cards_texture
	card.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	card.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(card)
	
	hp_spinbox = SpinBox.new()
	hp_spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_spinbox.max_value = max_hp
	hp_spinbox.value = max_hp
	hp_spinbox.allow_greater = true
	hp_spinbox.suffix = "/ " + str(max_hp)
	add_child(hp_spinbox)
	
	custom_minimum_size.y = get_card_height()
	apply_belongment(self.belongment)

func _ready() -> void:
	mouse_entered.connect(func(): is_mouse_inside = true)
	mouse_exited.connect(func(): is_mouse_inside = false)
	constract()
