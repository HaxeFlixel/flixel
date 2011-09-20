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

package org.flixel.plugin.photonstorm.fx;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.FlxSprite;
	import org.flixel.plugin.photonstorm.FlxMath;
	
	
	/**
	 * Creates a sine-wave effect through an FlxSprite which can be applied vertically or horizontally
	 */
	class SineWaveFX extends BaseFX
	{
		#if flash
		private var waveType:UInt;
		private var waveLength:UInt;
		private var waveSize:UInt;
		private var wavePixelChunk:UInt;
		private var waveDataCounter:UInt;
		#else
		private var waveType:Int;
		private var waveLength:Int;
		private var waveSize:Int;
		private var wavePixelChunk:Int;
		private var waveDataCounter:Int;
		#end
		
		private var waveVertical:Bool;
		private var waveFrequency:Float;
		private var waveData:Array<Float>;
		private var waveLoopCallback:Dynamic;
		
		#if flash
		public static inline var WAVETYPE_VERTICAL_SINE:UInt = 0;
		public static inline var WAVETYPE_VERTICAL_COSINE:UInt = 1;
		public static inline var WAVETYPE_HORIZONTAL_SINE:UInt = 2;
		public static inline var WAVETYPE_HORIZONTAL_COSINE:UInt = 3;
		#else
		public static inline var WAVETYPE_VERTICAL_SINE:Int = 0;
		public static inline var WAVETYPE_VERTICAL_COSINE:Int = 1;
		public static inline var WAVETYPE_HORIZONTAL_SINE:Int = 2;
		public static inline var WAVETYPE_HORIZONTAL_COSINE:Int = 3;
		#end
		
		public function new() 
		{
			waveDataCounter = 0;
			
			super();
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
		#if flash
		public function createFromFlxSprite(source:FlxSprite, type:UInt, size:UInt, length:UInt, ?frequency:UInt = 2, ?pixelsPerChunk:UInt = 1, updateFrame:Bool = false, ?backgroundColor:UInt = 0x0):FlxSprite
		#else
		public function createFromFlxSprite(source:FlxSprite, type:Int, size:Int, length:Int, ?frequency:Unt = 2, ?pixelsPerChunk:Int = 1, updateFrame:Bool = false, ?backgroundColor:Int = 0x0):FlxSprite
		#end
		{
			var result:FlxSprite = create(source.pixels, Math.floor(source.x), Math.floor(source.y), type, size, length, frequency, pixelsPerChunk, backgroundColor);
			
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
		#if flash
		public function createFromClass(source:Class<Bitmap>, x:Int, y:Int, type:UInt, size:UInt, length:UInt, ?frequency:UInt = 2, ?pixelsPerChunk:UInt = 1, ?backgroundColor:UInt = 0x0):FlxSprite
		#else
		public function createFromClass(source:Class<Bitmap>, x:Int, y:Int, type:Int, size:Int, length:Int, ?frequency:Int = 2, ?pixelsPerChunk:Int = 1, ?backgroundColor:Int = 0x0):FlxSprite
		#end
		{
			var result:FlxSprite = create((Type.createInstance(source, [])).bitmapData, x, y, type, size, length, frequency, pixelsPerChunk, backgroundColor);
			
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
		#if flash
		public function createFromBitmapData(source:BitmapData, x:Int, y:Int, type:UInt, size:UInt, length:UInt, ?frequency:UInt = 2, ?pixelsPerChunk:UInt = 1, ?backgroundColor:UInt = 0x0):FlxSprite
		#else
		public function createFromBitmapData(source:BitmapData, x:Int, y:Int, type:Int, size:Int, length:Int, ?frequency:Int = 2, ?pixelsPerChunk:Int = 1, ?backgroundColor:Int = 0x0):FlxSprite
		#end
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
		#if flash
		private function create(source:BitmapData, x:Int, y:Int, type:UInt, size:UInt, length:UInt, ?frequency:UInt = 2, ?pixelsPerChunk:UInt = 1, ?backgroundColor:UInt = 0x0):FlxSprite
		#else
		private function create(source:BitmapData, x:Int, y:Int, type:Int, size:Int, length:Int, ?frequency:Int = 2, ?pixelsPerChunk:Int = 1, ?backgroundColor:Int = 0x0):FlxSprite
		#end
		{
			if (type == WAVETYPE_VERTICAL_SINE || type == WAVETYPE_VERTICAL_COSINE)
			{
				waveVertical = true;
				
				if (Std.int(pixelsPerChunk) >= source.width)
				{
					throw "SineWaveFX: pixelsPerChunk cannot be >= source.width with WAVETYPE_VERTICAL";
				}
			}
			else if (type == WAVETYPE_HORIZONTAL_SINE || type == WAVETYPE_HORIZONTAL_COSINE)
			{
				waveVertical = false;
				
				if (Std.int(pixelsPerChunk) >= source.height)
				{
					throw "SineWaveFX: pixelsPerChunk cannot be >= source.height with WAVETYPE_HORIZONTAL";
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
			canvas = new BitmapData(Math.floor(sprite.width), Math.floor(sprite.height), true, backgroundColor);
			
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
		#if flash
		public function updateWaveData(type:UInt, size:UInt, length:UInt, ?frequency:UInt = 2, ?pixelsPerChunk:UInt = 1):Void
		#else
		public function updateWaveData(type:UInt, size:UInt, length:UInt, ?frequency:UInt = 2, ?pixelsPerChunk:UInt = 1):Void
		#end
		{
			if (type > WAVETYPE_HORIZONTAL_COSINE)
			{
				throw "SineWaveFX: Invalid WAVETYPE";
			}
			
			if (FlxMath.isOdd(frequency))
			{
				throw "SineWaveFX: frequency must be an even number";
			}
			
			waveType = type;
			waveSize = cast(Math.floor(size * 0.5), UInt);
			waveLength = cast(Math.floor(length / pixelsPerChunk), UInt);
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
		public function setLoopCompleteCallback(callbackFunc:Dynamic):Void
		{
			waveLoopCallback = callbackFunc;
		}
		
		/**
		 * Called by the FlxSpecialFX plugin. Should not be called directly.
		 */
		public function draw():Void
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
				
				var s:UInt = 0;
				
				copyRect.x = 0;
				copyRect.y = 0;
				
				if (waveVertical)
				{
					var x:Int = 0;
					while (x < image.width)
					{
						copyPoint.x = x;
						copyPoint.y = waveSize + (waveSize / 2) + waveData[s];
						
						canvas.copyPixels(image, copyRect, copyPoint);
						
						copyRect.x += wavePixelChunk;
						
						s++;
						x += wavePixelChunk;
					}
				}
				else
				{
					var y:Int = 0;
					while (y < image.height)
					{
						copyPoint.x = waveSize + (waveSize / 2) + waveData[s];
						copyPoint.y = y;
						
						canvas.copyPixels(image, copyRect, copyPoint);
						
						copyRect.y += wavePixelChunk;
						
						s++;
						y += wavePixelChunk;
					}
				}
				
				//	Cycle through the wave data - this is what causes the image to "undulate"
				var t:Float = waveData.shift();
				waveData.push(t);
				
				waveDataCounter++;
				
				if (Std.int(waveDataCounter) == waveData.length)
				{
					waveDataCounter = 0;
					
					if (waveLoopCallback != null)
					{
						Reflect.callMethod(this, waveLoopCallback, []);
						//waveLoopCallback.call();
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
			var output:Array<String> = [ "Type: " + waveType, "Size: " + waveSize, "Length: " + waveLength, "Frequency: " + waveFrequency, "Chunks: " + wavePixelChunk, "clsRect: " + clsRect ];
			
			return output.join(",");
		}
		
	}