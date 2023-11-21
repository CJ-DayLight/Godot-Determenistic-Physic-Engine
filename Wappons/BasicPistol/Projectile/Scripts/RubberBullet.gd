extends Spatial

var Speed = 10
var FVector:Vector3 = Vector3(0,0,0)




func _network_spawn(data: Dictionary) -> void:
	global_translation = data['GlobalTranslation']
	FVector = data['FVector']



func _network_process(_input: Dictionary) -> void:
	if not is_inside_tree():
		return
	global_translation += FVector * Speed 
	for HitBox in get_tree().get_nodes_in_group("PlayerHitBox"):
		if global_translation.z <= HitBox.V3.z and global_translation.z >= HitBox.V1.z\
		and global_translation.x >= HitBox.V3.x and global_translation.x <= HitBox.V4.z:
			pass


func _on_NetworkTimer_timeout():
	SyncManager.despawn(self)

func _save_state() -> Dictionary:
	return {
		global_transform = global_transform,
	}

func _load_state(state: Dictionary) -> void:
	global_transform = state['global_transform']
