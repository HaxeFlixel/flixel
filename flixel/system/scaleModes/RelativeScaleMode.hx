package flixel.system.scaleModes;

import flixel.FlxG;

/**
 * `RelativeScaleMode` is a scaling mode which stretches and squashes the game to exactly fit the provided window.
 * It acts similar to the `FillScaleMode`, however there is one major difference.
 * `RelativeScaleMode` takes two parameters, which represent the width scale and height scale.
 * 
 * For example, `RelativeScaleMode(1, 0.5)` will cause the game to take up 100% of the window width,
 * but only 50% of the window height, filling in the remaining space with a black margin.
 * 
 * To enable it in your project, use `FlxG.scaleMode = new RelativeScaleMode();`.
 */
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
