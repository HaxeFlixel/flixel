package;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

/**
 * @author Joe Williamson
 */
class DemoPanel extends FlxSpriteGroup
{
	public var titleText:FlxText;
	
	public function new(title:String)
	{
		super();
		
		titleText = new FlxText(2, 2, 0, title, 16);
		add(titleText);
	}
}