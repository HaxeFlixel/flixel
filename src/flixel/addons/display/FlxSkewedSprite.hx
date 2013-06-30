package flixel.addons.display;

import flash.geom.Matrix;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.layer.DrawStackItem;
import flixel.util.FlxAngle;
import flixel.util.FlxPoint;

/**
 * ...
 * @author Zaphod
 */
class FlxSkewedSprite extends FlxSprite
{
	public var skew:FlxPoint;
	
	private var _skewMatrix:Matrix;
	
	public function new(X:Float = 0, Y:Float = 0) 
	{
		super(X, Y);
		
		skew = new FlxPoint();
		_skewMatrix = new Matrix();
	}
	
	/**
	 * WARNING: This will remove this sprite entirely. Use <code>kill()</code> if you 
	 * want to disable it temporarily only and <code>reset()</code> it later to revive it.
	 * Used to clean up memory.
	 */
	override public function destroy():Void 
	{
		skew = null;
		_skewMatrix = null;
		
		super.destroy();
	}
	
	override private function get_simpleRender():Bool
	{ 
		return simpleRenderSkewedSprite();
	}
	
	inline private function simpleRenderSkewedSprite():Bool
	{
		#if !flash
		return (((angle == 0) || (bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1) && (skew.x == 0) && (skew.y == 0));
		#else
		return (((angle == 0) || (bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1) && (blend == null) && (skew.x == 0) && (skew.y == 0) && (forceComplexRender == false));
		#end
	}
	
	override public function draw():Void 
	{
		#if !flash
		if (_atlas == null)
		{
			return;
		}
		#end
		
		if (_flickerTimer != 0)
		{
			_flicker = !_flicker;
			if (_flicker)
			{
				return;
			}
		}
		
		if (dirty)	//rarely 
		{
			calcFrame();
		}
		
		if (cameras == null)
		{
			cameras = FlxG.cameras.list;
		}
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		#if !flash
		var drawItem:DrawStackItem;
		var isColored:Bool = isColored();
		var currDrawData:Array<Float>;
		var currIndex:Int;
		#end
		
		var radians:Float;
		var cos:Float;
		var sin:Float;
		
		while(i < l)
		{
			camera = cameras[i++];
			
			if (!onScreenSprite(camera) || !camera.visible || !camera.exists)
			{
				continue;
			}
			
		#if !flash
			#if !js
			drawItem = camera.getDrawStackItem(_atlas, isColored, _blendInt, antialiasing);
			#else
			var useAlpha:Bool = (alpha < 1);
			drawItem = camera.getDrawStackItem(_atlas, useAlpha);
			#end
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			_point.x = x - (camera.scroll.x * scrollFactor.x) - (offset.x);
			_point.y = y - (camera.scroll.y * scrollFactor.y) - (offset.y);
			
			_point.x = (_point.x) + origin.x;
			_point.y = (_point.y) + origin.y;
			
			#if js
			_point.x = Math.floor(_point.x);
			_point.y = Math.floor(_point.y);
			#end
		#else
			_point.x = x - (camera.scroll.x * scrollFactor.x) - (offset.x);
			_point.y = y - (camera.scroll.y * scrollFactor.y) - (offset.y);
		#end
		
#if flash
			if (simpleRenderSkewedSprite ())
			{
				_flashPoint.x = _point.x;
				_flashPoint.y = _point.y;
				camera.buffer.copyPixels(framePixels, _flashRect, _flashPoint, null, null, true);
			}
			else
			{
				_matrix.identity ();
				_matrix.translate( -origin.x, -origin.y);
				if ((angle != 0) && (bakedRotation <= 0))
				{
					_matrix.rotate(angle * FlxAngle.TO_RAD);
				}
				_matrix.scale(scale.x, scale.y);
				if (skew.x != 0 || skew.y != 0)
				{
					_skewMatrix.identity();
					_skewMatrix.b = Math.tan(skew.y * FlxAngle.TO_RAD);
					_skewMatrix.c = Math.tan(skew.x * FlxAngle.TO_RAD);
					
					_matrix.concat(_skewMatrix);
				}
				
				_matrix.translate(_point.x + origin.x, _point.y + origin.y);
				camera.buffer.draw(framePixels, _matrix, null, blend, null, antialiasing);
			}
#else
			var csx:Float = 1;
			var ssy:Float = 0;
			var ssx:Float = 0;
			var csy:Float = 1;
			var x2:Float = 0;
			var y2:Float = 0;
			
			var isFlipped : Bool = (_flipped != 0) && (facing == FlxObject.LEFT);
			if (simpleRenderSkewedSprite ())
			{
				if (isFlipped)
				{
					csx = -csx;
				}
			}
			else
			{
				radians = -angle * FlxAngle.TO_RAD;
				cos = Math.cos(radians);
				sin = Math.sin(radians);
				
				csx = cos * scale.x;
				ssy = sin * scale.y;
				ssx = sin * scale.x;
				csy = cos * scale.y;
				
				var x1:Float = (origin.x - _halfWidth);
				var y1:Float = (origin.y - _halfHeight);
				x2 = x1 * csx + y1 * ssy;
				y2 = -x1 * ssx + y1 * csy;
				
				_matrix.identity();
				_matrix.a = cos;
				_matrix.b = -sin;
				_matrix.c = sin;
				_matrix.d = cos;
				
				if (isFlipped)
				{
					_matrix.scale( -scale.x, scale.y);
				}
				else
				{
					_matrix.scale(scale.x, scale.y);
				}
				
				if (skew.x != 0 || skew.y != 0)
				{
					_skewMatrix.identity();
					
					_skewMatrix.b = Math.tan(skew.y * FlxAngle.TO_RAD);
					_skewMatrix.c = Math.tan(skew.x * FlxAngle.TO_RAD);
					
					_matrix.concat(_skewMatrix);
				}
				
				csx = _matrix.a;
				ssy = _matrix.b;
				ssx = _matrix.c;
				csy = _matrix.d;
			}
			
			currDrawData[currIndex++] = _point.x - x2;
			currDrawData[currIndex++] = _point.y - y2;
			currDrawData[currIndex++] = _flxFrame.tileID;
			
			currDrawData[currIndex++] = csx;
			currDrawData[currIndex++] = ssy;
			currDrawData[currIndex++] = ssx;
			currDrawData[currIndex++] = csy;
			
			#if !js
			if (isColored)
			{
				currDrawData[currIndex++] = _red;
				currDrawData[currIndex++] = _green;
				currDrawData[currIndex++] = _blue;
			}
			currDrawData[currIndex++] = alpha;
			#else 
			if (useAlpha)
			{
				currDrawData[currIndex++] = alpha;
			}
			#end
			
			drawItem.position = currIndex;
#end
			
			FlxBasic._VISIBLECOUNT++;
		}
	}
}