package flixel.graphics.tile;
import flixel.FlxCamera;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawBaseItem
{
	public var next:FlxDrawBaseItem;
	
	public var graphics:FlxGraphic;
	public var initialized:Bool = false;
	public var antialiasing:Bool = false;
	
	public var type:FlxDrawItemType;
	
	public function new() {  }
	
	public function reset():Void
	{
		graphics = null;
		antialiasing = false;
		initialized = false;
	}
	
	public function dispose():Void
	{
		graphics = null;
		next = null;
		type = null;
	}
	
	public function render(camera:FlxCamera):Void {  }
}

enum FlxDrawItemType 
{
	TILES;
	TRIANGLES;
}