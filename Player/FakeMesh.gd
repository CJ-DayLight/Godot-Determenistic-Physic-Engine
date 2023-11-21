tool
extends MeshInstance



func _physics_process(delta):
	global_translation = $"../..".global_translation + Vector3(0,13.5,0)
	scale = $"../..".scale
