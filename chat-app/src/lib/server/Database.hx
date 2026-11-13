package lib.server;

import haxe.ds.StringMap;
import sys.FileSystem;
import haxe.Json;
import sys.io.File;
import shinku.Console.Logger;
import sys.thread.Mutex;
import hx.concurrent.lock.RLock;
import hx.concurrent.lock.RWLock.WriteLock;
import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.crypto.Sha256;
import hx.concurrent.collection.SynchronizedMap;

typedef AccountInfo = {
	username:String
}

typedef User = AccountInfo & {
	passwordHash:String
};

/**
	Normally you would use a real database here.
	But this is just an example of a chat application so we use an in-memory persistant map.
**/
class Database {
	static final FILENAME = "mockdb.json";

	// This is a username -> User map
	var users:SynchronizedMap<String, User>;
	// This is a username -> session token map
	var sessions:SynchronizedMap<String, String>;

	var writeLock:Mutex;

	public function new() {
		this.users = SynchronizedMap.newStringMap();
		this.sessions = SynchronizedMap.newStringMap();
		this.writeLock = new Mutex();

		// Notice we are not validating it.
		// This can be a problem on a real application.
		if (FileSystem.exists(FILENAME)) {
			final dynFile = Json.parse(File.getContent(FILENAME));
			final file:{users:Dynamic, sessions:Dynamic} = dynFile;
			for (key in Reflect.fields(file.users))
				this.users.set(key, Reflect.getProperty(file.users, key));
			for (key in Reflect.fields(file.sessions))
				this.sessions.set(key, Reflect.getProperty(file.sessions, key));
		}
	}

	/**
		A mock account register, just puts it on a map, and returns true if the account was created, or false if it already exists.
	**/
	public function registerUser(username:String, password:String) {
		if (this.users.exists(username))
			return false;

		this.users.set(username, {
			username: username,
			// Security note: using Sha256 for passwords is potentially a bad idea.
			// Since it can be rather easily bruteforced. in a real app, it should be at least hardened with PBKDF2.
			passwordHash: Sha256.encode(password)
		});
		this.writeFile();
		return true;
	}

	/**
		A mock "sign in", returns a String session token if the password matched, null if it did not.
	**/
	public function logUserIn(username:String, password:String):Null<String> {
		final user = this.users.get(username);
		if (user == null)
			return null;
		final session = Base64.encode(generateRandomBytes(32));
		this.sessions.set(session, username);
		this.writeFile();
		return session;
	}

	public function getUserInfoFromSession(session:String):Null<AccountInfo> {
		final username = this.sessions.get(session);
		if (username == null)
			return null;
		final user = this.users.get(username);
		if (user == null)
			return null;
		return {
			username: user.username
		};
	}

	function writeFile() {
		writeLock.acquire();
		try {
			var usersMap = new Map<String, Dynamic>();
			for (k => v in users) {
				usersMap.set(k, v);
			}
			var sessionsMap = new Map<String, Dynamic>();
			for (k => v in sessions) {
				sessionsMap.set(k, v);
			}

			File.saveContent(FILENAME, Json.stringify({
				users: usersMap,
				sessions: sessionsMap
			}));
		} catch (e) {
			Logger.error(e);
			Logger.error("Could not store database information!");
		}
		writeLock.release();
	}

	static function generateRandomBytes(length:Int):Bytes {
		var bytes = Bytes.alloc(length);
		for (i in 0...length) {
			bytes.set(i, Std.random(256));
		}
		return bytes;
	}
}
