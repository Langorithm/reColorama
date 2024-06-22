extends Control

@onready var display_sprite: TextureRect = %DisplayTexture
@onready var vp: SubViewport = %SubViewport
@onready var source_sprite: TextureRect = %SourceTexture
@onready var v_flow_container: VFlowContainer = %VFlowContainer

var colors: Array[Color]



func _ready() -> void:
	get_viewport().files_dropped.connect(_on_files_dropped)
	v_flow_container.get_child(0).queue_free()
	source_sprite.texture = null


func open_image_file(filepath):
	var img = Image.load_from_file(filepath)
	setup_for_image(img)


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
			if pixel.a:
				color_set[pixel] = ""
	
	var res = color_set.keys()
	res.sort_custom(func(c0: Color, c1: Color):
		return c0.h < c1.h
	)
	
	return res


func _on_files_dropped(files) -> void:
	var path = files[0]
	open_image_file(path)
