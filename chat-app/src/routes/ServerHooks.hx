package routes;

import shinku.std.URL;
import lib.server.Database;
import shinku.handling.RequestHandler.RequestEvent;
import shinku.handling.AbstractHooks.AbstractServerHooks;

class ServerHooks extends AbstractServerHooks {
	private var database:Null<Database>;

	public override function onServerInit() {
		// lets initsialize the database when the server initializes, and then we pass
		// it through RequestEvent#locals.
		this.database = new Database();
	}

	public override function handle(event:RequestEvent<Dynamic>, resolve:(event:RequestEvent<Dynamic>) -> Void) {
		// lets see if the user is signed in!
		final token = event.cookies.get("token");
		if (token != null && database != null) {
			var account = database.getUserInfoFromSession(URL.decodeURIComponent(token.value));
			event.locals.accountData = account;
		}

		event.locals.database = database;

		trace(event.locals);

		resolve(event);
	};
}
