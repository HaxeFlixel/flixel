package flixel.effects.fx;

import flixel.FlxSprite;
import flixel.system.layer.DrawStackItem;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;

#if !flash
class StarSprite extends FlxSprite
{
	
	/**
	 * Information about stars positions and colors
	 */
	public var starData:Array<StarDef>;
	
	/**
	 * Starfield's background
	 */
	public var bgRed:Float;
	public var bgGreen:Float;
	public var bgBlue:Float;
	public var bgAlpha:Float;
	
	public var halfWidth:Float;
	public var halfHeight:Float;
	
	public function new(X:Float = 0, Y:Float = 0, Width:Int = 1, Height:Int = 1, ?bgColor:Int)
	{
		super(X, Y);
		
		makeGraphic(1, 1, FlxColor.WHITE);
		
		setBackgroundColor(bgColor);
		
		width = Width;
		height = Height;
		
		halfWidth = 0.5 * Width;
		halfHeight = 0.5 * Height;
		
		starData = new Array<StarDef>();
	}
	
	public function setBackgroundColor(bgColor:Int):Void
	{
		var rgba:RGBA = FlxColor.getRGB(bgColor);
		bgRed = rgba.red / 255;
		bgGreen = rgba.green / 255;
		bgBlue = rgba.blue / 255;
		bgAlpha = rgba.alpha / 255;
	}
	
	override public function destroy():Void 
	{
		starData = null;
		super.destroy();
	}
	
	override public function draw():Void 
	{
		if (_atlas == null)
		{
			return;
		}
		
		if (_flickerTimer != 0)
		{
			_flicker = !_flicker;
			if (_flicker)
			{
				return;
			}
		}
		
		if (cameras == null)
		{
			cameras = FlxG.cameras.list;
		}
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		var currDrawData:Array<Float>;
		var currIndex:Int;
		var drawItem:DrawStackItem;
		
		var radians:Float;
		var cos:Float;
		var sin:Float;
		
		var starRed:Float;
		var starGreen:Float;
		var starBlue:Float;
		
		var starDef:StarDef;
		
		while (i < l)
		{
			camera = cameras[i++];
			if (!onScreenSprite(camera) || !camera.visible || !camera.exists)
			{
				continue;
			}
			
			#if !js
			drawItem = camera.getDrawStackItem(_atlas, true, _blendInt, antialiasing);
			#else
			drawItem = camera.getDrawStackItem(_atlas, true);
			#end
			
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			_point.x = (x - (camera.scroll.x * scrollFactor.x) - (offset.x));
			_point.y = (y - (camera.scroll.y * scrollFactor.y) - (offset.y));
			
			#if js
			_point.x = Math.floor(_point.x);
			_point.y = Math.floor(_point.y);
			#end

			var csx:Float = 1;
			var ssy:Float = 0;
			var ssx:Float = 0;
			var csy:Float = 1;
			var x1 : Float = 0.5; // yes, 0.5
			var y1 : Float = 0.5; // yes, 0.5

			if (!simpleRenderSprite ())
			{
				radians = angle * FlxAngle.TO_RAD;
				cos = Math.cos(radians);
				sin = Math.sin(radians);
				
				csx = cos * scale.x;
				ssy = sin * scale.y;
				ssx = sin * scale.x;
				csy = cos * scale.y;
				x1 = 0.0; // yes, zero
				y1 = 0.0; // yes, zero
			}

			_point.x += halfWidth;
			_point.y += halfHeight;
			
			// draw background
			currDrawData[currIndex++] = _point.x;
			currDrawData[currIndex++] = _point.y;
			
			currDrawData[currIndex++] = _flxFrame.tileID;
			
			currDrawData[currIndex++] = csx * width;
			currDrawData[currIndex++] = ssx * width;
			currDrawData[currIndex++] = -ssy * height;
			currDrawData[currIndex++] = csy * height;
			
			#if !js
			currDrawData[currIndex++] = bgRed;
			currDrawData[currIndex++] = bgGreen;
			currDrawData[currIndex++] = bgBlue;
			#end
			
			currDrawData[currIndex++] = bgAlpha * alpha;

			// draw stars
			for (j in 0...(starData.length))
			{
				starDef = starData[j];
				
				var localX:Float = starDef.x;
				var localY:Float = starDef.y;
				
				var relativeX:Float = (localX * csx - localY * ssy);
				var relativeY:Float = (localX * ssx + localY * csy);
				
				currDrawData[currIndex++] = _point.x + relativeX + x1;
				currDrawData[currIndex++] = _point.y + relativeY + y1;
				
				currDrawData[currIndex++] = _flxFrame.tileID;
				
				currDrawData[currIndex++] = csx;
				currDrawData[currIndex++] = ssx;
				currDrawData[currIndex++] = -ssy;
				currDrawData[currIndex++] = csy;
			
				starRed = starDef.red;
				starGreen = starDef.green;
				starBlue = starDef.blue;
				
			#if !js
				if (_color < 0xffffff)
				{
					starRed *= _red;
					starGreen *= _green;
					starBlue *= _blue;
				}
				
				currDrawData[currIndex++] = starRed;
				currDrawData[currIndex++] = starGreen;
				currDrawData[currIndex++] = starBlue;
			#end
				
				currDrawData[currIndex++] = alpha * starDef.alpha;
			}
			
			drawItem.position = currIndex;

			FlxBasic._VISIBLECOUNT++;
		}
	}
	
	override public function updateFrameData():Void
	{
		if (_node != null && frameWidth >= 1 && frameHeight >= 1)
		{
			_framesData = _node.getSpriteSheetFrames(Std.int(frameWidth), Std.int(frameHeight));
			_flxFrame = _framesData.frames[0];
		}
	}
}

typedef StarDef = {
	var x:Float;
	var y:Float;
	var red:Float;
	var green:Float;
	var blue:Float;
	var alpha:Float;
}
#end