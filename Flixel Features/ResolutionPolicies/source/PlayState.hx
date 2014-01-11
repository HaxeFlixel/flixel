package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.system.resolution.FillResolutionPolicy;
import flixel.system.resolution.FixedResolutionPolicy;
import flixel.system.resolution.RatioResolutionPolicy;
import flixel.system.resolution.RelativeResolutionPolicy;
import flixel.system.resolution.StageSizeResolutionPolicy;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;

class PlayState extends FlxState
{
	private var currentPolicy:FlxText;
	
	private var fillPolicy:FillResolutionPolicy;
	private var ratioPolicy:RatioResolutionPolicy;
	private var relativePolicy:RelativeResolutionPolicy;
	private var fixedPolicy:FixedResolutionPolicy;
	
	override public function create():Void
	{
		fillPolicy = new FillResolutionPolicy();
		ratioPolicy = new RatioResolutionPolicy();
		relativePolicy = new RelativeResolutionPolicy(0.5, 0.5);
		fixedPolicy = new FixedResolutionPolicy();
		
		add(new FlxSprite(0, 0, "assets/bg.png"));
		
		for (i in 0...20)
		{
			add(new Ship(Math.random() * 50 + 50, Math.random() * 360));
		}
		
		FlxG.resolutionPolicy = fillPolicy;
		currentPolicy = new FlxText(170, 10, 150, "fill");
		currentPolicy.size = 16;
		add(currentPolicy);
		
		var info:FlxText = new FlxText(0, FlxG.height - 40, FlxG.width, "press space to change resolution policy");
		info.setFormat(null, 14, FlxColor.WHITE, "center");
		info.alpha = 0.5;
		add(info);
	}
	
	override public function update():Void
	{
		if (FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed)
		{
			switch (currentPolicy.text)
			{
				case "fill":
					FlxG.resolutionPolicy = ratioPolicy;
					currentPolicy.text = "ratio";
				
				case "ratio":
					FlxG.resolutionPolicy = fixedPolicy;
					currentPolicy.text = "fixed";
					
				case "fixed":
					FlxG.resolutionPolicy = relativePolicy;
					currentPolicy.text = "relative 50%";
				
				default:
					FlxG.resolutionPolicy = fillPolicy;
					currentPolicy.text = "fill";
			}
		}
		
		super.update();
	}
}