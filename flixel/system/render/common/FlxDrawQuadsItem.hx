package flixel.system.render.common;
import flixel.system.render.common.DrawItem.FlxDrawItemType;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawQuadsItem extends FlxDrawBaseItem<FlxDrawQuadsItem>
{

	public function new() 
	{
		super();
		type = FlxDrawItemType.TILES;
	}
	
}