package org.flixel.addons;

import nme.display.BitmapData;
import nme.display.Shape;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.FlxBasic;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxRect;

/**
* Creates a 9-grid style sprite that stretches
* @author David Grace
*/
class FlxGridSprite extends FlxObject
{
	private var _sourceImage:BitmapData;
	private var _grid:FlxRect;
	#if flash
	private var _scaledImage:BitmapData;
	private var _mat:Matrix;
	#else
	private var _red:Float = 1.0;
	private var _green:Float = 1.0;
	private var _blue:Float = 1.0;
	#end
	private var _flashRect:Rectangle;
	private var _flashPoint:Point;
	private var _smoothing:Bool;
	private var _color:Int = 0xFFFFFF;
	private var _alpha:Float = 1.0;
	private var _useTransform:Bool = false;
	private var _ct:ColorTransform;
	private var _dirty:Bool = true;
	
	#if !flash
	private var _tileData:Array<Float>;
	private var _tileIndices:Array<Int>;
	#end
   
	/**
	* Creates the grid sprite using the 9-slice grid given
	*
	* @param    X                	Left coord to draw the sprite
	* @param    Y                	Top coord to draw the sprite
	* @param    Width            	Total width of the sprite
	* @param    Height           	Total height of the sprite
	* @param    BitmapClass			The image class to use
	* @param    Grid            	A FlxRect that contains the grid demarks
	* @param    Smoothing       	Smooth when we scale the individual pieces?
	*/
	public function new(X:Float, Y:Float, Width:Float, Height:Float, Graphic:Dynamic, Grid:FlxRect, Smoothing:Bool = false)
	{
		super(X, Y, Width, Height);
	   
		_sourceImage = FlxG.addBitmap(Graphic);
		#if !flash
		_bitmapDataKey = FlxG._lastBitmapDataKey;
		#end
		_grid = Grid;
		_flashRect = new Rectangle(0, 0, width, height);
		_flashPoint = new Point();
		_smoothing = Smoothing;
		#if flash
		_mat = new Matrix();
		#else
		_tileData = [];
		_tileIndices = [];
		#end
		buildScaledImage();
	}
	
	public var smoothing(get_smoothing, set_smoothing):Bool;
   
	private function get_smoothing():Bool
	{
		return _smoothing;
	}
   
	private function set_smoothing(v:Bool):Bool
	{
		if (_smoothing != v)
		{
			_smoothing = v;
			#if flash
			_dirty = true;
			#end
		}
		return v;
	}
	
	public var color(get_color, set_color):Int;
	
	private function set_color(v:Int):Int
	{
		if (v < 0) v = -v;
		if (_color != v)
		{
			_color = v;
			updateColorTransform();
			#if flash
			_dirty = true;
			#end
		}
		return v;
	}
   
	private function get_color():Int
	{
		return _color;
	}
	
	public var alpha(get_alpha, set_alpha):Float;

	private function set_alpha(v:Float):Float
	{
		if (v > 1) v = 1;
		if (v < 0) v = 0;
		if (v != _alpha)
		{
			_alpha = v;
			updateColorTransform();
			#if flash
			_dirty = true;
			#end
		}
		return v;
	}
   
	private function get_alpha():Float
	{
		return _alpha;
	}
	
	private function updateColorTransform():Void
	{
		var r:Float = 1.0;
		var g:Float = 1.0;
		var b:Float = 1.0;
		
		if (_color < 0xFFFFFF || _alpha != 1.0)
		{
			r = (_color >> 16 & 0xFF) / 255;
			g = (_color >> 8 & 0xff) / 255;
			b = (_color & 0xff) / 255;
			
			if (_ct == null)
			{
				_ct = new ColorTransform(r, g, b, _alpha);
			}
			else
			{
				_ct.redMultiplier = (_color >> 16) / 255;
				_ct.greenMultiplier = (_color >> 8 & 0xff) / 255;
				_ct.blueMultiplier = (_color & 0xff) / 255;
				_ct.alphaMultiplier = _alpha;
			}
			_useTransform = true;
		} 
		else
		{
			if (_ct != null)
			{
				_ct.redMultiplier = r;
				_ct.greenMultiplier = g;
				_ct.blueMultiplier = b;
				_ct.alphaMultiplier = _alpha;
			}
			_useTransform = false;
		}
		
		#if !flash
		_red = r;
		_green = g;
		_blue = b;
		#end
	}
	
