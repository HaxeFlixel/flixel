package;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.text.TextFieldType;
import flash.utils.ByteArray;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.api.FlxGameJolt;
import flixel.addons.text.FlxTextField;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import openfl.utils.ByteArray;
using StringTools;

/**
 * These lines allow embedding of assets as ByteArrays, which helps to minimize the threat of data being compromised.
 * For your own purposes, it is recommended you add "*.privatekey" to your source control ignore list.
 * The content of the .privatekey file should be just your private key.
 * To see how this file is read and used, look at the bottom of the create() function below.
 */
@:file("assets/example.privatekey") class MyPrivateKey extends #if (lime_legacy || openfl <= "3.4.0") ByteArray #else ByteArrayData #end {} 

class MenuState extends FlxState
{
	private var _connection:FlxText;
	private var _return:FlxText;
	private var _main:FlxGroup;
	private var _highScores:FlxGroup;
	private var _apiTest:FlxGroup;
	private var _loginGroup:FlxGroup;
	private var _allScreens:FlxGroup;
	private var _apiPages:Array<FlxGroup>;
	private var _login:Button;
	private var _apiCurrentPage:Int;
	private var _mainMenuTime:Float = 0.0;
	private var _input1:FlxTextField;
	private var _input2:FlxTextField;
	private var _imageDisplay:FlxSprite;
	
	private static inline function API_TEST_BUTTONS():Array<Array<String>>
	{
		return [["fetchUser", "authUser", "openSession", "pingSession"],
		        ["closeSession", "fetchTrophy", "addTrophy", "fetchScore"],
		        ["addScore", "getTables", "fetchData", "setData"],
		        ["updateData", "removeData", "getAllKeys", "resetUser"],
		        ["fetchTrophyImage", "fetchAvatarImage", "username", "usertoken"],
		        ["isQuickPlay", "isEmbeddedFlash"]];
	}
	
