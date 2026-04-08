extends Node

const AUTHORNAME_MODNAME_DIR := "EmK530-NativeResolution"
const AUTHORNAME_MODNAME_LOG_NAME := "EmK530-NativeResolution:Main"

const logname = "NativeResolution"

const vanilla_size = Vector2(960,540)
const MAX = 2147483647

var config = {
	"wideScreen": true,
	"renderScale": 1
}

var root = null
var copy_parent = "Camera/dialogue UI/viewblocker parent"
var post_name = "Camera/post processing/posterization test"
var viewBlocker = copy_parent+"/viewblocker"
var customBlock = copy_parent+"/customBlock"
var ratchet = copy_parent+"/ratchet"
var forceCoverTargets = [
	post_name,
	viewBlocker,
	copy_parent+"/viewblcoker", # lmao
	customBlock,
	"Camera/post processing/opengl post processing"
]
var title_passed = false
var portrait = false

func pr(tx):
	ModLoaderLog.info(tx,logname)

func safe_get(name):
	var node = root.get_children().back()
	if node.has_node(name):
		return node.get_node(name)
	else:
		return false

var lastScene = ""

func _ready():
	ModLoader.get_node("MSLaFaver-ModMenu").config_init(AUTHORNAME_MODNAME_DIR, config)
	root = get_tree().get_root()
	var config_object = ModLoaderConfig.get_config(AUTHORNAME_MODNAME_DIR, "user")
	if config_object != null:
		config = config_object.data
	pr("Ready for action.")

func _process(delta):
	var curScene = get_tree().get_current_scene().name
	if curScene != lastScene:
		if portrait:
			switch_aspect_ratio()
		
		if curScene == "menu":
			pr("Detected menu start, creating custom viewblocker.")
			title_passed = false
	lastScene = curScene
	
	if not title_passed:
		var blk = safe_get(customBlock)
		if not blk:
			var par = safe_get(copy_parent)
			if par:
				blk = safe_get(viewBlocker)
				if blk:
					blk = blk.duplicate()
					blk.name = "customBlock"
					blk.color = Color.BLACK
					blk.z_index = -1
					par.add_child(blk)
				else:
					pr("[WARN] Could not find viewblocker in the first frame.")
			else:
				pr("[WARN] Could not find viewblocker parent in the first frame.")
		if blk:
			var rat = safe_get(ratchet)
			if not rat.visible:
				title_passed = true
				blk.queue_free()
				pr("Removing custom viewblocker.")
	
	var ratio = 16.0/9.0
	
	var sz = Vector2(root.get_size())
	if curScene == "mp_lobby" or not config["wideScreen"]:
		sz.x = sz.y * ratio
	var mul = config["renderScale"]
	if sz.x >= sz.y * ratio or not config["wideScreen"]:
		if portrait:
			portrait = false
			switch_aspect_ratio()
		sz = sz * vanilla_size.y / sz.y
		var aspectX = sz.x/sz.y
		var canvSize = sz.y/float(vanilla_size.y)*mul
		var relAspX = (aspectX-ratio)
		
		root.set_canvas_transform(Transform2D(Vector2(canvSize,0),Vector2(0,canvSize),Vector2((relAspX/2.0)*sz.y*mul,0)))
	else:
		if not portrait:
			portrait = true
			switch_aspect_ratio()
		sz = sz * vanilla_size.x / sz.x
		var aspectY = sz.y/sz.x
		var canvSize = sz.x/float(vanilla_size.x)*mul
		var relAspY = (aspectY-1.0/ratio)
		
		root.set_canvas_transform(Transform2D(Vector2(canvSize,0),Vector2(0,canvSize),Vector2(0,(relAspY/2.0)*sz.x*mul)))
		
	root.content_scale_size = Vector2i(sz * mul)
	
	for i in forceCoverTargets:
		var targ = safe_get(i)
		if targ:
			targ.position = Vector2(-MAX,-MAX)
			targ.scale = Vector2(MAX,MAX)

func switch_aspect_ratio():
	var scene = get_tree().get_current_scene()
	var keep = Camera3D.KEEP_WIDTH if portrait else Camera3D.KEEP_HEIGHT
	var amt = 1.56
	var mult = amt if portrait else 1.0/amt
	var camera = scene.get_node_or_null("Camera")
	if camera != null:
		camera.keep_aspect = keep
		camera.fov *= mult
	var cameraManager = scene.get_node_or_null("standalone managers/camera manager")
	if cameraManager != null:
		for socket in cameraManager.socketArray:
			socket.fov *= mult
	for animation_player in scene.find_children("*", "AnimationPlayer"):
		for animation in animation_player.libraries[""]._data:
			var animation_object = animation_player.libraries[""]._data[animation]
			for i in range(animation_object.get_track_count()):
				var path = animation_object.track_get_path(i)
				if path.get_name(path.get_name_count() - 1) + ":" + path.get_concatenated_subnames() == "Camera:fov":
					for j in range(animation_object.track_get_key_count(i)):
						var value = animation_object.track_get_key_value(i,j)
						value *= mult
						animation_player.libraries[""]._data[animation].track_set_key_value(i,j,value)
