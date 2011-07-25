package;

import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;

/**
 * ...
 * @author Zaphod
 */
class MenuState extends FlxState
{
	
	public function new() 
	{
		super();	
	}
	
	override public function create():Void 
	{
		FlxG.framerate = 30;
		FlxG.flashFramerate = 30;
		FlxG.bgColor = 0xffffffff;
		var back:FlxSprite = new FlxSprite(0, 0);
		back.makeGraphic(320, 240, 0xffffffff);
		//add(back);
		trace("Hello");
		var logo:FlxText = new FlxText(FlxG.width * 0.5 - 200, 250, 400, "INVADERS", false);
		logo.setFormat(null, 40, 0xff000000, "center");
		add(logo);
		trace(logo.color);
		
		var instruct:FlxText = new FlxText(FlxG.width * 0.5 - 200, 320, 400, "PRESS [x] TO START", false);
		//instruct.setFormat(null, 20, 0xff000000, "center");
		add(instruct);
	}
	
	override public function update():Void 
	{
		if (FlxG.keys.X)
		{
			FlxG.switchState(new MainState());
		}
		super.update();
	}
	
}