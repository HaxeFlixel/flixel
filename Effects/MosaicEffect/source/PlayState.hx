package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

class PlayState extends FlxState
{
	#if flash
	override public function create():Void
	{
		var infoText = new FlxText(10, 10, FlxG.width, "This demo does not work on this target", 16);
		infoText.setFormat(null, 16, FlxColor.WHITE, FlxTextAlign.CENTER);
		infoText.setPosition(FlxG.width * .5 -infoText.width * .5, FlxG.height * .45);
		add(infoText);
	}
	#else
	var effectTween:FlxTween;
	
	override public function create():Void
	{
		var backdrop = new FlxSprite(0, 0, "assets/images/backdrop.png");
		add(backdrop);

		var effect = new MosaicEffect();
		backdrop.shader = effect.shader;
		
		var infoText = new FlxText(10, 10, 100, "Press SPACE to pause the effect.");
		infoText.color = FlxColor.BLACK;
		add(infoText);
		
		effectTween = FlxTween.num(MosaicEffect.DEFAULT_STRENGTH, 15, 2, { type:FlxTween.PINGPONG }, function(v)
		{
			effect.setStrength(v, v);
		});
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.SPACE) 
			effectTween.active = !effectTween.active;
		
		super.update(elapsed);
	}
	#end
}
