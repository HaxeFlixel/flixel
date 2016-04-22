package;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;

class DemoState extends FlxState
{
	private var effectSprite:FlxFloodFill;
	private var effectSprite2:FlxFloodFill;
	private var infoText:FlxText;
	
	override public function create():Void
	{
		add(new FlxSprite(0, 0, "assets/images/backdrop.png"));
		
		var effectBitmapData:BitmapData = Assets.getBitmapData("assets/images/logo.png");
		effectSprite = new FlxFloodFill(100, FlxG.height * .5 - effectBitmapData.height * .5, effectBitmapData, effectBitmapData.width, effectBitmapData.height, 1, .01);
		
		effectSprite2 = new FlxFloodFill(FlxG.width-(effectBitmapData.width+100), 0, effectBitmapData, effectBitmapData.width, Math.floor(effectSprite.y+effectSprite.height), 1, .01);
		
		infoText = new FlxText(10, 10, 100, "Press SPACE key to run the effect.\n\nPress R to restart demo.");
		infoText.color = FlxColor.BLACK;
		
		add(effectSprite);
		add(effectSprite2);
		add(infoText);
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.R) 
		{
			FlxG.resetState();
		}
		
		if (FlxG.keys.justPressed.SPACE) 
		{
			effectSprite.active = !effectSprite.active;
			effectSprite2.active = !effectSprite2.active;
		}
		
		super.update(elapsed);
	}
}
