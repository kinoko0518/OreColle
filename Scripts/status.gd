extends VBoxContainer

func constract_status(status_name:String = "", value:float = 0.0) -> HBoxContainer:
	var delete_button = Button.new()
	var     stat_name = LineEdit.new()
	var       spinbox = SpinBox.new()
	var          hbox = HBoxContainer.new()
	
	stat_name.text = status_name
	spinbox.min_value = -2147483647
	spinbox.max_value = 2147483647
	spinbox.value = value
	spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	delete_button.text = "ステータスを削除"
	delete_button.button_down.connect(func(): hbox.queue_free())
	
	hbox.add_child(stat_name)
	hbox.add_child(spinbox)
	hbox.add_child(delete_button)
	return hbox

func clear_status():
	for i in get_children(): i.queue_free()

func get_status() -> Dictionary[String, float]:
	var res:Dictionary[String, float]
	for i in range(get_children().size()):
		var          grandson = get_child(i).get_children()
		var lineedit:LineEdit = grandson.filter(func(target): if target is LineEdit: return target)[0]
		var   spinbox:SpinBox = grandson.filter(func(target): if target is SpinBox: return target)[0]
		res[lineedit.text]    = spinbox.value
	return res
