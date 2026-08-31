extends "res://scripts/main.gd"

func _ready() -> void:
    super._ready()
    DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
    DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
