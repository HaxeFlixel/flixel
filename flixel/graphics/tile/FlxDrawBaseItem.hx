package flixel.graphics.tile;
import flixel.FlxCamera;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawBaseItem<T>
{
	public var nextTyped:T;
	
	public var next:FlxDrawBaseItem<T>;
	
	public var graphics:FlxGraphic;
	public var antialiasing:Bool = false;
	
	public var type:FlxDrawItemType;
	
	public function new() {  }
	
	public function reset():Void
	{
		graphics = null;
		antialiasing = false;
		nextTyped = null;
		next = null;
	}
	
	public function dispose():Void
	{
		graphics = null;
		next = null;
		type = null;
		nextTyped = null;
	}
	
	public function render(camera:FlxCamera):Void {  }
}

enum FlxDrawItemType 
{
	TILES;
	TRIANGLES;
}