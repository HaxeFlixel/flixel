package flixel.system.scaleModes;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxPoint;

@:allow(flixel.FlxGame)
class BaseScaleMode
{
	public var deviceSize(default, null):FlxPoint;
	public var gameSize(default, null):FlxPoint;
	public var scale(default, null):FlxPoint;
	public var offset(default, null):FlxPoint;
	
	private static var zoom:FlxPoint = FlxPoint.get();
	
	public function new()
	{
		deviceSize = FlxPoint.get();
		gameSize = FlxPoint.get();
		scale = FlxPoint.get();
		offset = FlxPoint.get();
	}
	
	public function onMeasure(Width:Int, Height:Int):Void
	{
		updateGameSize(Width, Height);
		updateDeviceSize(Width, Height);
		updateScaleOffset();
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
		
		zoom.set(FlxCamera.defaultZoom, FlxCamera.defaultZoom);
		
		if (FlxG.camera != null) 
		{
			zoom.set(FlxG.camera.scaleX, FlxG.camera.scaleY);
		}
		
		scale.x /= zoom.x;
		scale.y /= zoom.y;
		
		offset.x = Math.ceil((deviceSize.x - gameSize.x) * 0.5);
		offset.y = Math.ceil((deviceSize.y - gameSize.y) * 0.5);
	}
	
	private function updateGamePosition():Void
	{
		FlxG.game.x = offset.x;
		FlxG.game.y = offset.y;
	}
}