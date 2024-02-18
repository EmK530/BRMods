extends Node

var root = null

func _process(delta):
    if root == null:
        root = get_tree().get_root()
    else:
        root.content_scale_factor=root.get_size()[1]/540
        root.content_scale_mode=(0 if DisplayServer.window_get_mode()==4 else 1)
