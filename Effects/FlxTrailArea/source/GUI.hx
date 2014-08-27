package;

import flixel.addons.effects.FlxTrailArea;
import flixel.addons.ui.FlxSlider;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxDestroyUtil;

class GUI extends FlxSpriteGroup
{
	public static inline var WIDTH = 200;
	
	private var _trailArea:FlxTrailArea;
	private var _sliderCallback:Float->Void;
	private var _xPos:Int;
	
	public function new(TrailArea:FlxTrailArea, ?SliderCallback:Float->Void, ShowClickInstructions:Bool = true) 
	{
		super();
		
		_trailArea = TrailArea;
		_sliderCallback = SliderCallback;
		_xPos = FlxG.width - WIDTH;
		
		// Add a white background 
		add(new FlxSprite(_xPos).makeGraphic(WIDTH, FlxG.height));
		
		// Add the different sliders
		addSlider("alphaMultiplier", 0, 1);
		addSlider("redMultiplier", 0, 1);
		addSlider("greenMultiplier", 0, 1);
		addSlider("blueMultiplier", 0, 1);
		addSlider("alphaOffset", -25, 25);
		addSlider("redOffset", -25, 25);
		addSlider("greenOffset", -25, 25);
		addSlider("blueOffset", -25, 25);
		addSlider("delay", 1, 10);
		
		// Add a button to toggle simpleRender
		add(new FlxButton(_xPos + 18, FlxG.height - 22, "[S]impleRender", toggleSimpleRender));
		// And another one to reset the values
		add(new FlxButton(FlxG.width - 98, FlxG.height - 22, "[R]eset", FlxG.resetState));
		
		// Add some instruction texts
		if (ShowClickInstructions) 
		{
			var instructionText = new FlxText(0, 10, Std.int(_xPos), "Click in this area to create particles", 16);
			instructionText.alignment = CENTER;
			add(instructionText);	
		}
		
		var toggleText:FlxText = new FlxText(0, FlxG.height - 30, Std.int(_xPos), "Press space to toggle between demos", 16);
		toggleText.alignment = CENTER;
		add(toggleText);
	}
	
	private var _curY = 5; 
	
	private function addSlider(VarName:String, MinValue:Float, MaxValue:Float):Void
	{
		var slider = new FlxSlider(_trailArea, VarName, _xPos + 20, _curY, MinValue, MaxValue, WIDTH - 50);
		slider.callback = _sliderCallback;
		add(slider);
		_curY += 50;
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.keys.justReleased.R) {
			FlxG.resetState();
		}
		else if (FlxG.keys.justReleased.S) {
			toggleSimpleRender();
		}
	}
	
	private inline function toggleSimpleRender():Void
	{
		_trailArea.simpleRender = !_trailArea.simpleRender; 
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		_trailArea = FlxDestroyUtil.destroy(_trailArea);
		_sliderCallback = null;
		super.destroy();
	}
}