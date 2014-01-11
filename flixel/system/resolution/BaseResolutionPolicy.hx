package flixel.system.resolution;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.system.resolution.IFlxResolutionPolicy;
import flixel.util.FlxPoint;

class BaseResolutionPolicy implements IFlxResolutionPolicy 
{
	private var deviceSize:FlxPoint;
	private var gameSize:FlxPoint;
	private var scale:FlxPoint;
	private var offset:FlxPoint;
	
	public function new()
	{
		deviceSize = new FlxPoint();
		gameSize = new FlxPoint();
		scale = new FlxPoint();
		offset = new FlxPoint();
	}
	
	public function onMeasure(Width:Int, Height:Int):Void
	{
		updateGameSize(Width, Height);
		updateDeviceSize(Width, Height);
		updateScaleOffset();
		updateGameScale();
		updateGamePosition();
	}
	
	private function updateGameSize(Width:Int, Height:Int):Void
	{
		gameSize.set(Width, Height);
	}
	
	private function updateDeviceSize(Width:Int, Height:Int):Void
	{
		deviceSize.set(Width, Height);
	}
	
	private function updateScaleOffset():Void
	{
		scale.x = gameSize.x / FlxG.width;
		scale.y = gameSize.y / FlxG.height;
		
		var zoom:Float = FlxCamera.defaultZoom;
		
		if (FlxG.camera != null) zoom = FlxG.camera.zoom;
		
		offset.x = Math.ceil((deviceSize.x - gameSize.x * zoom) * 0.5);
		offset.y = Math.ceil((deviceSize.y - gameSize.y * zoom) * 0.5);
	}
	
	private function updateGameScale():Void
	{
		FlxG.game.scaleX = scale.x;
		FlxG.game.scaleY = scale.y;
	}
	
	private function updateGamePosition():Void
	{
		FlxG.game.x = offset.x;
		FlxG.game.y = offset.y;
	}
}