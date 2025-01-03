extends TextureRect
class_name SelectableCard

signal clicked(_carddata:CardData)

var is_mouse_inside:bool = false
var carddata:CardData

func _ready():
	mouse_entered.connect(func(): is_mouse_inside = true)
	mouse_exited.connect(func(): is_mouse_inside = false)

func _process(_delta):
	if is_mouse_inside and Input.is_action_just_pressed("summon_return"):
		clicked.emit(carddata)
