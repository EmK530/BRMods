extends Node

const AUTHORNAME_MODNAME_DIR := "EmK530-NativeResolution"
const AUTHORNAME_MODNAME_LOG_NAME := "EmK530-NativeResolution:Main"

const logname = "NativeResolution"

const vanilla_size = Vector2(960,540)

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
	if curScene != lastScene and curScene == "menu":
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
					blk.color = Color(0,0,0,1)
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
	if curScene == "mp_lobby" or not config["wideScreen"] or sz.x < sz.y * ratio:
		sz.x = sz.y * ratio
	var mul = config["renderScale"]
	sz = sz * vanilla_size.y / sz.y
	var aspectX = sz.x/sz.y
	var canvSize = sz.y/float(vanilla_size.y)*mul
	var relAspX = (aspectX-ratio)
		
	root.content_scale_size = Vector2i(sz * mul)
	root.set_canvas_transform(Transform2D(Vector2(canvSize,0),Vector2(0,canvSize),Vector2((relAspX/2.0)*sz.y*mul,0)))
	
	for i in forceCoverTargets:
		var targ = safe_get(i)
		if targ:
			targ.position = Vector2(-2147483647,-2147483647)
			targ.scale = Vector2(2147483647,2147483647)