	override public function create():Void
	{
		Reg.genColors();
		FlxG.cameras.bgColor = Reg.lite;
		Reg.level = 1;
		
		#if !FLX_NO_MOUSE
		var mouseSprite:Sprite = new Sprite();
		mouseSprite.graphics.beginFill(Reg.dark, 1);
		mouseSprite.graphics.moveTo(0, 0);
		mouseSprite.graphics.lineTo(20, 20);
		mouseSprite.graphics.lineTo(0, 27.5);
		mouseSprite.graphics.endFill();
		
		// using .show( mouseSprite ) doesn't work, so we convert it to bitmapdata
		
		var mouseData:BitmapData = new BitmapData(20, 30, true, 0);
		mouseData.draw(mouseSprite);
		FlxG.mouse.load(mouseData);
		FlxG.mouse.visible = true;
		#end
		
		// The background emitter, connection info, version, and blurb are always present.
		
		var em:Emitter = new Emitter(Std.int(FlxG.width / 2), Std.int(FlxG.height / 2), 4);
		
		_connection = new FlxText(1, 1, FlxG.width, "Connecting to GameJolt...");
		_connection.color = Reg.med_lite;
		
		var info:FlxText = new FlxText(0, FlxG.height - 14, FlxG.width, "FlxPong is a demo of HaxeFlixel & FlxGameJolt, which interacts with the GameJolt API.");
		info.color = Reg.med_lite;
		info.alignment = CENTER;
		
		var ver:FlxText = new FlxText(0, 0, FlxG.width, Reg.VERSION);
		ver.color = Reg.med_lite;
		ver.alignment = RIGHT;
		
		add(em);
		add(_connection);
		add(info);
		add(ver);
		
		// Set up the "main" screen/buttons.
		
		_main = new FlxGroup();
		
		var title:FlxText = new FlxText(0, 20, FlxG.width, "FlxPong!", 16);
		title.color = Reg.med_dark;
		title.alignment = CENTER;
		
		var play:Button = new Button(0, 50, "Play!", playCallback);
		Reg.quarterX(play, 2);
		
		_login = new Button(0, 50, "Log in", switchMenu, 60);
		Reg.quarterX(_login, 3);
		_login.visible = false;
		_login.active = false;
		
		var test:Button = new Button(0, 80, "API Functions", switchMenu);
		Reg.quarterX(test, 1);
		
		var high:Button = new Button(0, 80, "High Scores", scoresCallback);
		Reg.quarterX(high, 2);
		
		var mine:Button = new Button(0, 80, "My Scores", mineCallback);
		Reg.quarterX(mine, 3);
		
		var source:Button = new Button(0, 110, "FlxGameJolt Source", sourceCallback, 120);
		Reg.quarterX(source, 1);
		
		var hf:Button = new Button(0, 110, "HaxeFlixel.com", hfCallback);
		Reg.quarterX(hf, 2);
		
		var doc:Button = new Button(0, 110, "GameJolt API Doc", docCallback, 120);
		Reg.quarterX(doc, 3);
		
		_main.add(title);
		_main.add(play);
		_main.add(_login);
		_main.add(test);
		//_main.add( high );
		//_main.add( mine );
		_main.add(source);
		_main.add(hf);
		_main.add(doc);
		
		// End main group.
		
		// Set up the "high scores" screen.
		
		_highScores = new FlxGroup();
		
		// End high scores.
		
		// Set up the API test screen.
		
		_apiTest = new FlxGroup();
		
		var xpos:Int = 2;
		var ypos:Array<Int> = [20, 42, 64, 86, 108, 130];
		var buttonwidth:Int = 100;
		
		// Set up the pages of this screen.
		
		_apiPages = [];
		_apiCurrentPage = 0;
		
		for (i in 0...API_TEST_BUTTONS().length)
		{
			_apiPages.push(new FlxGroup());
			
			var button1:Button;
			var button2:Button;
			var button3:Button;
			var button4:Button;
			
			if (API_TEST_BUTTONS()[i][0] != null)
			{
				button1 = new Button(xpos, ypos[0], API_TEST_BUTTONS()[i][0], apiCallback, buttonwidth);
				_apiPages[i].add(button1);
			}
			
			if (API_TEST_BUTTONS()[i][1] != null)
			{
				button2 = new Button(xpos, ypos[1], API_TEST_BUTTONS()[i][1], apiCallback, buttonwidth);
				_apiPages[i].add(button2);
			}
			
			if (API_TEST_BUTTONS()[i][2] != null)
			{
				button3 = new Button(xpos, ypos[2], API_TEST_BUTTONS()[i][2], apiCallback, buttonwidth);
				_apiPages[i].add(button3);
			}
			
			if (API_TEST_BUTTONS()[i][3] != null)
			{
				button4 = new Button(xpos, ypos[3], API_TEST_BUTTONS()[i][3], apiCallback, buttonwidth);
				_apiPages[i].add(button4);
			}
			
			_apiPages[i].visible = false;
			_apiPages[i].active = false;
		}
		
		// We do want to see the first page, once apiTest is added
		
		_apiPages[0].visible = true;
		_apiPages[0].active = true;
		
		// Add elements aside from the per-screen buttons
		
		var prev:Button = new Button(xpos, ypos[4], "<<", testMove, Std.int(buttonwidth / 2 - xpos / 2));
		var next:Button = new Button(Std.int(prev.x + prev.width + 2), ypos[4], ">>", testMove, Std.int(buttonwidth / 2 - xpos / 2));
		var testSpace:PongSprite = new PongSprite(xpos + buttonwidth + xpos, ypos[0], FlxG.width - (xpos + buttonwidth + xpos * 2), ypos[4] + 20 - ypos[0], Reg.med_lite);
		_return = new FlxText(testSpace.x + 4, testSpace.y + 4, Std.int(testSpace.width - 8), "Return data will display here.");
		_return.color = Reg.lite;
		_imageDisplay = new FlxSprite(testSpace.x + 5, testSpace.y + 5);
		_imageDisplay.visible = false;
		var exit:Button = new Button(Std.int(testSpace.x + testSpace.width - 40), Std.int(testSpace.y + testSpace.height - 20), "Back", switchMenu, 40);
		
		// Add everything to this screen
		
		for (g in _apiPages)
		{
			_apiTest.add(g);
		}
		
		_apiTest.add(prev);
		_apiTest.add(next);
		_apiTest.add(testSpace);
		_apiTest.add(_return);
		_apiTest.add(_imageDisplay);
		_apiTest.add(exit);
		
		_apiTest.active = false;
		_apiTest.visible = false;
		
		// End API test.
		
		// Login screen
		
		_loginGroup = new FlxGroup();
		
		var instruct:FlxText = new FlxText(0, 50, FlxG.width, "Log in to GameJolt to get trophies and stuff:");
		instruct.alignment = CENTER;
		instruct.color = Reg.med_dark;
		
		var word1:FlxText = new FlxText(0, 70, 60, "Username:");
		var word2:FlxText = new FlxText(0, 90, 60, "Token:");
		Reg.quarterX(word1, 1);
		Reg.quarterX(word2, 1);
		word1.color = word2.color = Reg.med_dark;
		
		_input1 = new FlxTextField(0, 70, 240, " ");
		_input2 = new FlxTextField(0, 90, 240, " ");
		Reg.quarterX(_input1, 3);
		Reg.quarterX(_input2, 3);
		_input2.color = _input1.color = Reg.med_lite;
		_input2.textField.selectable = _input1.textField.selectable = true;
		_input2.textField.multiline = _input1.textField.multiline = false;
		_input2.textField.wordWrap = _input1.textField.wordWrap = false;
		_input2.textField.maxChars = _input1.textField.maxChars = 30;
		#if flash
		_input2.textField.restrict = _input1.textField.restrict = "A-Za-z0-9_";
		#end
		_input2.textField.type = _input1.textField.type = TextFieldType.INPUT;
		
		var input1bg:PongSprite = new PongSprite(Std.int(_input1.x), Std.int(_input1.y), Std.int(_input1.width - 40), Std.int(_input1.height + 4), Reg.dark);
		var input2bg:PongSprite = new PongSprite(Std.int(_input2.x), Std.int(_input2.y), Std.int(_input2.width - 40), Std.int(_input2.height + 4), Reg.dark);
		
		#if desktop
		_input1.height = input1bg.height;
		_input2.height = input2bg.height;
		#end
		
		var trylogin:Button = new Button(0, 110, "Log in", loginCallback);
		Reg.quarterX(trylogin, 2);
		var back:Button = new Button(400, 108, "Back", switchMenu, 40);
		
		_loginGroup.add(word1);
		_loginGroup.add(word2);
		_loginGroup.add(input1bg);
		_loginGroup.add(input2bg);
		_loginGroup.add(_input1);
		_loginGroup.add(_input2);
		_loginGroup.add(instruct);
		_loginGroup.add(trylogin);
		_loginGroup.add(back);
		
		_loginGroup.active = false;
		_loginGroup.visible = false;
		
		// End Login.
		
		_allScreens = new FlxGroup();
		_allScreens.add(_main);
		_allScreens.add(_apiTest);
		_allScreens.add(_loginGroup);
		
		add(_allScreens);
		
		em.start(false);
		
		// Load the privatekey data as a bytearray.
		
		var ba:ByteArray = new MyPrivateKey();
		
		// If we're already initialized (which would happen on returning from the playstate), we don't need to run init().
		// If we're not initialized, call init() using the game ID and the private key, which is converted to a string
		// with .readUTFBytes( ba.length ). The ba.length ensures that the ByteArray will be read from beginning to end
		// and then stop; otherwise, there would be an error when the end of the ByteArray was reached.
		
		if (!FlxGameJolt.initialized)
		{
			FlxGameJolt.init(19975, ba.readUTFBytes(ba.length), true, null, null, initCallback);
		}
		else
		{
			_connection.text = "Welcome back to the main menu, " + FlxGameJolt.username + "!";
		}
		
		super.create();
	}
	
