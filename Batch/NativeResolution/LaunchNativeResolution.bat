@echo off
cls
echo extends SceneTree;func _init():change_scene_to_file('res://scenes/menu.tscn'); > "%temp%\BuckshotNativeRes.gd"
echo func _process(delta):root.content_scale_factor=root.get_size()[1]/540;root.content_scale_mode=(0 if DisplayServer.window_get_mode()==4 else 1); >> "%temp%\BuckshotNativeRes.gd"
start /B "" "Buckshot Roulette.exe" --script %temp%\BuckshotNativeRes.gd
exit
