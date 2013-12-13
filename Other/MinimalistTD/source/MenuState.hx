package;

import flash.display.BlendMode;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxPoint;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;

class MenuState extends FlxState
{
	inline static private var TILE_SIZE:Int = 8;
	inline static private var START_X:Int = TILE_SIZE * 5 + 1;
	inline static private var START_Y:Int = 0;
	inline static private var END_X:Int = 34 * TILE_SIZE + 2;
	inline static private var END_Y:Int = 29 * TILE_SIZE;
	
	private var _enemy:Enemy;
	private var _map:FlxTilemap;
	
	override public function create():Void
	{
		#if mobile
		FlxG.mouse.hide();
		#else
		FlxG.mouse.show( "images/mouse.png" );
		FlxG.mouse.cursorContainer.blendMode = BlendMode.INVERT;
		#end
		
		FlxG.cameras.bgColor = FlxColor.WHITE;
		
		_map = new FlxTilemap();
		_map.loadMap( Assets.getText( "tilemaps/menu_tilemap.csv" ), "images/tileset.png" );
		
		var headline:FlxText = new FlxText(0, 40, FlxG.width, "Minimalist TD", 16);
		headline.alignment = "center";
		
		var credits:FlxText = new FlxText(2, FlxG.height - 12, FlxG.width, "Made in 48h for Ludum Dare 26 by Gama11");
		
		var playButton:Button = new Button( 0, Std.int( FlxG.height / 2 ), "[P]lay", playButtonCallback );
		playButton.x = Std.int( ( FlxG.width - playButton.width ) / 2 );
		
		_enemy = new Enemy( START_X, START_Y );
		_enemy.followPath( getMapPath() );
		
		add( _map );
		add( headline );
		add( credits );
		add( playButton );
		add( _enemy );
	}
	
	private function playButtonCallback():Void
	{
		FlxG.switchState( new PlayState() );
	}
	
	override public function update():Void
	{
		// Check if the enemy has reached the end of the path yet
		
		if ( _enemy.y >= 28 * TILE_SIZE ) {
			// If so, reset them to the beginning of the path
			_enemy.followPath( getMapPath() );
		}
		
		if ( FlxG.keys.justReleased.P ) {
			playButtonCallback();
		}
		
		super.update();
	}
	
	public function getMapPath():Array<FlxPoint>
	{
		return _map.findPath( new FlxPoint( START_X, START_Y ), new FlxPoint( END_X, END_Y ) );
	}
	
	override public function destroy():Void
	{
		_enemy = null;
		_map = null;
		
		super.destroy();
	}
}