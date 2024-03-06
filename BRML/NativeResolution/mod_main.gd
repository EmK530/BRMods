extends Node

var root = null

func _process(delta):
    if root == null:
        root = get_tree().get_root()
    else:
        var height=root.get_size()[1]
        if DisplayServer.window_get_mode()==4 && height%540==0:
            root.content_scale_mode=0
            root.content_scale_factor=height/540
        else:
            root.content_scale_mode=1
            root.content_scale_factor=1