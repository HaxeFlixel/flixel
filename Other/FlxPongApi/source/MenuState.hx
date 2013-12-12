package;

import flash.text.TextFieldType;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.text.FlxTextField;
import flixel.ui.FlxButton;
import flixel.addons.api.FlxGameJolt;
import flash.utils.ByteArray;
import flixel.util.FlxMisc;

/**
 * These lines allow embedding of assets as ByteArrays, which helps to minimize the threat of data being compromised.
 * The MOST important one is the private key. Only use the username and user token for debugging.
 * Since "*.privatekey" is added to the .gitignore, none of these will be uploaded to the repository.
 */
@:file("assets/my.privatekey") class MyPrivateKey extends ByteArray { }

#if debug
@:file("assets/username.privatekey") class MyUserName extends ByteArray { }
@:file("assets/usertoken.privatekey") class MyUserToken extends ByteArray { }
#end

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
	
	inline static private function API_TEST_BUTTONS():Array<Array<String>> {
		return [ 	[ "fetchUser", "authUser", "openSession", "pingSession" ],
					[ "closeSession", "fetchTrophy", "addTrophy", "fetchScore" ],
					[ "addScore", "getTables", "fetchData", "setData" ],
					[ "updateData", "removeData", "getAllKeys" ]
				];
	}
	
	override public function create():Void
	{
		Reg.CS = this;
		Reg.genColors();
		//FlxGameJolt.addTrophyCallback( Reg.createToast );
		FlxG.cameras.bgColor = Reg.lite;
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		// The background emitter, connection info, version, and blurb are always present.
		
		var em:Emitter = new Emitter( Std.int( FlxG.width / 2 ), Std.int( FlxG.height / 2 ), 4 );
		
		_connection = new FlxText( 1, 1, FlxG.width, "Connecting to GameJolt..." );
		_connection.color = Reg.med_lite;
		
		var info:FlxText = new FlxText( 0, FlxG.height - 14, FlxG.width, "FlxPong uses HaxeFlixel & FlxGameJolt to use the GameJolt API. Have fun, earn trophies!" );
		info.color = Reg.med_lite;
		info.alignment = "center";
		
		var ver:FlxText = new FlxText( 0, 0, FlxG.width, Reg.VERSION );
		ver.color = Reg.med_lite;
		ver.alignment = "right";
		
		add( em );
		add( _connection );
		add( info );
		add( ver );
		
		// Set up the "main" screen/buttons.
		
		_main = new FlxGroup();
		
		var title:FlxText = new FlxText( 0, 20, FlxG.width, "FlxPong!", 16 );
		title.color = Reg.med_dark;
		title.alignment = "center";
		
		var play:Button = new Button( 0, 50, "Play!", playCallback );
		Reg.quarterX( play, 2 );
		
		_login = new Button( 0, 50, "Log in", switchMenu, 60 );
		Reg.quarterX( _login, 3 );
		_login.visible = false;
		_login.active = false;
		
		var test:Button = new Button( 0, 80, "API Functions", switchMenu );
		Reg.quarterX( test, 1 );
		
		var high:Button = new Button( 0, 80, "High Scores", scoresCallback );
		Reg.quarterX( high, 2 );
		
		var mine:Button = new Button( 0, 80, "My Scores", mineCallback );
		Reg.quarterX( mine, 3 );
		
		var source:Button = new Button( 0, 110, "FlxGameJolt Source", sourceCallback, 120 );
		Reg.quarterX( source, 1 );
		
		var hf:Button = new Button( 0, 110, "HaxeFlixel.com", hfCallback );
		Reg.quarterX( hf, 2 );
		
		var doc:Button = new Button( 0, 110, "FlxGameJolt Usage", docCallback, 120 );
		Reg.quarterX( doc, 3 );
		
		_main.add( title );
		_main.add( play );
		_main.add( _login );
		_main.add( test );
		//_main.add( high );
		//_main.add( mine );
		_main.add( source );
		_main.add( hf );
		_main.add( doc );
		
		// End main group.
		
		// Set up the "high scores" screen.
		
		_highScores = new FlxGroup();
		
		// End high scores.
		
		// Set up the API test screen.
		
		_apiTest = new FlxGroup();
		
		var xpos:Int = 10;
		var ypos:Array<Int> = [ 20, 42, 64, 86, 108, 130 ];
		
		// Set up the pages of this screen.
		
		_apiPages = [];
		_apiCurrentPage = 0;
		
		for ( i in 0...API_TEST_BUTTONS().length ) {
			_apiPages.push( new FlxGroup() );
			
			var button1:Button;
			var button2:Button;
			var button3:Button;
			var button4:Button;
			
			if ( API_TEST_BUTTONS()[i][0] != null ) {
				button1 = new Button( xpos, ypos[0], API_TEST_BUTTONS()[i][0], apiCallback );
				_apiPages[i].add( button1 );
			}
			
			if ( API_TEST_BUTTONS()[i][1] != null ) {
				button2 = new Button( xpos, ypos[1], API_TEST_BUTTONS()[i][1], apiCallback );
				_apiPages[i].add( button2 );
			}
			
			if ( API_TEST_BUTTONS()[i][2] != null ) {
				button3 = new Button( xpos, ypos[2], API_TEST_BUTTONS()[i][2], apiCallback );
				_apiPages[i].add( button3 );
			}
			
			if ( API_TEST_BUTTONS()[i][3] != null ) {
				button4 = new Button( xpos, ypos[3], API_TEST_BUTTONS()[i][3], apiCallback );
				_apiPages[i].add( button4 );
			}
			
			_apiPages[i].visible = false;
			_apiPages[i].active = false;
		}
		
		// We do want to see the first page, once apiTest is added
		
		_apiPages[0].visible = true;
		_apiPages[0].active = true;
		
		// Add elements aside from the per-screen buttons
		
		var prev:Button = new Button( xpos, ypos[4], "<<", testMove, 39 );
		var next:Button = new Button( xpos + 80 - 39, ypos[4], ">>", testMove, 39 );
		var testSpace:PongSprite = new PongSprite( xpos + 90, ypos[0], FlxG.width - 10 - xpos - 90, ypos[4] + 20 - ypos[0], Reg.med_lite );
		_return = new FlxText( testSpace.x + 4, testSpace.y + 4, Std.int( testSpace.width - 8 ), "Return data will display here." );
		_return.color = Reg.lite;
		var exit:Button = new Button( Std.int( testSpace.x + testSpace.width - 40 ), Std.int( testSpace.y + testSpace.height - 20 ), "Back", switchMenu, 40 );
		
		// Add everything to this screen
		
		for ( g in _apiPages ) {
			_apiTest.add( g );
		}
		
		_apiTest.add( prev );
		_apiTest.add( next );
		_apiTest.add( testSpace );
		_apiTest.add( _return );
		_apiTest.add( exit );
		
		_apiTest.active = false;
		_apiTest.visible = false;
		
		// End API test.
		
		// Login screen
		
		_loginGroup = new FlxGroup();
		
		var instruct:FlxText = new FlxText( 0, 50, FlxG.width, "Log in to GameJolt to get trophies and stuff:" );
		instruct.alignment = "center";
		instruct.color = Reg.med_dark;
		
		var word1:FlxText = new FlxText( 0, 70, 60, "Username:" );
		var word2:FlxText = new FlxText( 0, 90, 60, "Token:" );
		Reg.quarterX( word1, 1 );
		Reg.quarterX( word2, 1 );
		word1.color = word2.color = Reg.med_dark;
		
		_input1 = new FlxTextField( 0, 70, 240, " " );
		_input2 = new FlxTextField( 0, 90, 240, " " );
		Reg.quarterX( _input1, 3 );
		Reg.quarterX( _input2, 3 );
		_input2.color = _input1.color = Reg.med_lite;
		_input2.textField.selectable = _input1.textField.selectable = true;
		_input2.textField.multiline = _input1.textField.multiline = false;
		_input2.textField.wordWrap = _input1.textField.wordWrap = false;
		_input2.textField.maxChars = _input1.textField.maxChars = 30;
		_input2.textField.restrict = _input1.textField.restrict = "A-Za-z0-9_";
		_input2.textField.type = _input1.textField.type = TextFieldType.INPUT;
		var input1bg:PongSprite = new PongSprite( Std.int( _input1.x ), Std.int( _input1.y ), Std.int( _input1.width - 40 ), Std.int( _input1.height + 4 ), Reg.dark );
		var input2bg:PongSprite = new PongSprite( Std.int( _input2.x ), Std.int( _input2.y ), Std.int( _input2.width - 40 ), Std.int( _input2.height + 4 ), Reg.dark );
		var trylogin:Button = new Button( 0, 110, "Log in", loginCallback );
		Reg.quarterX( trylogin, 2 );
		var back:Button = new Button( 400, 108, "Back", switchMenu, 40 );
		
		_loginGroup.add( word1 );
		_loginGroup.add( word2 );
		_loginGroup.add( input1bg );
		_loginGroup.add( input2bg );
		_loginGroup.add( _input1 );
		_loginGroup.add( _input2 );
		_loginGroup.add( instruct );
		_loginGroup.add( trylogin );
		_loginGroup.add( back );
		
		_loginGroup.active = false;
		_loginGroup.visible = false;
		
		// End Login.
		
		_allScreens = new FlxGroup();
		_allScreens.add( _main );
		_allScreens.add( _apiTest );
		_allScreens.add( _loginGroup );
		
		add( _allScreens );
		
		em.start( false );
		
		var ba:ByteArray = new MyPrivateKey();
		
		#if debug
		var name:ByteArray = new MyUserName();
		var token:ByteArray = new MyUserToken();
		FlxGameJolt.init( Reg.GAME_ID, ba.readUTFBytes( ba.length ), true, name.readUTFBytes( name.length ), token.readUTFBytes( token.length ), initCallback );
		#else
		FlxGameJolt.init( Reg.GAME_ID, ba.readUTFBytes( ba.length ), true, null, null, initCallback );
		#end
		
		#if debug
		//var newcol:Button = new Button( FlxG.width - 10, 0, "C", colorCallback, 10 );
		//add( newcol );
		#end
		
		super.create();
	}
	
	override public function update():Void
	{
		_mainMenuTime += FlxG.elapsed;
		
		super.update();
	}
	
	#if debug
	private function colorCallback( Name:String ):Void
	{
		Reg.genColors();
		FlxG.switchState( new MenuState() );
	}
	#end
	
	private function playCallback( Name:String ):Void
	{
		FlxG.switchState( new PlayState() );
	}
	
	private function hfCallback( Name:String ):Void
	{
		FlxMisc.openURL( "http://www.haxeflixel.com" );
	}
	
	private function sourceCallback( Name:String ):Void
	{
		FlxMisc.openURL( "https://github.com/HaxeFlixel/flixel-addons/blob/master/flixel/addons/api/FlxGameJolt.hx" );
	}
	
	private function docCallback( Name:String ):Void
	{
		FlxMisc.openURL( " http://www.steverichey.com/dev/flxgamejolt" );
	}
	
	private function scoresCallback( Name:String ):Void
	{
		// stuff
	}
	
	private function switchMenu( Name:String ):Void
	{
		if ( _loginGroup.visible ) {
			_input1.text = " ";
			_input2.text = " ";
		}
		
		for ( g in _allScreens.members ) {
			g.visible = false;
			g.active = false;
		}
		
		if ( Name == "Back" ) {
			_main.visible = true;
			_main.active = true;
		}
		
		if ( Name == "API Functions" ) {
			_apiTest.visible = true;
			_apiTest.active = true;
		}
		
		if ( Name == "Log in" ) {
			_loginGroup.visible = true;
			_loginGroup.active = true;
		}
	}
	
	private function loginCallback( Name:String ):Void
	{
		_connection.text = "Attempting to log in...";
		FlxGameJolt.authUser( StringTools.trim( _input1.text ), StringTools.trim( _input2.text ), initCallback );
	}
	
	private function mineCallback( Name:String ):Void
	{
		
	}
	
	private function apiCallback( Name:String ):Void
	{
		_return.text = "Sending " + Name + " request to GameJolt...";
		
		switch ( Name ) {
			case "fetchUser":
				FlxGameJolt.fetchUser( 0, FlxGameJolt.username, [], apiReturn );
			case "authUser":
				FlxGameJolt.authUser( null, null, authReturn );
			case "openSession":
				FlxGameJolt.openSession( apiReturn );
			case "pingSession":
				FlxGameJolt.pingSession( true, apiReturn );
			case "closeSession":
				FlxGameJolt.closeSession( apiReturn );
			case "fetchTrophy":
				FlxGameJolt.fetchTrophy( 0, apiReturn );
			case "addTrophy":
				FlxGameJolt.addTrophy( 5079, apiReturn );
			case "fetchScore":
				FlxGameJolt.fetchScore( 10, apiReturn );
			case "addScore":
				FlxGameJolt.addScore( Std.string( _mainMenuTime ) + " seconds in menu", _mainMenuTime, false, null, "FlxPong is a great game.", 0, apiReturn );
			case "getTables":
				FlxGameJolt.getTables( apiReturn );
			case "fetchData":
				FlxGameJolt.fetchData( "testkey", true, apiReturn );
			case "setData":
				FlxGameJolt.setData( "testkey", "I like bacon quite a bit.", true, apiReturn );
			case "updateData":
				FlxGameJolt.updateData( "testkey", "append", " But sausage is nice too.", true, apiReturn );
			case "removeData":
				FlxGameJolt.removeData( "testkey", true, apiReturn );
			case "getAllKeys":
				FlxGameJolt.getAllKeys( true, apiReturn );
			default:
				_return.text = "Sorry, there was an error. :(";
		}
	}
	
	private function apiReturn( ReturnMap:Map<String,String> ):Void
	{
		_return.text = "Received from GameJolt:\n" + ReturnMap.toString();
	}
	
	private function authReturn( Success:Bool ):Void
	{
		_return.text = "The user authentication returned: " + Success;
	}
	
	private function testMove( Name:String ):Void
	{
		_apiPages[ _apiCurrentPage ].visible = false;
		_apiPages[ _apiCurrentPage ].active = false;
		
		if ( Name.charCodeAt( 0 ) == 60 ) {
			_apiCurrentPage--;
		} else if ( Name.charCodeAt( 0 ) == 62 ) {
			_apiCurrentPage++;
		}
		
		if ( _apiCurrentPage < 0 ) {
			_apiCurrentPage = _apiPages.length - 1;
		}
		
		if ( _apiCurrentPage > _apiPages.length - 1 ) {
			_apiCurrentPage = 0;
		}
		
		_apiPages[ _apiCurrentPage ].visible = true;
		_apiPages[ _apiCurrentPage ].active = true;
	}
	
	private function initCallback( Result:Bool ):Void
	{
		if ( _connection != null ) {
			if ( Result ) {
				if ( _connection != null ) {
					_connection.text = "Successfully connected to GameJolt! Hi " + FlxGameJolt.username + "!";
				}
				
				//FlxGameJolt.addTrophy( 5072 );
				
				if ( _login.visible ) {
					_login.visible = false;
					_login.active = false;
				}
				
				if ( _loginGroup.visible == true ) {
					switchMenu( "Back" );
				}
			} else {
				if ( _connection != null ) {
					_connection.text = "Unable to verify your information with GameJolt.";
				}
				_login.visible = true;
				_login.active = true;
			}
		}
	}
	
	public function createToast( ReturnMap:Dynamic ):Void
	{
		var toast:Toast = new Toast( ReturnMap.get( "id" ) );
		add( toast );
	}
}