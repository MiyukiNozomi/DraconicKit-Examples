package routes.api.login;

import shinku.handling.RequestHandler.RequestEvent;
import shinku.handling.AbstractHandler;

class ServerHandler extends AbstractHandler {
	@:keep public function POST(event:RequestEvent<Dynamic>) {
		var payload = event.req.json();
		if (payload == null)
			return error(400, "Expected JSON!");

		var username = payload.username;
		var password = payload.password;

		if (username == null || password == null || !Std.isOfType(username, String) || !Std.isOfType(password, String))
			return error(400, "Missing either: username, password, or one/more of them are not a string!");

		final session = event.locals.database.logUserIn(username, password);
		if (session == null)
			return error(500, "Incorrect password or non-existant account!");

		// in prodution, make the cookie only accessible through HTTPS.
		#if dev
		final isSecure = false;
		#else
		final isSecure = true;
		#end

		event.cookies.set("token", session, {
			httpOnly: true,
			secure: isSecure
		});

		json({
			ok: true
		});
	}
}
