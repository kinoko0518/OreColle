extends Control

var cards:Array[Card]

func update_cards():
	if get_children():
		var temp_cards:Array[Card] = []
		var children = get_children()
		for i in range(children.size()):
			if children[i] is Card:
				temp_cards.append(children[i] as Card)
		cards = temp_cards
		
		var once = min((PI / 3) / cards.size(), PI/6)
		for i in range(cards.size()):
			create_tween().tween_property(cards[i], "rotation", i * once, 0.2)
		self.create_tween().tween_property(self, "rotation", deg_to_rad(190) - once * cards.size(), 0.2)

func _ready() -> void:
	self.child_order_changed.connect(update_cards)
