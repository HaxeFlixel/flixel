package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
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
	
	override public function create():Void
	{
		FlxG.cameras.bgColor = Reg.LITE;
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		Reg.CS = this;
		
		var em:Emitter = new Emitter( Std.int( FlxG.width / 2 ), Std.int( FlxG.height / 2 ), 4 );
		
		_connection = new FlxText( 1, 1, FlxG.width, "Connecting to GameJolt..." );
		_connection.color = Reg.MED_LITE;
		
		var title:FlxText = new FlxText( 0, 20, FlxG.width, "FlxPong!", 16 );
		title.color = Reg.MED_DARK;
		title.alignment = "center";
		
		var play:Button = new Button( 0, 80, "Play!", playCallback );
		Reg.centerX( play );
		
		var source:Button = new Button( 0, 110, "FlxGameJolt Source", sourceCallback, 120 );
		Reg.quarterX( source );
		
		var hf:Button = new Button( 0, 110, "HaxeFlixel.com", hfCallback );
		Reg.centerX( hf );
		
		var doc:Button = new Button( 0, 110, "FlxGameJolt Usage", docCallback, 120 );
		Reg.quarterX( doc, 3 );
		
		var info:FlxText = new FlxText( 0, FlxG.height - 14, FlxG.width, "FlxPong uses HaxeFlixel & FlxGameJolt to use the GameJolt API. Have fun, earn trophies!" );
		info.color = Reg.MED_LITE;
		info.alignment = "center";
		
		add( em );
		add( _connection );
		add( title );
		add( play );
		add( source );
		add( hf );
		add( info );
		add( doc );
		
		em.start( false );
		
		var ba:ByteArray = new MyPrivateKey();
		
		#if debug
		var name:ByteArray = new MyUserName();
		var token:ByteArray = new MyUserToken();
		FlxGameJolt.init( Reg.GAME_ID, ba.readUTFBytes( ba.length ), true, name.readUTFBytes( name.length ), token.readUTFBytes( token.length ), initCallback );
		#else
		FlxGameJolt.init( Reg.GAME_ID, ba.readUTFBytes( ba.length ), true, null, null, initCallback );
		#end
		
		super.create();
	}
	
	override public function update():Void
	{
		super.update();
	}
	
	private function playCallback():Void
	{
		FlxG.switchState( new PlayState() );
	}
	
	private function hfCallback():Void
	{
		FlxMisc.openURL( "http://www.haxeflixel.com" );
	}
	
	private function sourceCallback():Void
	{
		FlxMisc.openURL( "https://github.com/HaxeFlixel/flixel-addons/blob/master/flixel/addons/api/FlxGameJolt.hx" );
	}
	
	private function docCallback():Void
	{
		FlxMisc.openURL( " http://www.steverichey.com/dev/flxgamejolt" );
	}
	
	private function initCallback( m:Map<String,String> ):Void
	{
		if ( m.exists( "success" ) && m.get( "success" ) == "true" ) {
			_connection.text = "Successfully connected to GameJolt API! Hi " + FlxGameJolt.username + "!";
			FlxGameJolt.addAchievedTrophy( 5072, Reg.trophyToast );
		} else {
			_connection.text = "Unable to connect to the GameJolt API! :(";
		}
	}
}