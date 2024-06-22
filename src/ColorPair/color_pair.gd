class_name ColorPair
extends HBoxContainer

@onready var source_rect: ColorRect = $SourceRect
@onready var target_picker: ColorPickerButton = $TargetPicker

const COLOR_PAIR = preload("res://ColorPair/color_pair.tscn")
static func construct(parent: Node, source_color: Color = Color.BLACK) -> ColorPair:
	var cp = COLOR_PAIR.instantiate()
	parent.add_child(cp)
	cp.source_rect.color = source_color
	cp.target_picker.color = source_color
	#cp.ready.connect(
		#func():cp.source_rect.color = source_color
	#)
		
	return cp
