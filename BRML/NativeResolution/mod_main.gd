extends Node

const AUTHORNAME_MODNAME_DIR := "EmK530-NativeResolution"
const AUTHORNAME_MODNAME_LOG_NAME := "EmK530-NativeResolution:Main"

const logname = "NativeResolution"

var config = {
    "upscaleResolution": true,
    "wideScreen": false,
    "renderScale": 1
}

var root = null
var copy_parent = "Camera/dialogue UI/viewblocker parent"
var post_name = "Camera/post processing/posterization test"
var viewBlocker = copy_parent+"/viewblocker"
var customBlock = copy_parent+"/customBlock"
var forceCoverTargets = [
    post_name,
    viewBlocker,
    copy_parent+"/viewblcoker", # lmao
    customBlock,
    "Camera/post processing/opengl post processing"
]
var ratchet = copy_parent+"/ratchet"

var title_passed = false

func pr(tx):
    ModLoaderLog.info(tx,logname)

func safe_get(name):
    if root.get_child_count() <= 2:
        return false
    if root.get_child(5).has_node(name):
        return root.get_child(5).get_node(name)
    else:
        return false

func _process(delta):
    if root == null:
        root = get_tree().get_root()
        var game_dir = OS.get_executable_path().get_base_dir()
        var config_dir = game_dir+"/config/"
        if FileAccess.file_exists(config_dir+AUTHORNAME_MODNAME_DIR+".txt"):
            var file = FileAccess.open(config_dir+AUTHORNAME_MODNAME_DIR+".txt", FileAccess.READ)
            pr("Config exists, reading...")
            var ln = file.get_line()
            while ln!="":
                if ln.substr(0,1)!="#":
                    var set = ln.split("=")
                    if float(set[1])!=0:
                        config[set[0]] = float(set[1])
                    else:
                        config[set[0]] = (true if set[1].to_lower()=="true" else false)
                ln = file.get_line()
            file.close()
        else:
            pr("Config does not exist, creating...")
            var da = DirAccess.open(game_dir)
            if not da.dir_exists("config"):
                da.make_dir("config")
            var file = FileAccess.open(config_dir+AUTHORNAME_MODNAME_DIR+".txt", FileAccess.WRITE)
            file.store_string("upscaleResolution="+("true" if config["upscaleResolution"] else "false"))
            file.store_string("\nwideScreen="+("true" if config["wideScreen"] else "false"))
            file.store_string("\nrenderScale="+str(config["renderScale"]))
            file.store_string("\n# Render scale is currently only available for wideScreen")
            file.store_string("\n# Enabling the setting will override upscaleResolution")
            file.store_string("\n# -1: Match window resolution\n# 1: 960x540 (Vanilla)\n# 1.5: 1440x810 (1.5x scale)\n# 2: 1920x1080 (2x scale)\n# 4: 3840x2160 (4x scale)\n#\n# And so on...")
            file.close()
        if config["wideScreen"]:
            pr("Creating custom viewblocker for menu.")
            var par = safe_get(copy_parent)
            if par:
                var blk = safe_get(viewBlocker)
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
        pr("Ready for action.")
        if config["upscaleResolution"]:
            root.content_scale_mode=1
    else:
        if config["wideScreen"]:
            if not title_passed:
                var blk = safe_get(customBlock)
                if blk:
                    var rat = safe_get(ratchet)
                    if not rat.visible:
                        title_passed = true
                        blk.queue_free()
            var sz = root.get_size()
            var szX = float(sz[0])
            var szY = float(sz[1])
            var mul = 540.0/(540*config["renderScale"])
            if config["renderScale"] == -1:
                mul = 0.5
            var aspectX = szX/szY
            var canvSize = szY/540.0*mul
            var relAspX = (aspectX-(16.0/9.0))
            root.content_scale_size = Vector2i(szX*mul,szY*mul)
            root.set_canvas_transform(Transform2D(Vector2(canvSize,0),Vector2(0,canvSize),Vector2((relAspX/2.0)*szY*mul,0)))
            for i in forceCoverTargets:
                var targ = safe_get(i)
                if targ:
                    targ.position = Vector2(-2147483647,-2147483647)
                    targ.scale = Vector2(2147483647,2147483647)
        elif config["upscaleResolution"]:
            root.content_scale_factor=1
            var post = safe_get(forceCoverTargets[0])
            if post:
                post.position = Vector2i(-10,-10)
                post.size = Vector2i(60,60)
