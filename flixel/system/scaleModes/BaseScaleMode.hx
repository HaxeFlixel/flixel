package flixel.system.scaleModes;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxPoint;

class BaseScaleMode
{
	var deviceSize:FlxPoint;
	var gameSize:FlxPoint;
	var scale:FlxPoint;
	var offset:FlxPoint;
	
	static var zoom:FlxPoint = new FlxPoint();
	
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
	
	function updateGameSize(Width:Int, Height:Int):Void
	{
		gameSize.set(Width, Height);
	}
	
	function updateDeviceSize(Width:Int, Height:Int):Void
	{
		deviceSize.set(Width, Height);
	}
	
	function updateScaleOffset():Void
	{
		scale.x = gameSize.x / FlxG.width;
		scale.y = gameSize.y / FlxG.height;
		
		zoom.set(FlxCamera.defaultZoom, FlxCamera.defaultZoom);
		
		if (FlxG.camera != null) 
		{
			zoom.x = FlxG.camera.getScale().x;
			zoom.y = FlxG.camera.getScale().y;
		}
		
		scale.x /= zoom.x;
		scale.y /= zoom.y;
		
		offset.x = Math.ceil((deviceSize.x - gameSize.x) * 0.5);
		offset.y = Math.ceil((deviceSize.y - gameSize.y) * 0.5);
	}
	
	function updateGameScale():Void
	{
		FlxG.game.scaleX = scale.x;
		FlxG.game.scaleY = scale.y;
	}
	
	function updateGamePosition():Void
	{
		FlxG.game.x = offset.x;
		FlxG.game.y = offset.y;
	}
}