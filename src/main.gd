extends Control

@onready var display_sprite: TextureRect = %DisplayTexture
@onready var vp: SubViewport = %SubViewport
@onready var source_sprite: TextureRect = %SourceTexture
@onready var v_flow_container: VFlowContainer = %VFlowContainer
@onready var file_menu: PopupMenu = %File
@onready var file_dialog: FileDialog = %FileDialog

var colors: Array[Color]


func _ready() -> void:
	var ctrl_cmd = KEY_MASK_META if OS.get_name() == "macOS" else KEY_MASK_CTRL
	var args = OS.get_cmdline_args()
	if len(args) > 1:
		if _is_image(args[1]):
			open_image_file(args[1]) ## FIXME
		else:
			push_warning("%s type not supported." % [args[1]])

	get_viewport().files_dropped.connect(_on_files_dropped)
	v_flow_container.get_child(0).queue_free()
	
	file_menu.add_item(
		"Open... ",0,KEY_O + ctrl_cmd
	)
	file_menu.add_item(
		"Save... ",1,KEY_S + ctrl_cmd
	)
	file_menu.id_pressed.connect(
		func(id):
			if id == 0:
				file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
				file_dialog.visible = true
				#file_dialog.ok_button_text = "Open"
				file_dialog.file_selected.connect(
					open_image_file
					,CONNECT_ONE_SHOT
				)
			elif id == 1:
				file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
				file_dialog.visible = true
				#file_dialog.ok_button_text = "Save"
				file_dialog.file_selected.connect(
					save_image
					,CONNECT_ONE_SHOT
				)
	)


func open_image_file(filepath):
	var img = Image.load_from_file(filepath)
	setup_for_image(img)

func save_image(path: String):
	var img = display_sprite.texture.get_image()
	img.save_png(path)

func setup_for_image(image: Image):
	# Clean color pairs
	v_flow_container.get_children().map(func(child):
		child.queue_free()
	)
	
	source_sprite.texture = ImageTexture.create_from_image(image)
	source_sprite.size = image.get_size()
	vp.size = source_sprite.get_rect().size
	
	var palette: Array = _get_image_palette(image)
	var idx = 0
	for color in palette:
		var cp = ColorPair.construct(v_flow_container, color)
		_map_picker_to_shaderparam(cp,source_sprite.material,idx)
		idx += 1


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		pass
	if event.is_action_pressed("ui_accept"):
		var img = display_sprite.texture.get_image()
		var path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
		path += "/image.png"
		var error = img.save_png(path)
		if error: 
			printerr(error_string(error))
		else:
			print("Image saved at %s" % [path])


func _map_picker_to_shaderparam(cp: ColorPair, mat:ShaderMaterial, param_idx: int) -> void:
	var rect = cp.source_rect
	var picker = cp.target_picker
	
	var source_param = "s%s" % [param_idx]
	var target_param = "t%s" % [param_idx]
	
	mat.set_shader_parameter(source_param,rect.color)
	mat.set_shader_parameter(target_param,rect.color)
	picker.color_changed.connect(
		func(color):
			mat.set_shader_parameter(target_param,color)
	)


func _get_image_palette(im: Image) -> Array:
	var color_set: Dictionary = {}
	var x = im.get_size().x
	var y = im.get_size().y
	
	#collect all colors in image, store in set to remove duplicates
	for i in range(x):
		for j in range(y):
			var pixel: Color = Color(im.get_pixel(i,j),1)
			pixel.linear_to_srgb()
			if pixel.a == 1:
				color_set[pixel] = ""
	
	var res = color_set.keys()
	res.sort_custom(func(c0: Color, c1: Color):
		return c0.h < c1.h
	)
	
	return res


func _on_files_dropped(files) -> void:
	var path = files[0]
	open_image_file(path)


func _is_image(path:String) -> bool:
	var formats = ".png,.svg,.jpg,.jpeg".split(",")
	for format in formats:
		return path.ends_with(format)
	return false
