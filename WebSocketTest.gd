extends Control

# The port we will listen to
export(int) var bind_port = 9080

# Our WebSocketServer instance
var _server = WebSocketServer.new()

var clients:Array = []

func _client(id):
	_server.get_peer(id)

func log_msg(msg:String, direction:int = 0) -> void:
	var prefix:String = ""
	match direction:
		0:
			prefix = "->"
		1:
			prefix = "<-"
		2:
			prefix = "STATUS : "
		-1:
			prefix = "/!\\"
	$VBoxContainer/ScrollContainer/ItemList.add_item(prefix + msg)

signal received_text(text)

func _ready():
	# Connect base signals to get notified of new client connections,
	# disconnections, and disconnect requests.
	_server.connect("client_connected", self, "_connected")
	_server.connect("client_disconnected", self, "_disconnected")
	_server.connect("client_close_request", self, "_close_request")
	# This signal is emitted when not using the Multiplayer API every time a
	# full packet is received.
	# Alternatively, you could check get_peer(PEER_ID).get_available_packets()
	# in a loop for each connected peer.
	_server.connect("data_received", self, "_on_data")
	# Start listening on the given port.
	var err = _server.listen(bind_port)
	if err != OK:
		log_msg("Unable to start server", -1)
		set_process(false)
	log_msg("Server started on port %d" % [bind_port])

func _connected(id, proto):
	# This is called when a new peer connects, "id" will be the assigned peer id,
	# "proto" will be the selected WebSocket sub-protocol (which is optional)
	log_msg("Client %d connected with protocol: %s" % [id, proto], 2)
	_server.get_peer(id).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	clients.append(id)

func _close_request(id, code, reason):
	# This is called when a client notifies that it wishes to close the connection,
	# providing a reason string and close code.
	log_msg("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason], 2)

func _disconnected(id, was_clean = false):
	# This is called when a client disconnects, "id" will be the one of the
	# disconnecting client, "was_clean" will tell you if the disconnection
	# was correctly notified by the remote peer before closing the socket.
	log_msg("Client %d disconnected, clean: %s" % [id, str(was_clean)], 2)
	clients.remove(clients.find(id))

func _on_data(id):
	# Print the received packet, you MUST always use get_peer(id).get_packet to receive data,
	# and not get_packet directly when not using the MultiplayerAPI.
	var pkt = _server.get_peer(id).get_packet()
	var msg:String = pkt.get_string_from_utf8()
	log_msg("Got data from client %d: %s" % [id, pkt.get_string_from_utf8()], 2)
	emit_signal("received_text", msg)
	#_server.get_peer(id).put_packet(pkt)

func _process(delta):
	# Call this in _process or _physics_process.
	# Data transfer, and signals emission will only happen when calling this function.
	_server.poll()


func _on_LineEdit_text_entered(new_text:String):
	send_message(new_text)
	$VBoxContainer/LineEdit.clear()
	pass # Replace with function body.

func send_message(message:String) -> void:
	if _server.is_listening():
		for client_id in clients:
			var client = _server.get_peer(client_id)
			if client == null:
				log_msg("Client is null", -1)
				continue
			client.put_packet(message.to_utf8())
			log_msg("[Client:%d] %s" % [client_id, message])
