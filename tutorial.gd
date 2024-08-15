extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
var port = "1027"
var ip = "127.0.0.1"


func _on_host_pressed():
	port = $CanvasLayer/Port.text
	if port == "":
		port = "1027"


	peer.create_server(int(port))
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	$CanvasLayer.hide()

func _on_join_pressed():
	port = $CanvasLayer/Port.text
	if port == "":
		port = "1027"

	ip = $CanvasLayer/IP_Adress.text
	if ip == "":
		ip = "127.0.0.1"

	peer.create_client(ip, int(port))
	multiplayer.multiplayer_peer = peer
	$CanvasLayer.hide()

func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func del_player(id):
	rpc("_del_player", id)


@rpc("any_peer", "call_local")
func _del_player(id):
	get_node(str(id)).queue_free()


