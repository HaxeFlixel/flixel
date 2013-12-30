package;

import flash.display.BlendMode;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxPoint;
import flixel.util.FlxColor;
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
	
	/**
	 * Creates the title menu screen.
	 */
	override public function create():Void
	{
		#if (mobile || js)
		FlxG.mouse.hide();
		#else
		// Change the default mouse to an inverted triangle.
		FlxG.mouse.show( "images/mouse.png" );
		#if !(cpp || neko)
		FlxG.mouse.cursorContainer.blendMode = BlendMode.INVERT;
		#end
		#end
		
		FlxG.cameras.bgColor = FlxColor.WHITE;
		
		// Load a map from CSV data; note that the tile graphic does not need to be a file; in this case, it's BitmapData.
		
		_map = new FlxTilemap();
		_map.loadMap( Assets.getText( "tilemaps/menu_tilemap.csv" ), Reg.tileImage );
		
		// Game title
		
		var headline:FlxText = new FlxText(0, 40, FlxG.width, "Minimalist TD", 16);
		headline.alignment = "center";
		
		// Credits
		
		var credits:FlxText = new FlxText(2, FlxG.height - 12, FlxG.width, "Made in 48h for Ludum Dare 26 by Gama11");
		
		// Play button
		
		var playButton:Button = new Button( 0, Std.int( FlxG.height / 2 ), "[P]lay", playButtonCallback );
		playButton.x = Std.int( ( FlxG.width - playButton.width ) / 2 );
		
		// The enemy that repeatedly traverses the screen.
		
		_enemy = new Enemy( START_X, START_Y );
		enemyFollowPath();
		
		// Add everything to the state
		
		add( _map );
		add( headline );
		add( credits );
		add( playButton );
		add( _enemy );
		
		super.create();
	}
	
	/**
	 * Activated when clicking "Play" or pressing P; switches to the playstate.
	 */
	private function playButtonCallback():Void
	{
		FlxG.switchState( new PlayState() );
	}
	
	override public function update():Void
	{
		// Check if the enemy has reached the end of the path yet
		
		if ( _enemy.y >= 28 * TILE_SIZE ) {
			// If so, reset them to the beginning of the path
			enemyFollowPath();
		}
		
		// Begin the game on a P keypress.
		
		if ( FlxG.keys.justReleased.P ) {
			playButtonCallback();
		}
		
		super.update();
	}
	
	/**
	 * Starts the enemy on the map path.
	 */
	public function enemyFollowPath():Void
	{
		_enemy.followPath( _map.findPath( new FlxPoint( START_X, START_Y ), new FlxPoint( END_X, END_Y ) ) );
	}
	
	override public function destroy():Void
	{
		_enemy = null;
		_map = null;
		
		super.destroy();
	}
}