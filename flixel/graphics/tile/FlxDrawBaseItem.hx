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
	public var colored:Bool = false;
	public var blending:Int = 0;
	
	public var type:FlxDrawItemType;
	
	public var numVertices(get, never):Int;
	
	public var numTriangles(get, never):Int;
	
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
	
	private function get_numVertices():Int
	{
		return 0;
	}
	
	private function get_numTriangles():Int
	{
		return 0;
	}
}

enum FlxDrawItemType 
{
	TILES;
	TRIANGLES;
}