package org.flixel.addons;

import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.system.layer.DrawStackItem;

/**
 * Used for showing infinitely scrolling backgrounds.
 * @author Chevy Ray
 */
class FlxBackdrop extends FlxObject
{
	private var _ppoint:Point;
	private var _scrollW:Int;
	private var _scrollH:Int;
	private var _repeatX:Bool;
	private var _repeatY:Bool;
	
	#if !flash
	private var _tileID:Int;
	private var _tileInfo:Array<Float>;
	private var _numTiles:Int = 0;
	#else
	private var _data:BitmapData;
	#end
	
	/**
	 * Creates an instance of the FlxBackdrop class, used to create infinitely scrolling backgrounds.
	 * @param   bitmap The image you want to use for the backdrop.
	 * @param   scrollX Scrollrate on the X axis.
	 * @param   scrollY Scrollrate on the Y axis.
	 * @param   repeatX If the backdrop should repeat on the X axis.
	 * @param   repeatY If the backdrop should repeat on the Y axis.
	 */
	public function new(graphic:Dynamic, scrollX:Float = 1, scrollY:Float = 1, repeatX:Bool = true, repeatY:Bool = true) 
	{
		super();
		
		var data:BitmapData = FlxG.addBitmap(graphic);
		var w:Int = data.width;
		var h:Int = data.height;
		if (repeatX) w += FlxG.width;
		if (repeatY) h += FlxG.height;
		
		#if flash
		_data = new BitmapData(w, h);
		#end
		_ppoint = new Point();

		_scrollW = data.width;
		_scrollH = data.height;
		_repeatX = repeatX;
		_repeatY = repeatY;
		
		#if !flash
		_bitmapDataKey = FlxG._lastBitmapDataKey;
		_tileInfo = [];
		updateAtlasInfo();
		_numTiles = 0;
		#end

		while (_ppoint.y < h + data.height)
		{
			while (_ppoint.x < w + data.width)
			{
				#if flash
				_data.copyPixels(data, data.rect, _ppoint);
				#else
				_tileInfo.push(_ppoint.x);
				_tileInfo.push(_ppoint.y);
				_numTiles++;
				#end
				_ppoint.x += data.width;
			}
			_ppoint.x = 0;
			_ppoint.y += data.height;
		}
		
		scrollFactor.x = scrollX;
		scrollFactor.y = scrollY;
	}
	
	override public function destroy():Void 
	{
		#if flash
		if (_data != null)
		{
			_data.dispose();
		}
		_data = null;
		#else
		_tileInfo = null;
		#end
		_ppoint = null;
		super.destroy();
	}

	override public function draw():Void
	{
		if (cameras == null)
		{
			cameras = FlxG.cameras;
		}
		var camera:FlxCamera;
		var l:Int = cameras.length;
		
		for (i in 0...(l))
		{
			camera = cameras[i];
			
			if (!camera.visible || !camera.exists)
			{
				continue;
			}
			
			// find x position
			if (_repeatX)
			{   
				_ppoint.x = (x - camera.scroll.x * scrollFactor.x) % _scrollW;
				if (_ppoint.x > 0) _ppoint.x -= _scrollW;
			}
			else 
			{
				_ppoint.x = (x - camera.scroll.x * scrollFactor.x);
			}

			// find y position
			if (_repeatY)
			{
				_ppoint.y = (y - camera.scroll.y * scrollFactor.y) % _scrollH;
				if (_ppoint.y > 0) _ppoint.y -= _scrollH;
			}
			else 
			{
				_ppoint.y = (y - camera.scroll.y * scrollFactor.y);
			}
			
			// draw to the screen
			#if flash
			camera.buffer.copyPixels(_data, _data.rect, _ppoint, null, null, true);
			#else
			if (_atlas == null)
			{
				return;
			}
			
			var currDrawData:Array<Float>;
			var currIndex:Int;
			#if !js
			var isColoredCamera:Bool = camera.isColored();
			var drawItem:DrawStackItem = camera.getDrawStackItem(_atlas, isColoredCamera, 0);
			#else
			var drawItem:DrawStackItem = camera.getDrawStackItem(_atlas, false);
			#end
			
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			var currPosInArr:Int;
			var currTileX:Float;
			var currTileY:Float;
			
			#if !js
			var redMult:Float = 1;
			var greenMult:Float = 1;
			var blueMult:Float = 1;
			
			if (isColoredCamera)
			{
				redMult = camera.red; 
				greenMult = camera.green;
				blueMult = camera.blue;
			}
			#end
			
			for (j in 0...(_numTiles))
			{
				currPosInArr = j * 2;
				currTileX = _tileInfo[currPosInArr];
				currTileY = _tileInfo[currPosInArr + 1];
				#if !js
				currDrawData[currIndex++] = (_ppoint.x) + currTileX;
				currDrawData[currIndex++] = (_ppoint.y) + currTileY;
				#else
				currDrawData[currIndex++] = Math.floor(_ppoint.x) + currTileX;
				currDrawData[currIndex++] = Math.floor(_ppoint.y) + currTileY;
				#end
				currDrawData[currIndex++] = _tileID;
				
				currDrawData[currIndex++] = 1;
				currDrawData[currIndex++] = 0;
				currDrawData[currIndex++] = 0;
				currDrawData[currIndex++] = 1;
				
				#if !js
				if (isColoredCamera)
				{
					currDrawData[currIndex++] = redMult; 
					currDrawData[currIndex++] = greenMult;
					currDrawData[currIndex++] = blueMult;
				}
				currDrawData[currIndex++] = 1.0;	// alpha
				#end
			}
			
			drawItem.position = currIndex;
			#end
		}
	}
	
	override public function updateFrameData():Void
	{
	#if !flash
		if (_node != null)
		{
			_tileID = _node.addTileRect(new Rectangle(0, 0, _scrollW, _scrollH), new Point());
		}
	#end
	}
}