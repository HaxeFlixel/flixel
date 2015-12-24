package states;

import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import openfl.display.FPS;

class BaseState extends FlxState
{
	var fps:FPS;
	var states:Array<Dynamic> = [Pyramid, Balloons, Blob, Fight, Cutup, SolarSystem];
	static var stateIndex = 0;
	
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
			changeState(-1);
		if (FlxG.keys.justPressed.RIGHT)
			changeState(1);
	}
	
	private function changeState(modifier:Int):Void
	{
		stateIndex = FlxMath.wrap(stateIndex + modifier, 0, states.length - 1);
		FlxG.switchState(Type.createInstance(states[stateIndex], []));
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		if (fps != null)
			FlxG.removeChild(fps);
	}
}