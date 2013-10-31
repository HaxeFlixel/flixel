package;
 
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
 
/**
 * ...
 * @author .:BuzzJeux:.
 */
class PlayState extends FlxState
{
	public var player:Player;
	public var _level:TiledLevel;
	private var _howto:FlxText;
	
	override public function create():Void
	{
		//Set the background color
		bgColor = 0xff000000;
		
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		// Load the level's tilemaps
		_level = new TiledLevel("assets/data/map.tmx");
		
		// Add tilemaps
		add(_level.backgroundTiles);
		
		// Add tilemaps
		add(_level.foregroundTiles);
		
		// Load player and objects of the Tiled map
		_level.loadObjects(this);
		
		// Set and create Txt Howto
		_howto = new FlxText(FlxG.width / 2 - 93, 225, 374).setFormat(null, 8, 0xffffff, 'left');
		_howto.text = "Use the ARROW KEYS to move around.";
		_howto.scrollFactor.set(0, 0);
		add(_howto);
	}
	
	override public function update():Void
	{
		super.update();
		
		// Collide with foreground tile layer
		if (_level.collideWithLevel(player))
		{
			player.moveToNextTile = false;
		}
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		player = null;
		_level = null;
		_howto = null;
	}
}