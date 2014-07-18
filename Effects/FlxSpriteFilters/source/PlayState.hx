package;

import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flixel.effects.FlxSpriteFilter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxRandom;
import openfl.Assets;
import flixel.system.FlxAssets;

#if flash
import flash.filters.BevelFilter;
import flash.filters.DisplacementMapFilter;
import flash.filters.DisplacementMapFilterMode;
#end

class PlayState extends FlxState
{
	var spr1:FlxSprite;
	var spr2:FlxSprite;
	var spr3:FlxSprite;
	var spr4:FlxSprite;
	var spr5:FlxSprite;
	var spr6:FlxSprite;
	
	var txt1:FlxText;
	var txt2:FlxText;
	var txt3:FlxText;
	var txt4:FlxText;
	var txt5:FlxText;
	var txt6:FlxText;
	
	var filter1:BitmapFilter;
	#if !js
	var filter2:GlowFilter;
	var filter3:BlurFilter;
	var filter4:DropShadowFilter;
	#end
	#if flash
	var filter5:BevelFilter;
	var filter6:DisplacementMapFilter;
	#end
	
	var isAnimSpr1:Bool;
	var isAnimSpr2:Bool;
	var isAnimSpr3:Bool;
	var isAnimSpr4:Bool;
	var isAnimSpr5:Bool;
	var isAnimSpr6:Bool;
	
	var spr2Filter:FlxSpriteFilter;
	var spr3Filter:FlxSpriteFilter;
	var spr4Filter:FlxSpriteFilter;
	var spr5Filter:FlxSpriteFilter;
	var spr6Filter:FlxSpriteFilter;
	
	var tween2:FlxTween;
	var tween3:FlxTween;
	var tween5:FlxTween;
	
	override public function create():Void 
	{
		FlxG.camera.bgColor = 0xFF01355F;
		
		var txt:FlxText = new FlxText(0, 10, 640, " Sprite filters - click on each sprite to animate or stop animation. ", 8);
		txt.alignment = CENTER;
		add(txt);
		
		#if js
		txt.text = "Filters are currently not supported on HTML5";
		return;
		#end
		
		// SPRITES
		
		// NO FILTER
		spr1 = new FlxSprite(FlxG.width * 0.25 - 50, FlxG.height / 2 - 100 - 50, GraphicLogo); 
		spr1.antialiasing = true;
		add(spr1);
		txt1 = new FlxText(spr1.x, spr1.y + 120, 100, "No Filter", 10);
		txt1.alignment = CENTER;
		add(txt1);
		
		#if !js
		// GLOW
		spr2 = new FlxSprite(FlxG.width * 0.5 - 50, FlxG.height / 2 - 100 - 50, GraphicLogo);
		add(spr2);
		txt2 = new FlxText(spr2.x, spr2.y + 120, 100, "Glow", 10);
		txt2.alignment = CENTER;
		add(txt2);
		filter2 = new GlowFilter(0xFF0000, 1, 50, 50, 1.5, 1);
		
		spr2Filter = new FlxSpriteFilter(spr2, 50, 50);
		spr2Filter.addFilter(filter2);
		
		// BLUR
		spr3 = new FlxSprite(FlxG.width * 0.75 - 50, FlxG.height / 2 - 100 - 50, GraphicLogo);
		add(spr3);
		txt3 = new FlxText(spr3.x, spr3.y + 120, 100, "Blur", 10);
		txt3.alignment = CENTER;
		add(txt3);
		filter3 = new BlurFilter();
		
		spr3Filter = new FlxSpriteFilter(spr3, 50, 50);
		spr3Filter.addFilter(filter3);
		
		// DROP SHADOW
		spr4 = new FlxSprite(FlxG.width * 0.25 - 50, FlxG.height / 2 + 100 - 50, GraphicLogo);
		add(spr4);
		txt4 = new FlxText(spr4.x, spr4.y + 120, 100, "Drop Shadow", 10); 
		txt4.alignment = CENTER;
		add(txt4);
		filter4 = new DropShadowFilter(10, 45, 0, .75, 10, 10, 1, 1);
		
		spr4Filter = new FlxSpriteFilter(spr4, 50, 50);
		spr4Filter.addFilter(filter4);
		#end
		
		#if flash
		// BEVEL
		spr5 = new FlxSprite(FlxG.width * 0.5 - 50, FlxG.height / 2 + 100 - 50, GraphicLogo);
		add(spr5);
		filter5 = new BevelFilter(6);
		spr5Filter = new FlxSpriteFilter(spr5, 50, 50);
		spr5Filter.addFilter(filter5);
		txt5 = new FlxText(spr5.x + 25, spr5.y + 120 + 15, 100, "Bevel\n( flash only )", 10);
		txt5.alignment = CENTER;
		add(txt5);
		
		// DISPLACEMENT MAP
		spr6 = new FlxSprite(FlxG.width * 0.75 - 50, FlxG.height / 2 + 100 - 50, GraphicLogo);
		add(spr6);
		filter6 = (new DisplacementMapFilter(Assets.getBitmapData("assets/StaticMap.png"), 
						new Point(0, 0), 1, 1, 15, 1, DisplacementMapFilterMode.COLOR, 1, 0));
		spr6Filter = new FlxSpriteFilter(spr6, 50, 50);
		spr6Filter.addFilter(filter6);
		
		updateDisplaceFilter();
		txt6 = new FlxText(spr6.x + 25, spr6.y + 120 + 15, 100, "Displacement\n( flash only )", 10);
		txt6.alignment = CENTER;
		add(txt6);
		#end
		
		// FILTERS
		
		// Animations
		#if !js
		tween2 = FlxTween.tween(filter2, { blurX: 4, blurY: 4 }, 1, { type: FlxTween.PINGPONG });
		tween2.active = false;
		
		tween3 = FlxTween.tween(filter3, { blurX:50, blurY:50 }, 1.5, { type: FlxTween.PINGPONG });
		tween3.active = false;
		#end
		
		#if flash
		tween5 = FlxTween.tween(filter5, { distance: -6 }, 1.5, { type: FlxTween.PINGPONG, ease: FlxEase.quadInOut });
		tween5.active = false;
		#end
	}
	
