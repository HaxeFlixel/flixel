package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
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
	private var _apiPages:Array<FlxGroup>;
	private var _apiCurrentPage:Int;
	
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
		
		FlxG.cameras.bgColor = Reg.lite;
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		// The background emitter, connection info, and blurb are always present.
		
		var em:Emitter = new Emitter( Std.int( FlxG.width / 2 ), Std.int( FlxG.height / 2 ), 4 );
		
		_connection = new FlxText( 1, 1, FlxG.width, "Connecting to GameJolt..." );
		_connection.color = Reg.med_lite;
		
		var info:FlxText = new FlxText( 0, FlxG.height - 14, FlxG.width, "FlxPong uses HaxeFlixel & FlxGameJolt to use the GameJolt API. Have fun, earn trophies!" );
		info.color = Reg.med_lite;
		info.alignment = "center";
		
		add( em );
		add( _connection );
		add( info );
		
		// Set up the "main" screen/buttons.
		
		_main = new FlxGroup();
		
		var title:FlxText = new FlxText( 0, 20, FlxG.width, "FlxPong!", 16 );
		title.color = Reg.med_dark;
		title.alignment = "center";
		
		var play:Button = new Button( 0, 50, "Play!", playCallback );
		Reg.quarterX( play, 2 );
		
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
		_main.add( test );
		_main.add( high );
		_main.add( mine );
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
		
		add( _main );
		add( _apiTest );
		
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
		var newcol:Button = new Button( FlxG.width - 10, 0, "C", colorCallback, 10 );
		add( newcol );
		#end
		
		super.create();
	}
	
	override public function update():Void
	{
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
		if ( Name == "Back" ) {
			_main.visible = true;
			_main.active = true;
		} else {
			_main.visible = false;
			_main.active = false;
		}
		
		if ( Name == "API Functions" ) {
			_apiTest.visible = true;
			_apiTest.active = true;
		} else {
			_apiTest.visible = false;
			_apiTest.active = false;
		}
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
				//this is disabled for now, i might remove it from this screen
				//FlxGameJolt.authUser( null, null, apiReturn );
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
				//FlxGameJolt.addScore( Std.string(
			default:
				_return.text = "Sorry, there was an error. :(";
		}
	}
	
	private function apiReturn( ReturnMap:Map<String,String> ):Void
	{
		_return.text = "Received from GameJolt:\n" + ReturnMap.toString();
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
		if ( Result ) {
			_connection.text = "Successfully connected to GameJolt API! Hi " + FlxGameJolt.username + "!";
			FlxGameJolt.fetchTrophy( 0, trophiesFetched );
			
			//FlxGameJolt.addAchievedTrophy( 5072, trophyToast );
		} else {
			_connection.text = "Unable to connect to the GameJolt API! :(";
		}
	}
	
	private function trophyToast( ResultMap:Map<String,String> ):Void
	{
		trace( ResultMap );
		var toast:Toast = new Toast( 5072 );
		add( toast );
	}
	
	private function trophiesFetched( ResultMap:Map<String,String> ):Void
	{
		Reg.trophyMap = ResultMap;
		FlxGameJolt.addTrophy( 5072, trophyToast );
	}
}