	override public function update(elapsed:Float):Void
	{
		_mainMenuTime += elapsed;
		
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.justPressed.ENTER && _loginGroup.visible)
		{
			loginCallback("Login");
		}
		#end
		
		super.update(elapsed);
	}
	
	#if debug
	private function colorCallback(Name:String):Void
	{
		Reg.genColors();
		FlxG.switchState(new MenuState());
	}
	#end
	
	private function playCallback(Name:String):Void
	{
		FlxG.switchState(new PlayState());
	}
	
	private function hfCallback(Name:String):Void
	{
		FlxG.openURL("http://www.haxeflixel.com");
	}
	
	private function sourceCallback(Name:String):Void
	{
		FlxG.openURL("https://github.com/HaxeFlixel/flixel-addons/blob/master/flixel/addons/api/FlxGameJolt.hx");
	}
	
	private function docCallback(Name:String):Void
	{
		FlxG.openURL("http://gamejolt.com/api/doc/game/");
	}
	
	private function scoresCallback(Name:String):Void
	{
		// stuff
	}
	
	private function switchMenu(Name:String):Void
	{
		if (_loginGroup.visible)
		{
			_input1.text = " ";
			_input2.text = " ";
		}
		
		for (g in _allScreens)
		{
			g.visible = false;
			g.active = false;
		}
		
		if (Name == "Back")
		{
			_main.visible = true;
			_main.active = true;
		}
		
		if (Name == "API Functions")
		{
			_apiTest.visible = true;
			_apiTest.active = true;
		}
		
		if (Name == "Log in")
		{
			_loginGroup.visible = true;
			_loginGroup.active = true;
		}
	}
	
	private function loginCallback(Name:String):Void
	{
		_connection.text = "Attempting to log in...";
		FlxGameJolt.authUser(_input1.text.trim(), _input2.text.trim(), initCallback);
	}
	
	private function mineCallback(Name:String):Void
	{
		
	}
	
	private function apiCallback(Name:String):Void
	{
		_imageDisplay.visible = false;
		_return.text = "Sending " + Name + " request to GameJolt...";
		
		switch (Name)
		{
			case "fetchUser":
				FlxGameJolt.fetchUser(0, FlxGameJolt.username, [], apiReturn);
			case "authUser":
				FlxGameJolt.authUser(FlxGameJolt.username, FlxGameJolt.usertoken, authReturn);
			case "openSession":
				FlxGameJolt.openSession(apiReturn);
			case "pingSession":
				FlxGameJolt.pingSession(true, apiReturn);
			case "closeSession":
				FlxGameJolt.closeSession(apiReturn);
			case "fetchTrophy":
				FlxGameJolt.fetchTrophy(0, apiReturn);
			case "addTrophy":
				FlxGameJolt.addTrophy(5079, apiReturn);
			case "fetchScore":
				FlxGameJolt.fetchScore(10, apiReturn);
			case "addScore":
				FlxGameJolt.addScore(Std.string(Math.round(_mainMenuTime)) + "secondsinmenu", Math.round(_mainMenuTime), 0, false, null, "FlxPongRox", apiReturn);
			case "getTables":
				FlxGameJolt.getTables(apiReturn);
			case "fetchData":
				FlxGameJolt.fetchData("testkey", true, apiReturn);
			case "setData":
				FlxGameJolt.setData("testkey", "IheartBACON", true, apiReturn);
			case "updateData":
				FlxGameJolt.updateData("testkey", "append", "andSAUSAGE", true, apiReturn);
			case "removeData":
				FlxGameJolt.removeData("testkey", true, apiReturn);
			case "getAllKeys":
				FlxGameJolt.getAllKeys(true, apiReturn);
			case "resetUser":
				FlxGameJolt.resetUser(FlxGameJolt.username, FlxGameJolt.usertoken, authReturn);
			case "fetchTrophyImage":
				FlxGameJolt.fetchTrophyImage(5072, apiImageReturn);
			case "fetchAvatarImage":
				FlxGameJolt.fetchAvatarImage(apiImageReturn);
			case "username":
				_return.text = "User name: " + FlxGameJolt.username;
			case "usertoken":
				_return.text = "User token: " + FlxGameJolt.usertoken;
			case "isQuickPlay":
				_return.text = "Was FlxPong loaded via Quick Play? Status: " + FlxGameJolt.isQuickPlay;
			case "isEmbeddedFlash":
				_return.text = "Was FlxPong loaded as embedded Flash on GameJolt? Status: " + FlxGameJolt.isEmbeddedFlash;
			default:
				_return.text = "Sorry, there was an error. :(";
		}
	}
	
	private function apiReturn(ReturnMap:Map<String,String>):Void
	{
		_return.text = "Received from GameJolt:\n" + ReturnMap.toString();
	}
	
	private function apiImageReturn(Bits:BitmapData):Void
	{
		_return.text = "";
		_imageDisplay.loadGraphic(Bits);
		_imageDisplay.visible = true;
	}
	
	private function authReturn(Success:Bool):Void
	{
		_return.text = "The user authentication returned: " + Success;
		
		if (!Success)
		{
			_return.text += ". This is probably because the user is already authenticated! You can use resetUser() to authenticate a new user.";
		}
	}
	
	private function testMove(Name:String):Void
	{
		_apiPages[_apiCurrentPage].visible = false;
		_apiPages[_apiCurrentPage].active = false;
		
		if (Name.charCodeAt(0) == 60)
		{
			_apiCurrentPage--;
		} 
		else if (Name.charCodeAt(0) == 62)
		{
			_apiCurrentPage++;
		}
		
		if (_apiCurrentPage < 0)
			_apiCurrentPage = _apiPages.length - 1;
		
		if (_apiCurrentPage > _apiPages.length - 1)
			_apiCurrentPage = 0;
		
		_apiPages[_apiCurrentPage].visible = true;
		_apiPages[_apiCurrentPage].active = true;
	}
	
	private function initCallback(Result:Bool):Void
	{
		if (_connection != null)
		{
			if (Result)
			{
				if (_connection != null)
				{
					_connection.text = "Successfully connected to GameJolt! Hi " + FlxGameJolt.username + "!";
				}
				
				FlxGameJolt.addTrophy(5072);
				
				if (_login.visible)
				{
					_login.visible = false;
					_login.active = false;
				}
				
				if (_loginGroup.visible == true)
				{
					switchMenu("Back");
				}
				
				//FlxGameJolt.fetchAvatarImage( avatarCallback );
			}
			else
			{
				if (_connection != null)
				{
					_connection.text = "Unable to verify your information with GameJolt.";
				}
				_login.visible = true;
				_login.active = true;
			}
		}
	}
	
	public function createToast(ReturnMap:Dynamic):Void
	{
		var toast:Toast = new Toast(ReturnMap.get("id"));
		add(toast);
	}
}