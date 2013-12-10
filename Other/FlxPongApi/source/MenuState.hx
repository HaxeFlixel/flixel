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
		
		var test:Button = new Button( 0, 80, "API Functions", testCallback );
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
		
		_main.visible = false;
		
		// End main group.
		
		// Set up the "high scores" screen.
		
		_highScores = new FlxGroup();
		
		// End high scores.
		
		// Set up the API test screen.
		
		_apiTest = new FlxGroup();
		
		var xpos:Int = 10;
		var ypos:Array<Int> = [ 20, 42, 64, 86, 108, 130 ];
		
		// Set up the first page of this screen.
		
		var page1:FlxGroup = new FlxGroup();
		
		var fetchUser:Button = new Button( xpos, ypos[0], "fetchUser", apiCallback );
		var authUser:Button = new Button( xpos, ypos[1], "authUser", apiCallback );
		var openSession:Button = new Button( xpos, ypos[2], "openSession", apiCallback );
		var pingSession:Button = new Button( xpos, ypos[3], "pingSession", apiCallback );
		
		page1.add( fetchUser );
		page1.add( authUser );
		page1.add( openSession );
		page1.add( pingSession );
		
		page1.visible = false;
		
		var page2:FlxGroup = new FlxGroup();
		
		var closeSession:Button = new Button( xpos, ypos[0], "closeSession", apiCallback );
		
		page2.add( closeSession );
		
		page2.visible = false;
		
		// We start on page 1.
		
		page1.visible = true;
		
		// Add elements aside from the per-screen buttons
		
		var prev:Button = new Button( xpos, ypos[4], "<", testMove, 30 );
		var next:Button = new Button( xpos + 80 - 30, ypos[4], ">", testMove, 30 );
		var testSpace:PongSprite = new PongSprite( xpos + 90, ypos[0], FlxG.width - 10 - xpos - 90, ypos[4] + 20 - ypos[0], Reg.med_lite );
		_return = new FlxText( testSpace.x + 4, testSpace.y + 4, Std.int( testSpace.width - 8 ), "Return data will display here." );
		_return.color = Reg.lite;
		
		// Add everything to the screen
		
		_apiTest.add( page1 );
		_apiTest.add( page2 );
		_apiTest.add( prev );
		_apiTest.add( next );
		_apiTest.add( testSpace );
		_apiTest.add( _return );
		
		_apiTest.visible = false;
		
		// End API return.
		
		add( _main );
		add( _apiTest );
		// add ( _highScores );
		
		// Initially we can see the main menu.
		
		_main.visible = true;
		
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
	
	private function testCallback( Name:String ):Void
	{
		_main.visible = false;
		_apiTest.visible = true;
	}
	
	private function mineCallback( Name:String ):Void
	{
		
	}
	
	private function apiCallback( Name:String ):Void
	{
		trace( "Button label: " + Name + "..." );
	}
	
	private function testMove( Name:String ):Void
	{
		trace( "Button label: " + Name + "..." );
	}
	
	private function initCallback( m:Map<String,String> ):Void
	{
		if ( m.exists( "success" ) && m.get( "success" ) == "true" ) {
			_connection.text = "Successfully connected to GameJolt API! Hi " + FlxGameJolt.username + "!";
			FlxGameJolt.addAchievedTrophy( 5072 );
		} else {
			_connection.text = "Unable to connect to the GameJolt API! :(";
		}
	}
}