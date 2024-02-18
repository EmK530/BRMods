@echo off
cls
if exist "%temp%\BuckshotNativeRes.gd" goto:skip
echo extends SceneTree;func _init():change_scene_to_file('res://scenes/menu.tscn'); > "%temp%\BuckshotNativeRes.gd"
echo func _process(delta):root.content_scale_factor=root.get_size()[1]/540;root.content_scale_mode=(1 if DisplayServer.window_get_mode()==0 else 0); >> "%temp%\BuckshotNativeRes.gd"
:skip
start /B "" "Buckshot Roulette.exe" --script %temp%\BuckshotNativeRes.gd
exit
