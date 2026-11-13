package routes.api.register;

import shinku.handling.RequestHandler.RequestEvent;
import shinku.handling.AbstractHandler;

class ServerHandler extends AbstractHandler {
	@:keep public function POST(event:RequestEvent<Dynamic>) {
		var payload = event.req.json();
		if (payload == null)
			return error(400, "Expected JSON!");
		var username = payload.username;
		var password = payload.password;
		var repeatPassword = payload.repeatPassword;

		if (username == null || password == null || repeatPassword == null || !Std.isOfType(username, String) || !Std.isOfType(password, String)
			|| !Std.isOfType(repeatPassword, String))
			return error(400, "Missing either: username, password, repeatPassword, or one/more of them are not a string!");

		if (password != repeatPassword) {
			return error(400, "Passwords dont match!");
		}

		if (!event.locals.database.registerUser(username, password)) {
			return error(400, "Account already exists!");
		}

		final session = event.locals.database.logUserIn(username, password);
		if (session == null)
			return error(500, "Could not create session!");

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
