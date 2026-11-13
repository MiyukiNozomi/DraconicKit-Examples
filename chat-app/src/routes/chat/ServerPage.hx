package routes.chat;

import shinku.handling.RequestHandler.RequestEvent;
import shinku.handling.AbstractHandler.AbstractServerPage;

class ServerPage extends AbstractServerPage {
	public override function pageServerLoad(event:RequestEvent<Dynamic>):Dynamic {
		trace(event.locals);

		if (event.locals.accountData == null)
			redirect(302, "/");

		return {
			accountInfo: event.locals.accountData
		};
	}
}
