package;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.addons.api.FlxGameJolt;

class MenuState extends FlxState
{
	private var _connection:FlxText;
	
	override public function create():Void
	{
		FlxG.cameras.bgColor = Reg.LITE;
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		_connection = new FlxText( 1, 1, 50, "Connecting to GameJolt..." );
		_connection.color = Reg.MED_LITE;
		
		var title:FlxText = new FlxText( 0, 20, FlxG.width, "FlxPong!", 16 );
		title.color = Reg.MED_DARK;
		title.alignment = "center";
		
		var play:Button = new Button( 0, 80, "Play!", playCallback );
		Reg.centerX( play );
		
		var info:FlxText = new FlxText( 0, FlxG.height - 14, FlxG.width, "FlxPong uses HaxeFlixel & FlxGameJolt to use the GameJolt API. Have fun, earn trophies!" );
		info.color = Reg.MED_LITE;
		info.alignment = "center";
		
		add( _connection );
		add( title );
		add( play );
		add( info );
		
		FlxGameJolt.
		
		super.create();
	}
	
	override public function update():Void
	{
		
		
		super.update();
	}
	
	private function playCallback():Void
	{
		FlxG.log.add( "bacon" );
	}
}