extends Control

var editing_card = CardData.new()
var template_stats:Array[HBoxContainer]

@onready var     card_template = $VBoxContainer/HBoxContainer/OptionButton
@onready var       name_editor = $VBoxContainer/HBoxContainer3/Name
@onready var      card_preview = $VBoxContainer2/TextureRect
@onready var   rarelity_select = $VBoxContainer/HBoxContainer2/OptionButton
@onready var status_add_button = $VBoxContainer/Button
@onready var       status_list = $VBoxContainer/Status
@onready var      load_texture = $VBoxContainer2/Button

@onready var       save_button = $HBoxContainer/Save
@onready var debug_save_button = $HBoxContainer/SaveDebug
@onready var       load_button = $HBoxContainer/Load

func on_rarelity_changed(item_index:int):
	if   item_index == 0:
		editing_card.rarelity = CardData.Rarelity.Common
	elif item_index == 1:
		editing_card.rarelity = CardData.Rarelity.Sleeve
	elif item_index == 2:
		editing_card.rarelity = CardData.Rarelity.BossSleeve
	elif item_index == 3:
		editing_card.rarelity = CardData.Rarelity.BossRare
	card_preview.material = editing_card.get_material()

func on_texture_loaded(path:String):
	editing_card.texture_path = path
	card_preview.texture = ImageTexture.create_from_image(Image.load_from_file(path))

func save_card(root:String):
	editing_card.name = name_editor.text
	editing_card.status = status_list.get_status()
	editing_card.is_infinity = $VBoxContainer/Flags/CheckBox.toggle_mode
	var card_root = root+"/Cards/"+editing_card.name
	DirAccess.make_dir_recursive_absolute(card_root)
	editing_card.texture_path = card_root + "/" + editing_card.name + ".png"
	ResourceSaver.save(card_preview.texture, editing_card.texture_path)
	ResourceSaver.save(editing_card, card_root + "/" + editing_card.name + ".tres")

func update_card_template():
	for _temp_stat in template_stats: _temp_stat.queue_free()
	template_stats = []
	if card_template.selected == 0:
		template_stats.append(status_list.constract_status("HP"))
		template_stats.append(status_list.constract_status("ATK"))
		template_stats.append(status_list.constract_status("DFS"))
	elif card_template.selected == 1:
		pass
	for i in (func(): var reversed = template_stats.duplicate(); reversed.reverse(); return reversed).call():
		status_list.add_child(i)
		status_list.move_child(i, 0)

func load_card(_card_data:CardData):
	card_preview.texture = _card_data.get_texture()
	name_editor.text = _card_data.name
	rarelity_select.select(_card_data.rarelity)
	rarelity_select.item_selected.emit(_card_data.rarelity)
	status_list.clear_status()
	for key in _card_data.status.keys():
		status_list.add_child(status_list.constract_status(key, _card_data.status[key]))

func load_card_ui_call():
	var cardlist = CardList.new()
	add_child(cardlist)
	cardlist.anchor_top = 1
	cardlist.anchor_bottom = 2
	cardlist.anchor_left = 0
	cardlist.anchor_right = 1
	create_tween().tween_property(self, "anchor_top", -1, 1).set_trans(Tween.TRANS_QUART)
	create_tween().tween_property(self, "anchor_bottom", 0, 1).set_trans(Tween.TRANS_QUART)
	cardlist.selected.connect(func(_card_data:CardData): load_card(_card_data))
	await cardlist.selected
	create_tween().tween_property(self, "anchor_top", 0, 1).set_trans(Tween.TRANS_QUART)
	await create_tween().tween_property(self, "anchor_bottom", 1, 1).set_trans(Tween.TRANS_QUART).finished
	cardlist.queue_free()

func _ready():
	$FileDialog.file_selected.connect(on_texture_loaded)
	card_preview.material = editing_card.get_material()
	
	status_add_button.button_down.connect(func(): status_list.add_child(status_list.constract_status()))
	rarelity_select.item_selected.connect(on_rarelity_changed)
	load_texture.button_down.connect(func(): $FileDialog.visible = true)
	save_button.button_down.connect(save_card.bind("user:/"))
	debug_save_button.button_down.connect(save_card.bind("res:/"))
	card_template.item_selected.connect(func(_index:int): update_card_template())
	load_button.button_down.connect(load_card_ui_call)
	update_card_template()
