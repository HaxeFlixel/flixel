package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
#if !web
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
#end
class PlayState extends FlxState
{
	#if web
	override public function create():Void
	{
		var infoText = new FlxText(10, 10, FlxG.width, "This demo does not work on this target", 16);
		infoText.setFormat(null, 16, FlxColor.WHITE, FlxTextAlign.CENTER);
		infoText.setPosition(FlxG.width * .5 -infoText.width * .5, FlxG.height * .45);
		add(infoText);
	}
	#else
	private var effect:MosaicEffect;
	private var effectTween:FlxTween;
	
	override public function create():Void
	{	
		add(new FlxSprite(0, 0, "assets/images/backdrop.png"));
	
		effect = new MosaicEffect();
		
		var filter = new ShaderFilter(effect.shader);
		var filters:Array<BitmapFilter> = [filter];
		
		FlxG.camera.setFilters(filters);
		FlxG.camera.filtersEnabled = true;
		
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
