package;

import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;

/**
 * ...
 * @author Zaphod
 */
class MenuState extends FlxState
{
	
	override public function create():Void 
	{
		var t:FlxText;
		t = new FlxText(0, FlxG.height / 2 - 20, FlxG.width, "FlxTeroids");
		t.size = 32;
		t.alignment = "center";
		add(t);
		
		t = new FlxText(0, FlxG.height - 30, FlxG.width, "click to play");
		t.size = 16;
		t.alignment = "center";
		add(t);
		
		FlxG.mouse.show();
	}
	
	override public function update():Void 
	{
		if (FlxG.mouse.justPressed())
		{
			FlxG.switchState(new PlayState());
		}
	}
	
}