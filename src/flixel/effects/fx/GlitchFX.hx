package flixel.effects.fx;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.util.FlxAngle;

// TODO: Add reduction from really high glitch value down to zero, will smooth the image into place and look cool :)
// TODO: Add option to glitch vertically?

/**
 * Creates a static / glitch / monitor-corruption style effect on an FlxSprite
 * 
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm 
 */
class GlitchFX extends BaseFX
{
	private var _glitchSize:Int;
	private var _glitchSkip:Int;
	
	public function new() 
	{
		super();
	}
	
	public function createFromFlxSprite(Source:FlxSprite, MaxGlitch:Int, MaxSkip:Int, AutoUpdate:Bool = false, BackgroundColor:Int = 0x0):FlxSprite
	{
		#if flash
		sprite = new FlxSprite(Source.x, Source.y).makeGraphic(Std.int(Source.width + MaxGlitch), Std.int(Source.height), BackgroundColor);
		canvas = new BitmapData(Std.int(sprite.width), Std.int(sprite.height), true, BackgroundColor);
		image = Source.pixels;
		#else
		sprite = new GlitchSprite(Source, MaxGlitch, MaxSkip, BackgroundColor);
		#end
		
		sourceRef = Source;
		
		updateFromSource = AutoUpdate;
		
		_glitchSize = MaxGlitch;
		_glitchSkip = MaxSkip;
		
		clsColor = BackgroundColor;
		
		copyPoint = new Point(0, 0);
		
		#if flash
		clsRect = new Rectangle(0, 0, canvas.width, canvas.height);
		copyRect = new Rectangle(0, 0, image.width, 1);
		#end
		
		active = true;
		
		return sprite;
	}
	
	public function changeGlitchValues(MaxGlitch:Int, MaxSkip:Int):Void
	{
		glitchSize = MaxGlitch;
		glitchSkip = MaxSkip;
		
		#if !flash
		if (sprite != null && sourceRef != null)
		{
			var glitch:GlitchSprite = cast(sprite, GlitchSprite);
			glitch.frameWidth = Std.int(sourceRef.frameWidth + MaxGlitch);
			glitch.maxGlitch = MaxGlitch;
			glitch.glitchSkip = MaxSkip;
		}
		#end
	}
	
	override public function draw():Void
	{
		if (ready)
		{
			if (lastUpdate != updateLimit)
			{
				lastUpdate++;
				return;
			}
			
			if (updateFromSource && sourceRef.exists)
			{
				#if flash
				image = sourceRef.framePixels;
				#else
				cast(sprite, GlitchSprite).updateFromSourceSprite();
				#end
			}
			
			var rndSkip:Int = 1 + Std.int(Math.random() * glitchSkip);
			
			#if flash
			canvas.lock();
			canvas.fillRect(clsRect, clsColor);
			
			copyRect.y = 0;
			copyPoint.y = 0;
			copyRect.height = rndSkip;
			
			var y:Int = 0;
			
			while (y < sprite.height)
			{
				copyPoint.x = Std.int(Math.random() * glitchSize);
				canvas.copyPixels(image, copyRect, copyPoint);
				
				copyRect.y += rndSkip;
				copyPoint.y += rndSkip;
				y += rndSkip;
			}
			
			canvas.unlock();
			sprite.pixels = canvas;
			sprite.dirty = true;
			#else
			cast(sprite, GlitchSprite).updateLinePositions();
			#end
			
			lastUpdate = 0;
		}
	}
}

typedef ImageLine = {
	var x:Float;
	var y:Float;
	var tileID:Int;
}
#end