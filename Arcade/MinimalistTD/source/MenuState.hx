package;

import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.tile.FlxTilemap;
import Reg.TILE_SIZE;

class MenuState extends FlxState
{
	private var startPosition = FlxPoint.get(TILE_SIZE * 5 + 4, 0);
	private var endPosition = FlxPoint.get(34 * TILE_SIZE + 2, 28 * TILE_SIZE);
	
	private var _enemy:Enemy;
	private var _map:FlxTilemap;
	
	/**
	 * Creates the title menu screen.
	 */
	override public function create():Void
	{
		// Change the default mouse to an inverted triangle.
		FlxG.mouse.load("images/mouse.png");
		#if flash
		FlxG.mouse.cursorContainer.blendMode = BlendMode.INVERT;
		#end
		
		FlxG.cameras.bgColor = FlxColor.WHITE;
		FlxG.timeScale = 1;
		
		// Load a map from CSV data; note that the tile graphic does not need to be a file; in this case, it's BitmapData.
		_map = new FlxTilemap();
		_map.loadMapFromCSV("tilemaps/menu_tilemap.csv", Reg.tileImage);
		
		// Game title
		var headline = new FlxText(0, 40, FlxG.width, "Minimalist TD", 16);
		headline.alignment = CENTER;
		
		// Credits
		var credits = new FlxText(2, FlxG.height - 12, FlxG.width, "Made in 48h for Ludum Dare 26 by Gama11");
		
		// Play button
		var playButton = new Button(0, 0, "[P]lay", startGame);
		playButton.screenCenter();
		
		// The enemy that repeatedly traverses the screen.
		_enemy = new Enemy();
		enemyFollowPath();
		
		// Add everything to the state
		add(_map);
		add(headline);
		add(credits);
		add(playButton);
		add(_enemy);
		
		super.create();
	}
	
	/**
	 * Activated when clicking "Play" or pressing P; switches to the playstate.
	 */
	private function startGame():Void
	{
		FlxG.switchState(new PlayState());
	}
	
	override public function update(elapsed:Float):Void
	{
		// Begin the game on a P keypress.
		if (FlxG.keys.justReleased.P)
			startGame();
		
		super.update(elapsed);
	}
	
	/**
	 * Starts the enemy on the map path.
	 */
	public function enemyFollowPath(?_):Void
	{
		_enemy.setPosition(startPosition.x, startPosition.y - 12);
		var path:Array<FlxPoint> = _map.findPath(startPosition, endPosition);
		var lastPoint = path[path.length - 1];
		lastPoint.x = path[path.length - 2].x;
		lastPoint.y += 20;
		_enemy.followPath(path, 50, enemyFollowPath);
	}
}