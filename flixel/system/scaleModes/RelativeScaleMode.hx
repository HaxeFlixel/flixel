package flixel.system.scaleModes;

import flixel.FlxG;

class RelativeScaleMode extends BaseScaleMode
{
	var _widthScale:Float;
	var _heightScale:Float;

	public function new(WidthScale:Float, HeightScale:Float)
	{
		super();
		initScale(WidthScale, HeightScale);
	}

	inline function initScale(WidthScale:Float, HeightScale:Float):Void
	{
		_widthScale = WidthScale;
		_heightScale = HeightScale;
	}

	public function setScale(WidthScale:Float, HeightScale:Float):Void
	{
		initScale(WidthScale, HeightScale);
		onMeasure(FlxG.stage.stageWidth, FlxG.stage.stageHeight);
	}

	override function updateGameSize(Width:Int, Height:Int):Void
	{
		gameSize.x = Std.int(Width * _widthScale);
		gameSize.y = Std.int(Height * _heightScale);
	}
}
