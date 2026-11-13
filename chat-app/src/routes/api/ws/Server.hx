package routes.api.ws;

import shinku.Console.Logger;
import haxe.Json;
import hx.concurrent.collection.SynchronizedArray;
import shinku.handling.AbstractHandler;
import shinku.handling.RequestHandler.RequestEvent;
import shinku.ws.WebSocket;
import shinku.ws.WebSocketController.WebSocketAction;

class Server extends AbstractHandler {
	private var sockets:SynchronizedArray<WebSocket>;

	/** never put any parameters in the constructor of a handler, server hooks, or any other type of endpoint.**/
	public function new() {
		super();
		this.sockets = new SynchronizedArray();
	}

	function broadcast(author:String, content:String) {
		this.sockets = this.sockets.filter(v -> v.readyState == Open);

		for (ws in this.sockets) {
			try {
				ws.send(Json.stringify({
					author: author,
					content: content,
					time: Date.now().getTime(),

					// this is a simplification, it could just be another packet.
					onlineCount: this.sockets.length
				}));
			} catch (err) {
				trace(err);
			}
		}
	}

	@:keep public function GET(event:RequestEvent<Dynamic>) {
		if (event.locals.accountData == null) {
			return error(401, "You are not signed in!");
		}

		final username = event.locals.accountData.username;

		WebSocketAction.upgrade(event, "SkylliopeChat", (ws) -> {
			ws.onTextMessage = (msg:String) -> {
				try {
					var json = Json.parse(msg);
					this.broadcast(username, json.content);
				} catch (err) {
					Logger.error("Failed to send a message! ", err);
				}
			};

			this.sockets.add(ws);
			Logger.info("New connection!");
			this.broadcast("Skylliope", event.locals.accountData.username + " has joined the room!");
		});
	}
}
