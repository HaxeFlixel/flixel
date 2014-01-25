package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.system.scaleModes.FillScaleMode;
import flixel.system.scaleModes.FixedScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.scaleModes.RelativeScaleMode;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;

class PlayState extends FlxState
{
	private var currentPolicy:FlxText;
	
	private var fillPolicy:FillScaleMode;
	private var ratioPolicy:RatioScaleMode;
	private var relativePolicy:RelativeScaleMode;
	private var fixedPolicy:FixedScaleMode;
	
	override public function create():Void
	{
		fillPolicy = new FillScaleMode();
		ratioPolicy = new RatioScaleMode();
		relativePolicy = new RelativeScaleMode(0.75, 0.75);
		fixedPolicy = new FixedScaleMode();
		
		add(new FlxSprite(0, 0, "assets/bg.png"));
		
		for (i in 0...20)
		{
			add(new Ship(FlxRandom.intRanged(50, 100), FlxRandom.intRanged(0, 360)));
		}
		
		FlxG.scaleMode = ratioPolicy;
		currentPolicy = new FlxText(0, 10, FlxG.width, "ratio");
		currentPolicy.alignment = "center";
		currentPolicy.size = 16;
		add(currentPolicy);
		
		var info:FlxText = new FlxText(0, FlxG.height - 40, FlxG.width, "press space or click to change the resolution policy");
		info.setFormat(null, 14, FlxColor.WHITE, "center");
		info.alpha = 0.75;
		add(info);
	}
	
	override public function update():Void
	{
		if (FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed)
		{
			switch (currentPolicy.text)
			{
				case "fill":
					FlxG.scaleMode = ratioPolicy;
					currentPolicy.text = "ratio";
				
				case "ratio":
					FlxG.scaleMode = fixedPolicy;
					currentPolicy.text = "fixed";
					
				case "fixed":
					FlxG.scaleMode = relativePolicy;
					currentPolicy.text = "relative 75%";
				
				default:
					FlxG.scaleMode = fillPolicy;
					currentPolicy.text = "fill";
			}
		}
		
		super.update();
	}
}