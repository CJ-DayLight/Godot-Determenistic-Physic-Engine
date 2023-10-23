extends Spatial

#-----------------SCENE--SCRIPT------------------#
#    Close your game faster by clicking 'Esc'    #
#   Change mouse mode by clicking 'Shift + F1'   #
#------------------------------------------------#

export var fast_close := true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	
	if !OS.is_debug_build():
		fast_close = false
	
	if fast_close:
		print("** Fast Close enabled in the 'L_Main.gd' script **")
		print("** 'Esc' to close 'Shift + F1' to release mouse **")
	
	set_process_input(fast_close)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit() # Quits the game


# Capture mouse if clicked on the game, needed for HTML5
# Called when an InputEvent hasn't been consumed by _input() or any GUI item
#func _unhandled_input(event: InputEvent) -> void:
#	if event is InputEventMouseButton:
#			if event.button_index == BUTTON_LEFT && event.pressed:
#				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


#func _physics_process(delta):
#	print(Engine.get_frames_per_second())