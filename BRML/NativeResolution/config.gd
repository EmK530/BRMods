extends Control

@export var widescreen_toggle: CheckButton
@export var renderscale_spinbox: SpinBox

const id = "EmK530-NativeResolution"
const id_modmenu = "MSLaFaver-ModMenu"

var speaker_press: AudioStreamPlayer2D

func _ready():
	var config = ModLoaderConfig.get_config(id, "user")
	if config != null:
		var data = config.data
		widescreen_toggle.button_pressed = data.get("wideScreen")
		renderscale_spinbox.value = data.get("renderScale")
	
	widescreen_toggle.toggled.connect(_on_toggled_widescreen)
	renderscale_spinbox.value_changed.connect(_on_changed_renderscale)
	
	var line_edit = renderscale_spinbox.get_line_edit()
	line_edit.mouse_default_cursor_shape = Control.CURSOR_ARROW
	line_edit.add_theme_constant_override("caret_width", 0)
	
	speaker_press = get_node("/root/menu/speaker_press")
	
	var toggle_off_image = Image.load_from_file("res://mods-unpacked/%s/assets/toggle-off.png" % id_modmenu)
	var toggle_off_texture = ImageTexture.create_from_image(toggle_off_image)
	var toggle_on_image = Image.load_from_file("res://mods-unpacked/%s/assets/toggle-on.png" % id_modmenu)
	var toggle_on_texture = ImageTexture.create_from_image(toggle_on_image)
	
	for toggle in [widescreen_toggle]:
		toggle.add_theme_icon_override("unchecked", toggle_off_texture)
		toggle.add_theme_icon_override("unchecked_disabled", toggle_off_texture)
		toggle.add_theme_icon_override("checked", toggle_on_texture)
		toggle.add_theme_icon_override("checked_disabled", toggle_on_texture)

func _on_toggled_widescreen(enabled: bool):
	update_config("wideScreen", enabled)
	speaker_press.play()

func _on_changed_renderscale(value: float):
	update_config("renderScale", value)
	speaker_press.play()

func update_config(config_name: String, config_value):
	var config = ModLoaderConfig.get_config(id, "user")
	if config != null:
		config.data[config_name] = config_value
		ModLoaderConfig.update_config(config)
		ModLoader.get_node(id).config = config.data
