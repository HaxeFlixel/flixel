package org.flixel.addons;

import nme.display.BitmapData;
import nme.display.Shape;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Rectangle;
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
	private var _scaledImage:BitmapData;
	private var _flashRect:Rectangle;
	private var _smoothing:Bool;
	private var _color:Int = 0xFFFFFF;
	private var _alpha:Float = 1.0;
	private var _ct:ColorTransform;
   
	/**
	* Creates the grid sprite using the 9-slice grid given
	*
	* @param    X                Left coord to draw the sprite
	* @param    Y                Top coord to draw the sprite
	* @param    Width            Total width of the sprite
	* @param    Height            Total height of the sprite
	* @param    BitmapClass        The image class to use
	* @param    Grid            A FlxRect that contains the grid demarks
	* @param    Smoothing        Smooth when we scale the individual pieces?
	*/
	public function new(X:Float, Y:Float, Width:Float, Height:Float, BitmapClass:Dynamic, Grid:FlxRect, Smoothing:Bool = false)
	{
		super(X, Y, Width, Height);
	   
		_sourceImage = FlxG.addBitmap(BitmapClass);
		_grid = Grid;
		_flashRect = new Rectangle(0, 0, width, height);   
		_smoothing = Smoothing;
		buildScaledImage();
	}
	
	public var smoothing(get_smoothing, set_smoothing):Bool;
   
	private function get_smoothing():Bool
	{
		return _smoothing;
	}
   
	private function set_smoothing(v:Bool):Bool
	{
		_smoothing = v;
		buildScaledImage();
		return v;
	}
	
	public var color(get_color, set_color):Int;
	
	private function set_color(v:Int):Int
	{
		if (v < 0) v = -v;
		// TODO: cut off alpha
		_color = v;
		buildScaledImage();
		return v;
	}
   
	private function get_color():Int
	{
		return _color;
	}
	
	public var alpha(get_alpha, set_alpha):Float;

	private function set_alpha(v:Float):Float
	{
		if(v > 1) v = 1;
		if(v < 0) v = 0;
		if(v == _alpha) return;
		_alpha = v;
		buildScaledImage();
		return v;
	}
   
	private function get_alpha():Float
	{
		return _alpha;
	}
   
	/**
	* Called whenever we need to rebuild the scaled bitmap that is rendered.
	* Do this after you modify the width/height of this sprite.
	*/
	public function buildScaledImage():Void
	{
		if (_scaledImage != null)
		{
			_scaledImage.dispose();
		}
		
		_scaledImage = new BitmapData(width, height, true, 0x0);
	   
		var rows:Array<Float> = [0, _grid.top, _grid.bottom, _sourceImage.height];
		var cols:Array<Float> = [0, _grid.left, _grid.right, _sourceImage.width];
	   
		var dRows:Array<Float> = [0, _grid.top, height - (_sourceImage.height - _grid.bottom), height];
		var dCols:Array<Float> = [0, _grid.left, width - (_sourceImage.width - _grid.right), width];

		var origin:Rectangle;
		var draw:Rectangle;
		var mat:Matrix = new Matrix();
		var ct:ColorTransform;

		if (_color < 0xFFFFFF || alpha != 1.0)
		{
			ct = new ColorTransform((_color >> 16 & 0xFF) / 255, (_color >> 8 & 0xff) / 255, (_color & 0xff) / 255, _alpha);
		} 
		else
		{
			ct = null;
		}
	   
		for (cx in 0...3)
		{
			for (cy in 0...3)
			{
				origin = new Rectangle(cols[cx], rows[cy], cols[cx + 1] - cols[cx], rows[cy + 1] - rows[cy]);
				draw = new Rectangle(dCols[cx], dRows[cy], dCols[cx + 1] - dCols[cx], dRows[cy + 1] - dRows[cy]);
				mat.identity();
				mat.a = draw.width / origin.width;
				mat.d = draw.height / origin.height;
				mat.tx = draw.x - origin.x * mat.a;
				mat.ty = draw.y - origin.y * mat.d;
				_scaledImage.draw(_sourceImage, mat, ct, null, draw, _smoothing);
			}
		}
		
		_flashRect = new Rectangle(0, 0, width, height);
	}
   
	override public function render():Void
	{
		getScreenXY(_point);
		_flashPoint.x = _point.x;
		_flashPoint.y = _point.y;
		FlxG.buffer.copyPixels(_scaledImage, _flashRect, _flashPoint, null, null, true);
	}
   
	override public function destroy():Void
	{
		super.destroy() ;
		_scaledImage.dispose() ;
	}
}