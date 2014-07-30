package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	override public function create():Void 
	{
		var t:FlxText;
		t = new FlxText(0, FlxG.height / 2 - 20, FlxG.width, "FlxTeroids");
		t.setFormat(null, 32, FlxColor.WHITE, CENTER, OUTLINE);
		add(t);
		
		t = new FlxText(0, FlxG.height - 30, FlxG.width, "space to play");
		t.setFormat(null, 16, FlxColor.WHITE, CENTER, OUTLINE);
		add(t);
	}
	
	override public function update():Void 
	{
		if (FlxG.keys.justReleased.SPACE)
		{
			FlxG.switchState(new PlayState());
		}
	}
}