	override public function update():Void 
	{
		super.update();
		
		// Check for animation toggles
		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(spr1))
			{
				isAnimSpr1 = !isAnimSpr1;
			}
			else if (FlxG.mouse.overlaps(spr2))
			{
				isAnimSpr2 = !isAnimSpr2;
				tween2.active = isAnimSpr2;
			}
			else if (FlxG.mouse.overlaps(spr3))
			{
				isAnimSpr3 = !isAnimSpr3;
				tween3.active = isAnimSpr3;
			}
			else if (FlxG.mouse.overlaps(spr4))
			{
				isAnimSpr4 = !isAnimSpr4;
			}
			#if flash
			else if (FlxG.mouse.overlaps(spr5))
			{
				isAnimSpr5 = !isAnimSpr5;
				tween5.active = isAnimSpr5;
			}
			else if (FlxG.mouse.overlaps(spr6))
			{
				isAnimSpr6 = !isAnimSpr6;
			} 
			#end
		}
		
		if (isAnimSpr1)
		{
			spr1.angle += 45 * FlxG.elapsed;
		}
		if (isAnimSpr2)
		{
			updateFilter(spr2Filter);
		}
		if (isAnimSpr3)
		{
			updateFilter(spr3Filter);
		}
		if (isAnimSpr4)
		{
			updateDropShadowFilter();
		}
		if (isAnimSpr5)
		{
			updateFilter(spr5Filter);
		}
		if (isAnimSpr6)
		{
			updateDisplaceFilter();
		}
	}
	
	function updateDisplaceFilter()
	{
		#if flash
		filter6.scaleX = FlxG.random.float( -10, 10);
		filter6.mapPoint = new Point(0, FlxG.random.float(0, 30));
		updateFilter(spr6Filter);
		#end
	}
	
	function updateDropShadowFilter()
	{
		#if !js
		filter4.angle -= 360 * FlxG.elapsed;
		updateFilter(spr4Filter);
		#end
	}
	
	function updateFilter(sprFilter:FlxSpriteFilter)
	{
		sprFilter.applyFilters();
	}
}