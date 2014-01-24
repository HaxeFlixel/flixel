package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * ...
 * @author Zaphod
 */
class MenuState extends FlxState
{
	override public function create():Void 
	{
		FlxG.mouse.visible = true;
		
		var t:FlxText;
		t = new FlxText(0, FlxG.height / 2 - 20, FlxG.width, "FlxTeroids");
		t.setFormat(null, 32, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE);
		add(t);
		
		t = new FlxText(0, FlxG.height - 30, FlxG.width, "click to play");
		t.setFormat(null, 16, FlxColor.WHITE, "center", FlxText.BORDER_OUTLINE);
		add(t);
	}
	
	override public function update():Void 
	{
		if (FlxG.mouse.justPressed)
		{
			FlxG.switchState(new PlayState());
		}
	}
}