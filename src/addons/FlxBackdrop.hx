package addons;

import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.FlxG;
import org.flixel.FlxObject;

/**
 * Used for showing infinitely scrolling backgrounds.
 * @author Chevy Ray
 */
class FlxBackdrop extends FlxObject
{
	private var _data:BitmapData;
	private var _ppoint:Point;
	private var _scrollW:Int;
	private var _scrollH:Int;
	private var _repeatX:Bool;
	private var _repeatY:Bool;
	
	/**
	 * Creates an instance of the FlxBackdrop class, used to create infinitely scrolling backgrounds.
	 * @param   bitmap The image you want to use for the backdrop.
	 * @param   scrollX Scrollrate on the X axis.
	 * @param   scrollY Scrollrate on the Y axis.
	 * @param   repeatX If the backdrop should repeat on the X axis.
	 * @param   repeatY If the backdrop should repeat on the Y axis.
	 */
	public function new(graphic:String, scrollX:Float = 0, scrollY:Float = 0, repeatX:Bool = true, repeatY:Bool = true) 
	{
		super();
		var data:BitmapData = Assets.getBitmapData(graphic);
		var w:Int = data.width;
		var h:Int = data.height;
		if (repeatX) w += FlxG.width;
		if (repeatY) h += FlxG.height;

		_data = new BitmapData(w, h);
		_ppoint = new Point();

		_scrollW = data.width;
		_scrollH = data.height;
		_repeatX = repeatX;
		_repeatY = repeatY;

		while (_ppoint.y < _data.height + data.height)
		{
			while (_ppoint.x < _data.width + data.width)
			{
				_data.copyPixels(data, data.rect, _ppoint);
				_ppoint.x += data.width;
			}
			_ppoint.x = 0;
			_ppoint.y += data.height;
		}
		
		scrollFactor.x = scrollX;
		scrollFactor.y = scrollY;
	}

	override public function draw():Void
	{
		// find x position
		if (_repeatX)
		{   
			_ppoint.x = (x - FlxG.camera.scroll.x * scrollFactor.x) % _scrollW;
			if (_ppoint.x > 0) _ppoint.x -= _scrollW;
		}
		else 
		{
			_ppoint.x = (x - FlxG.camera.scroll.x * scrollFactor.x);
		}

		// find y position
		if (_repeatY)
		{
			_ppoint.y = (y - FlxG.camera.scroll.y * scrollFactor.y) % _scrollH;
			if (_ppoint.y > 0) _ppoint.y -= _scrollH;
		}
		else 
		{
			_ppoint.y = (y - FlxG.camera.scroll.y * scrollFactor.y);
		}

		// draw to the screen
		FlxG.camera.buffer.copyPixels(_data, _data.rect, _ppoint, null, null, true);
	}
}