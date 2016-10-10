package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.system.scaleModes.FillScaleMode;
import flixel.system.scaleModes.FixedScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.scaleModes.RelativeScaleMode;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	private var currentPolicy:FlxText;
	private var scaleModes:Array<ScaleMode> = [RATIO_DEFAULT, RATIO_FILL_SCREEN, FIXED, RELATIVE, FILL];
	private var scaleModeIndex:Int = 0;
	
	override public function create():Void
	{
		add(new FlxSprite(0, 0, "assets/bg.png"));
		
		for (i in 0...20)
		{
			add(new Ship(FlxG.random.int(50, 100), FlxG.random.int(0, 360)));
		}
		
		currentPolicy = new FlxText(0, 10, FlxG.width, ScaleMode.RATIO_DEFAULT);
		currentPolicy.alignment = CENTER;
		currentPolicy.size = 16;
		add(currentPolicy);
		
		var info:FlxText = new FlxText(0, FlxG.height - 40, FlxG.width, "Press space or click to change the scale mode");
		info.setFormat(null, 14, FlxColor.WHITE, CENTER);
		info.alpha = 0.75;
		add(info);
	}
	
	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed)
		{
			scaleModeIndex = FlxMath.wrap(scaleModeIndex + 1, 0, scaleModes.length - 1);
			setScaleMode(scaleModes[scaleModeIndex]);
		}
		
		super.update(elapsed);
	}
	
	private function setScaleMode(scaleMode:ScaleMode)
	{
		currentPolicy.text = scaleMode;
		
		FlxG.scaleMode = switch (scaleMode)
		{
			case ScaleMode.RATIO_DEFAULT:
				new RatioScaleMode();
				
			case ScaleMode.RATIO_FILL_SCREEN:
				new RatioScaleMode(true);
				
			case ScaleMode.FIXED:
				new FixedScaleMode();
				
			case ScaleMode.RELATIVE:
				new RelativeScaleMode(0.75, 0.75);
				
			case ScaleMode.FILL:
				new FillScaleMode();
		}
	}
}

@:enum
abstract ScaleMode(String) to String
{
	var RATIO_DEFAULT = "ratio";
	var RATIO_FILL_SCREEN = "ratio (screenfill)";
	var FIXED = "fixed";
	var RELATIVE = "relative 75%";
	var FILL = "fill";
}