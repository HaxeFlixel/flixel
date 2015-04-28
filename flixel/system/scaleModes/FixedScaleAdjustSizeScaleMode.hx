package flixel.system.scaleModes;

import flixel.FlxG;

class FixedScaleAdjustSizeScaleMode extends BaseScaleMode
{
	private var fixedWidth:Bool = false;
	private var fixedHeight:Bool = false;
	
	public function new(fixedWidth:Bool = false, fixedHeight:Bool = false)
	{
		super();
		this.fixedWidth = fixedWidth;
		this.fixedHeight = fixedHeight;
		
		gameSize.set(FlxG.width * FlxG.initialZoom, FlxG.height * FlxG.initialZoom);
	}
	
	override public function onMeasure(Width:Int, Height:Int):Void
	{
		FlxG.width = fixedWidth ? BaseScaleMode.gWidth : Math.ceil(Width / FlxG.initialZoom);
		FlxG.height = fixedHeight ? BaseScaleMode.gHeight : Math.ceil(Height / FlxG.initialZoom);
		
		updateGameSize(Width, Height);
		updateDeviceSize(Width, Height);
		updateScaleOffset();
		updateGamePosition();
	}
	
	override private function updateGameSize(Width:Int, Height:Int):Void 
	{
		gameSize.x = FlxG.width * FlxG.initialZoom;
		gameSize.y = FlxG.height * FlxG.initialZoom;
		
		if (FlxG.camera != null)
		{
			var oldWidth:Float = FlxG.camera.width;
			var oldHeight:Float = FlxG.camera.height;
			
			FlxG.camera.setSize(FlxG.width, FlxG.height);
			FlxG.camera.scroll.x += 0.5 * (oldWidth - FlxG.width);
			FlxG.camera.scroll.y += 0.5 * (oldHeight - FlxG.height);
		}
	}
}