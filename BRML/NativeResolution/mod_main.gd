extends Node

var root = null

func _process(delta):
    if root == null:
        root = get_tree().get_root()
    else:
        root.content_scale_mode=1
        root.content_scale_factor=1