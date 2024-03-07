extends Node

var root = null
var post_name = "Camera/post processing/posterization test"

func _process(delta):
    if root == null:
        root = get_tree().get_root()
    else:
        root.content_scale_mode=1
        root.content_scale_factor=1
        if root.get_child(2).has_node(post_name):
            var post = root.get_child(2).get_node(post_name)
            post.position = Vector2i(-10,-10)
            post.size = Vector2i(60,60)
