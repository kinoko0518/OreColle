extends Control

var loading_menu:Control

func load_menu(menu:PackedScene):
	if loading_menu: loading_menu.queue_free()
	loading_menu = menu.instantiate()
	loading_menu.size_flags_vertical = Control.SIZE_EXPAND_FILL
	$VBoxContainer/Control.add_child(loading_menu)

func _ready():
	load_menu(preload("res://Scenes/player_menu.tscn"))
	$VBoxContainer/HBoxContainer/Button.button_down.connect(func(): load_menu(preload("res://Scenes/card_editor.tscn")))
	$VBoxContainer/HBoxContainer/Button2.button_down.connect(func(): load_menu(preload("res://Scenes/deck_editor.tscn")))
	$VBoxContainer/HBoxContainer/Button3.button_down.connect(func(): load_menu(preload("res://Scenes/player_menu.tscn")))
