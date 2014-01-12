package flixel.system.resolution;

import flixel.FlxG;
import flixel.system.resolution.IFlxResolutionPolicy;
import flixel.util.FlxPoint;

class StageSizeResolutionPolicy extends BaseResolutionPolicy
{
	override public function onMeasure(Width:Int, Height:Int):Void
	{
		FlxG.width = Width;
		FlxG.height = Height;
		
		FlxG.game.scaleX = FlxG.game.scaleY = 1;
		FlxG.game.x = FlxG.game.y = 0;
		
		if (FlxG.camera != null)
			FlxG.camera.setSize(Math.ceil(Width / FlxG.camera.zoom), Math.ceil(Height / FlxG.camera.zoom));
	}
}