package states;

import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import openfl.display.FPS;

class BaseState extends FlxState
{
	var fps:FPS;
	
	override public function create():Void
	{
		FlxG.addChildBelowMouse(fps = new FPS(FlxG.width - 60, 5, FlxColor.WHITE));
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.G)
			FlxNapeSpace.drawDebug = !FlxNapeSpace.drawDebug;
		
		if (FlxG.keys.justPressed.R)
			FlxG.resetState();
		
		if (FlxG.keys.justPressed.LEFT)
			Main.prevState();
		if (FlxG.keys.justPressed.RIGHT)
			Main.nextState();
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		if (fps != null)
			FlxG.removeChild(fps);
	}
}