	public function drawImage():Void
	{
		_dirty = true;
		buildScaledImage();
	}
   
	/**
	* Called whenever we need to rebuild the scaled bitmap that is rendered.
	* Do this after you modify the width/height of this sprite.
	*/
	private function buildScaledImage():Void
	{
		if (_dirty)
		{
			#if flash
			if (_scaledImage != null && (_scaledImage.width != width || _scaledImage.height != height))
			{
				_scaledImage.dispose();
				_scaledImage = null;
			}
			
			if (_scaledImage == null)
			{
				_scaledImage = new BitmapData(Std.int(width), Std.int(height), true, FlxG.TRANSPARENT);
			}
			else
			{
				_scaledImage.fillRect(_scaledImage.rect, FlxG.TRANSPARENT);
			}
			#end
			
			var rows:Array<Float> = [0, _grid.top, _grid.bottom, _sourceImage.height];
			var cols:Array<Float> = [0, _grid.left, _grid.right, _sourceImage.width];
		   
			var dRows:Array<Float> = [0, _grid.top, height - (_sourceImage.height - _grid.bottom), height];
			var dCols:Array<Float> = [0, _grid.left, width - (_sourceImage.width - _grid.right), width];

			var origin:Rectangle;
			var draw:Rectangle;
		   
			for (cx in 0...3)
			{
				for (cy in 0...3)
				{
					origin = new Rectangle(cols[cx], rows[cy], cols[cx + 1] - cols[cx], rows[cy + 1] - rows[cy]);
					draw = new Rectangle(dCols[cx], dRows[cy], dCols[cx + 1] - dCols[cx], dRows[cy + 1] - dRows[cy]);
					#if flash
					_mat.identity();
					_mat.a = draw.width / origin.width;
					_mat.d = draw.height / origin.height;
					_mat.tx = draw.x - origin.x * _mat.a;
					_mat.ty = draw.y - origin.y * _mat.d;
					_scaledImage.draw(_sourceImage, _mat, _ct, null, draw, _smoothing);
					#end
				}
			}
			
			#if flash
			_flashRect = new Rectangle(0, 0, width, height);
			#end
		}
		_dirty = false;
	}
   
	override public function draw():Void
	{
		#if !flash
		if (_atlas == null)
		{
			return;
		}
		#end
		
		if (_dirty)
		{
			buildScaledImage();
		}
		
		if (cameras == null)
		{
			cameras = FlxG.cameras;
		}
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		while (i < l)
		{
			camera = cameras[i++];
			
			if (!onScreenObject(camera) || !camera.visible || !camera.exists)
			{
				continue;
			}
			
		#if !flash
			
		#else
			_point.x = x - (camera.scroll.x * scrollFactor.x);
			_point.y = y - (camera.scroll.y * scrollFactor.y);
		#end
		
			#if flash
			_flashPoint.x = _point.x;
			_flashPoint.y = _point.y;
			
			camera.buffer.copyPixels(_scaledImage, _flashRect, _flashPoint, null, null, true);
			#else
			
			#end
			
			FlxBasic._VISIBLECOUNT++;
			#if !FLX_NO_DEBUG
			if (FlxG.visualDebug && !ignoreDrawDebug)
			{
				drawDebug(camera);
			}
			#end
		}
	}
   
	override public function destroy():Void
	{
		super.destroy();
		#if flash
		_scaledImage.dispose();
		_mat = null;
		#else
		_tileData = null;
		_tileIndices = null;
		#end
		_sourceImage = null;
		_grid = null;
		_ct = null;
		_flashRect = null;
		_flashPoint = null;
	}
}