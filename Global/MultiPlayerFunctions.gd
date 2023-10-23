extends Node




func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "OnSomeOneJoined")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")





func OnSomeOneJoined(peer_id: int):
	print("Registering to Sync manger")
	SyncManager.add_peer(peer_id)
	get_node("/root/L_Main/ServerPlayer").set_network_master(1)
	if get_tree().is_network_server():
		get_node("/root/L_Main/ClientPlayer").set_network_master(peer_id)
	else:
		get_node("/root/L_Main/ClientPlayer").set_network_master(get_tree().get_network_unique_id())
	
	if get_tree().is_network_server():
		# Give a little time to get ping data.
		yield(get_tree().create_timer(2.0), "timeout")
		SyncManager.start()

func _on_network_peer_disconnected(peer_id: int):
	SyncManager.remove_peer(peer_id)

func _on_server_disconnected() -> void:
	_on_network_peer_disconnected(1)


func HostGame() -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(int(9999), 1)
	get_tree().network_peer = peer

func JoinGame() -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client("127.0.0.1", int(9999))
	get_tree().network_peer = peer
