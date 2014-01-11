package ;
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
		FlxG.cameras.bgColor = FlxColor.GRAY;
		
		var text:FlxText = new FlxText(0, 0.5 * FlxG.height, FlxG.width, "Press any button on your gamepad, so we can detect it", 16);
		text.setFormat(null, 16, 0x000000, "center");
		add(text);
		
		super.create();
	}
	
	override public function update():Void 
	{
		#if (cpp || neko)
		if (FlxG.gamepads.anyButton())
		{
			FlxG.switchState(new PlayState());
		}
		#end
		
		super.update();
	}
	
}