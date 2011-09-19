/**
 * SineWaveFX - Special FX Plugin
 * -- Part of the Flixel Power Tools set
 * 
 * v1.0 First release
 * 
 * @version 1.0 - May 21st 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm.FX 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	
	/**
	 * Creates a sine-wave effect through an FlxSprite which can be applied vertically or horizontally
	 */
	public class SineWaveFX extends BaseFX
	{
		private var waveType:uint;
		private var waveVertical:Boolean;
		private var waveLength:uint;
		private var waveSize:uint;
		private var waveFrequency:Number;
		private var wavePixelChunk:uint;
		private var waveData:Array;
		private var waveDataCounter:uint = 0;
		private var waveLoopCallback:Function;
		
		public static const WAVETYPE_VERTICAL_SINE:uint = 0;
		public static const WAVETYPE_VERTICAL_COSINE:uint = 1;
		public static const WAVETYPE_HORIZONTAL_SINE:uint = 2;
		public static const WAVETYPE_HORIZONTAL_COSINE:uint = 3;
		
		public function SineWaveFX() 
		{
		}
		
		/**
		 * Creates a new SineWaveFX Effect from the given FlxSprite. The original sprite remains unmodified.<br>
		 * The resulting FlxSprite will take on the same width / height and x/y coordinates of the source FlxSprite.<br>
		 * For really cool effects you can SineWave an FlxSprite that is constantly updating (either through animation or an FX chain).
		 * 
		 * @param	source				The FlxSprite providing the image data for this effect. The resulting FlxSprite takes on the source width, height, x/y positions and scrollfactor.
		 * @param	type				WAVETYPE_VERTICAL_SINE, WAVETYPE_VERTICAL_COSINE, WAVETYPE_HORIZONTAL_SINE or WAVETYPE_HORIZONTAL_COSINE
		 * @param	size				The size in pixels of the sine wave. Either the height of the wave or the width (for vertical or horizontal waves)
		 * @param	length				The length of the wave in pixels. You should usually set this to the width or height of the source image, or a multiple of it.
		 * @param	frequency			The frequency of the peaks in the wave. MUST BE AN EVEN NUMBER! 2, 4, 6, 8, etc.
		 * @param	pixelsPerChunk		How many pixels to use per step. Higher numbers make a more chunky but faster effect. Make sure source.width/height divides by this value evenly.
		 * @param	updateFrame			When this effect is created it takes a copy of the source image data and stores it. Set this to true to grab a new copy of the image data every frame.
		 * @param	backgroundColor		The background color (0xAARRGGBB format) to draw behind the effect (default 0x0 = transparent)
		 * @return	An FlxSprite with the effect running through it, which should be started with a call to SineWaveFX.start()
		 */
		public function createFromFlxSprite(source:FlxSprite, type:uint, size:uint, length:uint, frequency:uint = 2, pixelsPerChunk:uint = 1, updateFrame:Boolean = false, backgroundColor:uint = 0x0):FlxSprite
		{
			var result:FlxSprite = create(source.pixels, source.x, source.y, type, size, length, frequency, pixelsPerChunk, backgroundColor);
			
			updateFromSource = updateFrame;
			
			if (updateFromSource)
			{
				sourceRef = source;
			}
			
			return result;
		}
		
		/**
		 * Creates a new SineWaveFX Effect from the given Class (which must contain a Bitmap).<br>
		 * If you need to update the source data at run-time then use createFromFlxSprite
		 * 
		 * @param	source				The Class providing the bitmapData for this effect, usually from an Embedded bitmap.
		 * @param	x					The x coordinate (in game world pixels) that the resulting FlxSprite will be created at.
		 * @param	y					The x coordinate (in game world pixels) that the resulting FlxSprite will be created at.
		 * @param	type				WAVETYPE_VERTICAL_SINE, WAVETYPE_VERTICAL_COSINE, WAVETYPE_HORIZONTAL_SINE or WAVETYPE_HORIZONTAL_COSINE
		 * @param	size				The size in pixels of the sine wave. Either the height of the wave or the width (for vertical or horizontal waves)
		 * @param	length				The length of the wave in pixels. You should usually set this to the width or height of the source image, or a multiple of it.
		 * @param	frequency			The frequency of the peaks in the wave. MUST BE AN EVEN NUMBER! 2, 4, 6, 8, etc.
		 * @param	pixelsPerChunk		How many pixels to use per step. Higher numbers make a more chunky but faster effect. Make sure source.width/height divides by this value evenly.
		 * @param	backgroundColor		The background color in 0xAARRGGBB format to draw behind the effect (default 0x0 = transparent)
		 * @return	An FlxSprite with the effect running through it, which should be started with a call to SineWaveFX.start()
		 */
		public function createFromClass(source:Class, x:int, y:int, type:uint, size:uint, length:uint, frequency:uint = 2, pixelsPerChunk:uint = 1, backgroundColor:uint = 0x0):FlxSprite
		{
			var result:FlxSprite = create((new source).bitmapData, x, y, type, size, length, frequency, pixelsPerChunk, backgroundColor);
			
			updateFromSource = false;
			
			return result;
		}
		
		/**
		 * Creates a new SineWaveFX Effect from the given bitmapData.<br>
		 * If you need to update the source data at run-time then use createFromFlxSprite
		 * 
		 * @param	source				The bitmapData image to use for this effect.
		 * @param	x					The x coordinate (in game world pixels) that the resulting FlxSprite will be created at.
		 * @param	y					The x coordinate (in game world pixels) that the resulting FlxSprite will be created at.
		 * @param	type				WAVETYPE_VERTICAL_SINE, WAVETYPE_VERTICAL_COSINE, WAVETYPE_HORIZONTAL_SINE or WAVETYPE_HORIZONTAL_COSINE
		 * @param	size				The size in pixels of the sine wave. Either the height of the wave or the width (for vertical or horizontal waves)
		 * @param	length				The length of the wave in pixels. You should usually set this to the width or height of the source image, or a multiple of it.
		 * @param	frequency			The frequency of the peaks in the wave. MUST BE AN EVEN NUMBER! 2, 4, 6, 8, etc.
		 * @param	pixelsPerChunk		How many pixels to use per step. Higher numbers make a more chunky but faster effect. Make sure source.width/height divides by this value evenly.
		 * @param	backgroundColor		The background color in 0xAARRGGBB format to draw behind the effect (default 0x0 = transparent)
		 * @return	An FlxSprite with the effect running through it, which should be started with a call to SineWaveFX.start()
		 */
		public function createFromBitmapData(source:BitmapData, x:int, y:int, type:uint, size:uint, length:uint, frequency:uint = 2, pixelsPerChunk:uint = 1, backgroundColor:uint = 0x0):FlxSprite
		{
			var result:FlxSprite = create(source, x, y, type, size, length, frequency, pixelsPerChunk, backgroundColor);
			
			updateFromSource = false;
			
			return result;
		}
		
		/**
		 * Internal function fed from createFromFlxSprite / createFromClass / createFromBitmapData
		 * 
		 * @param	source				The bitmapData image to use for this effect.
		 * @param	x					The x coordinate (in game world pixels) that the resulting FlxSprite will be created at.
		 * @param	y					The x coordinate (in game world pixels) that the resulting FlxSprite will be created at.
		 * @param	type				WAVETYPE_VERTICAL_SINE, WAVETYPE_VERTICAL_COSINE, WAVETYPE_HORIZONTAL_SINE or WAVETYPE_HORIZONTAL_COSINE
		 * @param	size				The size in pixels of the sine wave. Either the height of the wave or the width (for vertical or horizontal waves)
		 * @param	length				The length of the wave in pixels. You should usually set this to the width or height of the source image, or a multiple of it.
		 * @param	frequency			The frequency of the peaks in the wave. MUST BE AN EVEN NUMBER! 2, 4, 6, 8, etc.
		 * @param	pixelsPerChunk		How many pixels to use per step. Higher numbers make a more chunky but faster effect. Make sure source.width/height divides by this value evenly.
		 * @param	backgroundColor		The background color in 0xAARRGGBB format to draw behind the effect (default 0x0 = transparent)
		 * @return	An FlxSprite with the effect running through it, which should be started with a call to SineWaveFX.start()
		 */
		private function create(source:BitmapData, x:int, y:int, type:uint, size:uint, length:uint, frequency:uint = 2, pixelsPerChunk:uint = 1, backgroundColor:uint = 0x0):FlxSprite
		{
			if (type == WAVETYPE_VERTICAL_SINE || type == WAVETYPE_VERTICAL_COSINE)
			{
				waveVertical = true;
				
				if (pixelsPerChunk >= source.width)
				{
					throw new Error("SineWaveFX: pixelsPerChunk cannot be >= source.width with WAVETYPE_VERTICAL");
				}
			}
			else if (type == WAVETYPE_HORIZONTAL_SINE || type == WAVETYPE_HORIZONTAL_COSINE)
			{
				waveVertical = false;
				
				if (pixelsPerChunk >= source.height)
				{
					throw new Error("SineWaveFX: pixelsPerChunk cannot be >= source.height with WAVETYPE_HORIZONTAL");
				}
			}
			
			updateWaveData(type, size, length, frequency, pixelsPerChunk);
			
			//	The FlxSprite into which the sine-wave effect is drawn
			
			if (waveVertical)
			{
				sprite = new FlxSprite(x, y).makeGraphic(source.width, source.height + (waveSize * 3), backgroundColor);
			}
			else
			{
				sprite = new FlxSprite(x, y).makeGraphic(source.width + (waveSize * 3), source.height, backgroundColor);
			}
			
			//	The scratch bitmapData where we prepare the final sine-waved image
			canvas = new BitmapData(sprite.width, sprite.height, true, backgroundColor);
			
			//	Our local copy of the sprite image data
			image = source.clone();
			
			clsColor = backgroundColor;
			clsRect = new Rectangle(0, 0, canvas.width, canvas.height);
			
			copyPoint = new Point(0, 0);
			
			if (waveVertical)
			{
				copyRect = new Rectangle(0, 0, wavePixelChunk, image.height);
			}
			else
			{
				copyRect = new Rectangle(0, 0, image.width, wavePixelChunk);
			}
			
			active = true;
			
			return sprite;
		}
		
		/**
		 * Update the SineWave data without modifying the source image being used.<br>
		 * This call is fast enough that you can modify it in real-time.
		 * 
		 * @param	type				WAVETYPE_VERTICAL_SINE, WAVETYPE_VERTICAL_COSINE, WAVETYPE_HORIZONTAL_SINE or WAVETYPE_HORIZONTAL_COSINE
		 * @param	size				The size in pixels of the sine wave. Either the height of the wave or the width (for vertical or horizontal waves)
		 * @param	length				The length of the wave in pixels. You should usually set this to the width or height of the source image, or a multiple of it.
		 * @param	frequency			The frequency of the peaks in the wave. MUST BE AN EVEN NUMBER! 2, 4, 6, 8, etc.
		 * @param	pixelsPerChunk		How many pixels to use per step. Higher numbers make a more chunky but faster effect. Make sure source.width/height divides by this value evenly.
		 */
		public function updateWaveData(type:uint, size:uint, length:uint, frequency:uint = 2, pixelsPerChunk:uint = 1):void
		{
			if (type > WAVETYPE_HORIZONTAL_COSINE)
			{
				throw new Error("SineWaveFX: Invalid WAVETYPE");
			}
			
			if (FlxMath.isOdd(frequency))
			{
				throw new Error("SineWaveFX: frequency must be an even number");
			}
			
			waveType = type;
			waveSize = uint(size * 0.5);
			waveLength = uint(length / pixelsPerChunk);
			waveFrequency = frequency;
			wavePixelChunk = pixelsPerChunk;
			waveData = FlxMath.sinCosGenerator(waveLength, waveSize, waveSize, waveFrequency);
			
			if (waveType == WAVETYPE_VERTICAL_COSINE || waveType == WAVETYPE_HORIZONTAL_COSINE)
			{
				waveData = FlxMath.getCosTable();
			}
		}
		
		/**
		 * Use this to set a function to be called every time the wave has completed one full cycle.<br>
		 * Set to null to remove any previous callback.
		 * 
		 * @param	callback		The function to call every time the wave completes a full cycle (duration will vary based on waveLength)
		 */
		public function setLoopCompleteCallback(callback:Function):void
		{
			waveLoopCallback = callback;
		}
		
		/**
		 * Called by the FlxSpecialFX plugin. Should not be called directly.
		 */
		public function draw():void
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
					image = sourceRef.framePixels;
				}
				
				canvas.lock();
				canvas.fillRect(clsRect, clsColor);
				
				var s:uint = 0;
				
				copyRect.x = 0;
				copyRect.y = 0;
				
				if (waveVertical)
				{
					for (var x:int = 0; x < image.width; x += wavePixelChunk)
					{
						copyPoint.x = x;
						copyPoint.y = waveSize + (waveSize / 2) + waveData[s];
						
						canvas.copyPixels(image, copyRect, copyPoint);
						
						copyRect.x += wavePixelChunk;
						
						s++;
					}
				}
				else
				{
					for (var y:int = 0; y < image.height; y += wavePixelChunk)
					{
						copyPoint.x = waveSize + (waveSize / 2) + waveData[s];
						copyPoint.y = y;
						
						canvas.copyPixels(image, copyRect, copyPoint);
						
						copyRect.y += wavePixelChunk;
						
						s++;
					}
				}
				
				//	Cycle through the wave data - this is what causes the image to "undulate"
				var t:Number = waveData.shift();
				waveData.push(t);
				
				waveDataCounter++;
				
				if (waveDataCounter == waveData.length)
				{
					waveDataCounter = 0;
					
					if (waveLoopCallback is Function)
					{
						waveLoopCallback.call();
					}
				}
				
				canvas.unlock();
				
				lastUpdate = 0;
				
				sprite.pixels = canvas;
				sprite.dirty = true;
			}
		}
		
		public function toString():String
		{
			var output:Array = [ "Type: " + waveType, "Size: " + waveSize, "Length: " + waveLength, "Frequency: " + waveFrequency, "Chunks: " + wavePixelChunk, "clsRect: " + clsRect ];
			
			return output.join(",");
		}
		
	}

}