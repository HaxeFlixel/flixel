package org.flixel;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.display.Graphics;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;

#if (cpp || neko)
import org.flixel.tileSheetManager.TileSheetData;
import org.flixel.tileSheetManager.TileSheetManager;
#end

#if flash
import flash.display.BlendMode;
#end

import org.flixel.system.FlxAnim;


/**
 * The main "game object" class, the sprite is a <code>FlxObject</code>
 * with a bunch of graphics options and abilities, like animation and stamping.
 */
class FlxSprite extends FlxObject
{
	public var facing(getFacing, setFacing):Int;
	
	#if flash
	public var color(getColor, setColor):UInt;
	public var frame(getFrame, setFrame):UInt;
	#else
	public var color(getColor, setColor):BitmapInt32;
	public var frame(getFrame, setFrame):Int;
	#end
	
	/**
	 * WARNING: The origin of the sprite will default to its center.
	 * If you change this, the visuals and the collisions will likely be
	 * pretty out-of-sync if you do any rotation.
	 */
	public var origin:FlxPoint;
	/**
	* If you changed the size of your sprite object after loading or making the graphic,
	* you might need to offset the graphic away from the bound box to center it the way you want.
	*/
	public var offset:FlxPoint;
	
	/**
	 * Change the size of your sprite's graphic.
	 * NOTE: Scale doesn't currently affect collisions automatically,
	 * you will need to adjust the width, height and offset manually.
	 * WARNING: scaling sprites decreases rendering performance for this sprite by a factor of 10x!
	 */
	public var scale:FlxPoint;
	/**
	 * Blending modes, just like Photoshop or whatever.
	 * E.g. "multiply", "screen", etc.
	 * @default null
	 */
	#if flash
	public var blend:BlendMode;
	#else
	public var blend:String;
	#end
	/**
	 * Controls whether the object is smoothed when rotated, affects performance.
	 * @default false
	 */
	#if flash
	public var antialiasing:Bool;
	#else
	private var _antialiasing:Bool;
	#end
	/**
	 * Whether the current animation has finished its first (or only) loop.
	 */
	public var finished:Bool;
	/**
	 * The width of the actual graphic or image being displayed (not necessarily the game object/bounding box).
	 * NOTE: Edit at your own risk!!  This is intended to be read-only.
	 */
	#if flash
	public var frameWidth:UInt;
	#else
	public var frameWidth:Int;
	#end
	/**
	 * The height of the actual graphic or image being displayed (not necessarily the game object/bounding box).
	 * NOTE: Edit at your own risk!!  This is intended to be read-only.
	 */
	#if flash
	public var frameHeight:UInt;
	#else
	public var frameHeight:Int;
	#end
	/**
	 * The total number of frames in this image.  WARNING: assumes each row in the sprite sheet is full!
	 */
	#if flash
	public var frames:UInt;
	#else
	public var frames:Int;
	#end
	/**
	 * The actual Flash <code>BitmapData</code> object representing the current display state of the sprite.
	 */
	public var framePixels:BitmapData;
	/**
	 * Set this flag to true to force the sprite to update during the draw() call.
	 * NOTE: Rarely if ever necessary, most sprite operations will flip this flag automatically.
	 */
	public var dirty:Bool;
	
	/**
	 * Internal, stores all the animations that were added to this sprite.
	 */
	private var _animations:Array<FlxAnim>;
	/**
	 * Internal, keeps track of whether the sprite was loaded with support for automatic reverse/mirroring.
	 */
	#if flash
	private var _flipped:UInt;
	#else
	private var _flipped:Int;
	#end
	/**
	 * Internal, keeps track of the current animation being played.
	 */
	private var _curAnim:FlxAnim;
	/**
	 * Internal, keeps track of the current frame of animation.
	 * This is NOT an index into the tile sheet, but the frame number in the animation object.
	 */
	#if flash
	private var _curFrame:UInt;
	#else
	private var _curFrame:Int;
	#end
	/**
	 * Internal, keeps track of the current index into the tile sheet based on animation or rotation.
	 */
	#if flash
	private var _curIndex:UInt;
	#else
	private var _curIndex:Int;
	#end
	/**
	 * Internal, used to time each frame of animation.
	 */
	private var _frameTimer:Float;
	/**
	 * Internal tracker for the animation callback.  Default is null.
	 * If assigned, will be called each time the current frame changes.
	 * A function that has 3 parameters: a string name, a uint frame number, and a uint frame index.
	 */
	#if flash
	private var _callback:String->UInt->UInt->Void;
	#else
	private var _callback:String->Int->Int->Void;
	#end
	/**
	 * Internal tracker for what direction the sprite is currently facing, used with Flash getter/setter.
	 */
	private var _facing:Int;
	/**
	 * Internal tracker for opacity, used with Flash getter/setter.
	 */
	private var _alpha:Float;
	/**
	 * Internal tracker for color tint, used with Flash getter/setter.
	 */
	#if flash
	private var _color:UInt;
	#else
	private var _color:BitmapInt32;
	#end
	/**
	 * Internal tracker for how many frames of "baked" rotation there are (if any).
	 */
	private var _bakedRotation:Float;
	/**
	 * Internal, stores the entire source graphic (not the current displayed animation frame), used with Flash getter/setter.
	 */
	private var _pixels:BitmapData;
	
	/**
	 * Internal, reused frequently during drawing and animating.
	 */
	private var _flashPoint:Point;
	/**
	 * Internal, reused frequently during drawing and animating.
	 */
	private var _flashRect:Rectangle;
	/**
	 * Internal, reused frequently during drawing and animating.
	 */
	private var _flashRect2:Rectangle;
	/**
	 * Internal, reused frequently during drawing and animating. Always contains (0,0).
	 */
	private var _flashPointZero:Point;
	/**
	 * Internal, helps with animation, caching and drawing.
	 */
	private var _colorTransform:ColorTransform;
	/**
	 * Internal, helps with animation, caching and drawing.
	 */
	private var _matrix:Matrix;
	
	#if (cpp || neko)
	private var _tileSheetData:TileSheetData;
	private var _framesData:FlxSpriteFrames;
	private var _frameID:Int;
	private var _red:Float;
	private var _green:Float;
	private var _blue:Float;
	#end
	
	/**
	 * Creates a white 8x8 square <code>FlxSprite</code> at the specified position.
	 * Optionally can load a simple, one-frame graphic instead.
	 * @param	X				The initial X position of the sprite.
	 * @param	Y				The initial Y position of the sprite.
	 * @param	SimpleGraphic	The graphic you want to display (OPTIONAL - for simple stuff only, do NOT use for animated images!).
	 */
	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:Dynamic = null)
	{
		super(X, Y);
		
		_flashPoint = new Point();
		_flashRect = new Rectangle();
		_flashRect2 = new Rectangle();
		_flashPointZero = new Point();
		offset = new FlxPoint();
		origin = new FlxPoint();
		
		scale = new FlxPoint(1.0, 1.0);
		_alpha = 1.0;
		#if neko
		_color = { rgb: 0xffffff, a:0x00 };
		#else
		_color = 0x00ffffff;
		#end
		blend = null;
		antialiasing = false;
		cameras = null;
		
		finished = false;
		_facing = FlxObject.RIGHT;
		_animations = new Array<FlxAnim>();
		_flipped = 0;
		_curAnim = null;
		_curFrame = 0;
		_curIndex = 0;
		_frameTimer = 0;

		_matrix = new Matrix();
		_callback = null;
		
		#if (cpp || neko)
		_red = 1.0;
		_green = 1.0;
		_blue = 1.0;
		
		_frameID = 0;
		#end
		
		if (SimpleGraphic == null)
		{
			SimpleGraphic = FlxAssets.imgDefault;
		}
		loadGraphic(SimpleGraphic);
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		if(_animations != null)
		{
			var a:FlxAnim;
			var i:Int = 0;
			var l:Int = _animations.length;
			while(i < l)
			{
				a = _animations[i++];
				if (a != null)
				{
					a.destroy();
				}
			}
			_animations = null;
		}
		
		_flashPoint = null;
		_flashRect = null;
		_flashRect2 = null;
		_flashPointZero = null;
		offset = null;
		origin = null;
		scale = null;
		_curAnim = null;
		_matrix = null;
		_callback = null;
		if (framePixels != null)
		{
			framePixels.dispose();
		}
		framePixels = null;
		
		#if (cpp || neko)
		_framesData = null;
		_tileSheetData = null;
		#end
		
		super.destroy();
	}
	
	/**
	 * Load graphic from another FlxSprite and copy it's tileSheet data. This method usefull for non-flash targets
	 * @param	Sprite			The FlxSprite from which you want to load graphic data
	 * @param	AutoBuffer		Use this parameter when loading graphic from FlxSprite with "rotated" graphic (graphic loaded with loadRotatedGraphic() method). It should have the same value as you passed to loadRotatedGraphic() method for original FlxSprite.
	 * @return					This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadFrom(Sprite:FlxSprite, ?AutoBuffer:Bool = false):FlxSprite
	{
		_pixels = Sprite.pixels;
		_flipped = Sprite.flipped;
		_bakedRotation = Sprite.bakedRotation;
		
		width = frameWidth = Sprite.frameWidth;
		height = frameHeight = Sprite.frameHeight;
		resetHelpers();
		if (_bakedRotation > 0 && AutoBuffer == true)
		{
			width = Sprite.width;
			height = Sprite.height;
			centerOffsets();
		}
		
		#if (cpp || neko)
		_antialiasing = Sprite.antialiasing;
		updateTileSheet();
		#end
		
		return this;
	}
	
	/**
	 * Load an image from an embedded graphic file.
	 * @param	Graphic		The image you want to use.
	 * @param	Animated	Whether the Graphic parameter is a single sprite or a row of sprites.
	 * @param	Reverse		Whether you need this class to generate horizontally flipped versions of the animation frames.
	 * @param	Width		Optional, specify the width of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets).
	 * @param	Height		Optional, specify the height of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets).
	 * @param	Unique		Optional, whether the graphic should be a unique instance in the graphics cache.  Default is false.
	 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadGraphic(Graphic:Dynamic, ?Animated:Bool = false, ?Reverse:Bool = false, Width:Int = 0, ?Height:Int = 0, ?Unique:Bool = false):FlxSprite
	{
		Width = FlxU.fromIntToUInt(Width);
		Height = FlxU.fromIntToUInt(Height);
		
		_bakedRotation = 0;
		#if (cpp || neko)
		_pixels = FlxG.addBitmap(Graphic, false, Unique);
		#else
		_pixels = FlxG.addBitmap(Graphic, Reverse, Unique);
		#end
		
		if (Reverse)
		{
			_flipped = _pixels.width >> 1;
		}
		else
		{
			_flipped = 0;
		}
		if (Width == 0)
		{
			if (Animated)
			{
				Width = _pixels.height;
			}
			else if (_flipped > 0)
			{
				#if flash
				Width = Math.floor(_pixels.width * 0.5);
				#else
				Width = _pixels.width;
				#end
			}
			else
			{
				Width = _pixels.width;
			}
		}
		width = frameWidth = Width;
		if (Height == 0)
		{
			if (Animated)
			{
				Height = Math.floor(width);
			}
			else
			{
				Height = _pixels.height;
			}
		}
		
		#if !flash
		_pixels = FlxG.addBitmap(Graphic, false, Unique, null, Width, Height);
		#end
		
		height = frameHeight = Height;
		resetHelpers();
		
		updateTileSheet();
		
		return this;
	}
	
	/**
	 * Create a pre-rotated sprite sheet from a simple sprite.
	 * This can make a huge difference in graphical performance!
	 * @param	Graphic			The image you want to rotate and stamp.
	 * @param	Rotations		The number of rotation frames the final sprite should have.  For small sprites this can be quite a large number (360 even) without any problems.
	 * @param	Frame			If the Graphic has a single row of square animation frames on it, you can specify which of the frames you want to use here.  Default is -1, or "use whole graphic."
	 * @param	AntiAliasing	Whether to use high quality rotations when creating the graphic.  Default is false.
	 * @param	AutoBuffer		Whether to automatically increase the image size to accomodate rotated corners.  Default is false.  Will create frames that are 150% larger on each axis than the original frame or graphic.
	 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadRotatedGraphic(Graphic:Dynamic, ?Rotations:Int = 16, ?Frame:Int = -1, ?AntiAliasing:Bool = false, ?AutoBuffer:Bool = false):FlxSprite
	{
		Rotations = FlxU.fromIntToUInt(Rotations);
		
		//Create the brush and canvas
		var rows:Int = Math.floor(Math.sqrt(Rotations));
		var brush:BitmapData = FlxG.addBitmap(Graphic);
		if (Frame >= 0)
		{
			//Using just a segment of the graphic - find the right bit here
			var full:BitmapData = brush;
			brush = new BitmapData(full.height, full.height);
			var rx:Int = Frame * brush.width;
			var ry:Int = 0;
			var fw:Int = full.width;
			if (rx >= fw)
			{
				ry = Math.floor(rx / fw) * brush.height;
				rx %= fw;
			}
			_flashRect.x = rx;
			_flashRect.y = ry;
			_flashRect.width = brush.width;
			_flashRect.height = brush.height;
			brush.copyPixels(full, _flashRect, _flashPointZero);
		}
		
		var max:Int = brush.width;
		if (brush.height > max)
		{
			max = brush.height;
		}
		
		if (AutoBuffer)
		{
			max = Math.floor(max * 1.5);
		}
		
		var columns:Int = FlxU.ceil(Rotations / rows);
		width = max * columns;
		height = max * rows;
		var key:String = "";
		if (Std.is(Graphic, String))
		{
			key = Graphic;
		}
		else if (Std.is(Graphic, Class))
		{
			key = Type.getClassName(Graphic);
		}
	#if flash
		key += ":" + Frame + ":" + width + "x" + height;
	#else
		key += ":" + Frame + ":" + width + "x" + height + ":" + Rotations;
	#end
		var skipGen:Bool = FlxG.checkBitmapCache(key);
		
		#if flash
		_pixels = FlxG.createBitmap(Math.floor(width), Math.floor(height), 0, true, key);
		#elseif cpp
		_pixels = FlxG.createBitmap(Math.floor(width) + columns, Math.floor(height) + rows, 0, true, key);
		#elseif neko
		_pixels = FlxG.createBitmap(Math.floor(width) + columns, Math.floor(height) + rows, {rgb: 0, a: 0}, true, key);
		#end
		
		width = frameWidth = _pixels.width;
		height = frameHeight = _pixels.height;
		_bakedRotation = 360 / Rotations;
		
		//Generate a new sheet if necessary, then fix up the width and height
		if (!skipGen)
		{
			var row:Int = 0;
			var column:Int;
			var bakedAngle:Float = 0;
			var halfBrushWidth:Int = Math.floor(brush.width * 0.5);
			var halfBrushHeight:Int = Math.floor(brush.height * 0.5);
			var midpointX:Int = Math.floor(max * 0.5);
			var midpointY:Int = Math.floor(max * 0.5);
			while(row < rows)
			{
				column = 0;
				while(column < columns)
				{
					_matrix.identity();
					_matrix.translate( -halfBrushWidth, -halfBrushHeight);
					_matrix.rotate(bakedAngle * 0.017453293);
					#if flash
					_matrix.translate(max * column + midpointX, midpointY);
					#else
					_matrix.translate(max * column + midpointX + column, midpointY + row);
					#end
					bakedAngle += _bakedRotation;
					_pixels.draw(brush, _matrix, null, null, null, AntiAliasing);
					column++;
				}
				midpointY += max;
				row++;
			}
		}
		frameWidth = frameHeight = max;
		width = height = max;
		resetHelpers();
		if (AutoBuffer)
		{
			width = brush.width;
			height = brush.height;
			centerOffsets();
		}
		
		#if (cpp || neko)
		_antialiasing = AntiAliasing;
		#end
		
		updateTileSheet();
		
		return this;
	}
	
	/**
	 * This function creates a flat colored square image dynamically.
	 * @param	Width		The width of the sprite you want to generate.
	 * @param	Height		The height of the sprite you want to generate.
	 * @param	Color		Specifies the color of the generated block.
	 * @param	Unique		Whether the graphic should be a unique instance in the graphics cache.  Default is false.
	 * @param	Key			Optional parameter - specify a string key to identify this graphic in the cache.  Trumps Unique flag.
	 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
	 */
	#if flash 
	public function makeGraphic(Width:UInt, Height:UInt, ?Color:UInt = 0xffffffff, ?Unique:Bool = false, ?Key:String = null):FlxSprite
	#else
	public function makeGraphic(Width:Int, Height:Int, ?Color:BitmapInt32, ?Unique:Bool = false, ?Key:String = null):FlxSprite
	#end
	{
		#if (cpp || neko)
		if (Color == null)
		{
			#if cpp
			Color = 0xffffffff;
			#elseif neko
			Color = { rgb: 0xffffff, a: 0xff };
			#end
		}
		#end
		
		_bakedRotation = 0;
		_pixels = FlxG.createBitmap(Width, Height, Color, Unique, Key);
		width = frameWidth = _pixels.width;
		height = frameHeight = _pixels.height;
		resetHelpers();
		
		updateTileSheet();
		
		return this;
	}
	
	/**
	 * Resets some important variables for sprite optimization and rendering.
	 */
	private function resetHelpers():Void
	{
		_flashRect.x = 0;
		_flashRect.y = 0;
		_flashRect.width = frameWidth;
		_flashRect.height = frameHeight;
		_flashRect2.x = 0;
		_flashRect2.y = 0;
		_flashRect2.width = _pixels.width;
		_flashRect2.height = _pixels.height;
		
		origin.make(frameWidth * 0.5, frameHeight * 0.5);
		
	#if flash
		if ((framePixels == null) || (framePixels.width != width) || (framePixels.height != height))
		{
			framePixels = new BitmapData(Math.floor(width), Math.floor(height));
		}
		framePixels.copyPixels(_pixels, _flashRect, _flashPointZero);
		if (_colorTransform != null) framePixels.colorTransform(_flashRect, _colorTransform);
		
		frames = Math.floor(_flashRect2.width / _flashRect.width * _flashRect2.height / _flashRect.height);
	#else
		frames = Math.floor(_flashRect2.width / (_flashRect.width + 1) * _flashRect2.height / (_flashRect.height + 1));
		if (_flipped > 0)
		{
			frames *= 2;
		}
	#end
		_curIndex = 0;
		#if (cpp || neko)
		if (_framesData != null)
		{
			_frameID = _framesData.frameIDs[_curIndex];
		}
		#end
	}
	
	/**
	 * Automatically called after update() by the game loop,
	 * this function just calls updateAnimation().
	 */
	override public function postUpdate():Void
	{
		super.postUpdate();
		updateAnimation();
	}
	
	/**
	 * Called by game loop, updates then blits or renders current frame of animation to the screen
	 */
	override public function draw():Void
	{
		if(_flickerTimer != 0)
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
			cameras = FlxG.cameras;
		}
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		#if (cpp || neko)
		var currDrawData:Array<Float>;
		var currIndex:Int;
		
		var radians:Float;
		var cos:Float;
		var sin:Float;
		#end
		
		while(i < l)
		{
			camera = cameras[i++];
			
			if (!onScreen(camera))
			{
				continue;
			}
			_point.x = x - Math.floor(camera.scroll.x * scrollFactor.x) - Math.floor(offset.x);
			_point.y = y - Math.floor(camera.scroll.y * scrollFactor.y) - Math.floor(offset.y);
			
			#if (cpp || neko)
			currDrawData = _tileSheetData.drawData[camera.ID];
			currIndex = _tileSheetData.positionData[camera.ID];
			
			_point.x = Math.floor(_point.x) + origin.x;
			_point.y = Math.floor(_point.y) + origin.y;
			#else
			_point.x += (_point.x > 0)?0.0000001:-0.0000001;
			_point.y += (_point.y > 0)?0.0000001: -0.0000001;
			#end
			if (simpleRender)
			{	//Simple render
				#if flash
				_flashPoint.x = _point.x;
				_flashPoint.y = _point.y;
				camera.buffer.copyPixels(framePixels, _flashRect, _flashPoint, null, null, true);
				#else
				currDrawData[currIndex++] = _point.x;
				currDrawData[currIndex++] = _point.y;
				
				currDrawData[currIndex++] = _frameID;
				
				// handle reversed sprites
				if ((_flipped != 0) && (_facing == FlxObject.LEFT))
				{
					currDrawData[currIndex++] = -1;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 1;
				}
				else
				{
					currDrawData[currIndex++] = 1;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 1;
				}
				
				if (_tileSheetData.isColored || camera.isColored)
				{
					if (camera.isColored)
					{
						currDrawData[currIndex++] = _red * camera.red; 
						currDrawData[currIndex++] = _green * camera.green;
						currDrawData[currIndex++] = _blue * camera.blue;
					}
					else
					{
						currDrawData[currIndex++] = _red; 
						currDrawData[currIndex++] = _green;
						currDrawData[currIndex++] = _blue;
					}
				}
				
				currDrawData[currIndex++] = _alpha;
				
				_tileSheetData.positionData[camera.ID] = currIndex;
				#end
			}
			else
			{	//Advanced render
				#if flash
				_matrix.identity();
				_matrix.translate( -origin.x, -origin.y);
				_matrix.scale(scale.x, scale.y);
				if ((angle != 0) && (_bakedRotation <= 0))
				{
					_matrix.rotate(angle * 0.017453293);
				}
				_matrix.translate(_point.x + origin.x, _point.y + origin.y);
				camera.buffer.draw(framePixels, _matrix, null, blend, null, antialiasing);
				#else
				radians = -angle * 0.017453293;
				cos = Math.cos(radians);
				sin = Math.sin(radians);
				
				currDrawData[currIndex++] = _point.x;
				currDrawData[currIndex++] = _point.y;
				
				currDrawData[currIndex++] = _frameID;
				
				if ((_flipped != 0) && (_facing == FlxObject.LEFT))
				{
					currDrawData[currIndex++] = -cos * scale.x;
					currDrawData[currIndex++] = sin * scale.y;
					currDrawData[currIndex++] = -sin * scale.x;
					currDrawData[currIndex++] = cos * scale.y;
				}
				else
				{
					currDrawData[currIndex++] = cos * scale.x;
					currDrawData[currIndex++] = sin * scale.y;
					currDrawData[currIndex++] = -sin * scale.x;
					currDrawData[currIndex++] = cos * scale.y;
				}
				
				if (_tileSheetData.isColored || camera.isColored)
				{
					if (camera.isColored)
					{
						currDrawData[currIndex++] = _red * camera.red; 
						currDrawData[currIndex++] = _green * camera.green;
						currDrawData[currIndex++] = _blue * camera.blue;
					}
					else
					{
						currDrawData[currIndex++] = _red; 
						currDrawData[currIndex++] = _green;
						currDrawData[currIndex++] = _blue;
					}
				}
				
				currDrawData[currIndex++] = _alpha;
				
				_tileSheetData.positionData[camera.ID] = currIndex;
				#end
			}
			FlxBasic._VISIBLECOUNT++;
			if (FlxG.visualDebug && !ignoreDrawDebug)
			{
				drawDebug(camera);
			}
		}
	}
	
	/**
	 * This function draws or stamps one <code>FlxSprite</code> onto another.
	 * This function is NOT intended to replace <code>draw()</code>!
	 * @param	Brush		The image you want to use as a brush or stamp or pen or whatever.
	 * @param	X			The X coordinate of the brush's top left corner on this sprite.
	 * @param	Y			They Y coordinate of the brush's top left corner on this sprite.
	 */
	public function stamp(Brush:FlxSprite, ?X:Int = 0, Y:Int = 0):Void
	{
		Brush.drawFrame();
		var bitmapData:BitmapData = Brush.framePixels;
		
		//Simple draw
		if(((Brush.angle == 0) || (Brush._bakedRotation > 0)) && (Brush.scale.x == 1) && (Brush.scale.y == 1) && (Brush.blend == null))
		{
			_flashPoint.x = X;
			_flashPoint.y = Y;
			_flashRect2.width = bitmapData.width;
			_flashRect2.height = bitmapData.height;
			_pixels.copyPixels(bitmapData, _flashRect2, _flashPoint, null, null, true);
			_flashRect2.width = _pixels.width;
			_flashRect2.height = _pixels.height;
			#if flash
			calcFrame();
			#end
			return;
		}
		
		//Advanced draw
		_matrix.identity();
		_matrix.translate(-Brush.origin.x, -Brush.origin.y);
		_matrix.scale(Brush.scale.x, Brush.scale.y);
		if (Brush.angle != 0)
		{
			_matrix.rotate(Brush.angle * 0.017453293);
		}
		_matrix.translate(X + Brush.origin.x, Y + Brush.origin.y);
		#if flash
		var brushBlend:BlendMode = cast(Brush.blend, BlendMode);
		#else
		var brushBlend:String = Brush.blend;
		#end
		_pixels.draw(bitmapData, _matrix, null, brushBlend, null, Brush.antialiasing);
		#if flash
		calcFrame();
		#end
		
		updateTileSheet();
	}
	
	/**
	 * This function draws a line on this sprite from position X1,Y1
	 * to position X2,Y2 with the specified color.
	 * @param	StartX		X coordinate of the line's start point.
	 * @param	StartY		Y coordinate of the line's start point.
	 * @param	EndX		X coordinate of the line's end point.
	 * @param	EndY		Y coordinate of the line's end point.
	 * @param	Color		The line's color.
	 * @param	Thickness	How thick the line is in pixels (default value is 1).
	 */
	#if flash
	public function drawLine(StartX:Float, StartY:Float, EndX:Float, EndY:Float, Color:UInt, ?Thickness:UInt = 1):Void
	#else
	public function drawLine(StartX:Float, StartY:Float, EndX:Float, EndY:Float, Color:BitmapInt32, ?Thickness:Int = 1):Void
	#end
	{
		//Draw line
		var gfx:Graphics = FlxG.flashGfx;
		gfx.clear();
		gfx.moveTo(StartX, StartY);
		#if !neko
		var alphaComponent:Float = ((Color >> 24) & 255) / 255;
		#else
		var alphaComponent:Float = Color.a / 255;
		#end
		if (alphaComponent <= 0)
		{
			alphaComponent = 1;
		}
		#if neko
		gfx.lineStyle(Thickness, Color.rgb, alphaComponent);
		#else
		gfx.lineStyle(Thickness, Color, alphaComponent);
		#end
		gfx.lineTo(EndX, EndY);
		
		//Cache line to bitmap
		_pixels.draw(FlxG.flashGfxSprite);
		dirty = true;
		
		updateTileSheet();
	}
	
	/**
	 * Fills this sprite's graphic with a specific color.
	 * @param	Color		The color with which to fill the graphic, format 0xAARRGGBB.
	 */
	#if flash
	public function fill(Color:UInt):Void
	#else
	public function fill(Color:BitmapInt32):Void
	#end
	{
		_pixels.fillRect(_flashRect2, Color);
		if (_pixels != framePixels)
		{
			dirty = true;
		}
		
		updateTileSheet();
	}
	
	/**
	 * Internal function for updating the sprite's animation.
	 * Useful for cases when you need to update this but are buried down in too many supers.
	 * This function is called automatically by <code>FlxSprite.postUpdate()</code>.
	 */
	private function updateAnimation():Void
	{
		if (_bakedRotation > 0)
		{
			var oldIndex:Int = _curIndex;
			var angleHelper:Int = Math.floor(angle % 360);
			
			#if flash
			if (angleHelper < 0)
			{
				angleHelper += 360;
			}
			#else 
			while (angleHelper < 0)
			{
				angleHelper += 360;
			}
			#end
			
			_curIndex = Math.floor(angleHelper / _bakedRotation + 0.5);
			
			#if (cpp || neko)
			if (_framesData != null)
			{
				_frameID = _framesData.frameIDs[_curIndex];
			}
			#end		
			if (oldIndex != Math.floor(_curIndex))
			{
				dirty = true;
			}
		}
		else if ((_curAnim != null) && (_curAnim.delay > 0) && (_curAnim.looped || !finished))
		{
			_frameTimer += FlxG.elapsed;
			while (_frameTimer > _curAnim.delay)
			{
				_frameTimer = _frameTimer - _curAnim.delay;
				if (Math.floor(_curFrame) == _curAnim.frames.length - 1)
				{
					if (_curAnim.looped)
					{
						_curFrame = 0;
					}
					finished = true;
				}
				else
				{
					_curFrame++;
				}
				_curIndex = _curAnim.frames[_curFrame];
				#if (cpp || neko)
				if (_framesData != null)
				{
					_frameID = _framesData.frameIDs[_curIndex];
				}
				#end
				dirty = true;
			}
		}
		
		if (dirty)
		{
			calcFrame();
		}
	}
	
	/**
	 * Request (or force) that the sprite update the frame before rendering.
	 * Useful if you are doing procedural generation or other weirdness!
	 * @param	Force	Force the frame to redraw, even if its not flagged as necessary.
	 */
	public function drawFrame(?Force:Bool = false):Void
	{
		#if flash
		if (Force || dirty)
		{
			calcFrame();
		}
		#else
		calcFrame(true);
		#end
	}
	
	/**
	 * Adds a new animation to the sprite.
	 * @param	Name		What this animation should be called (e.g. "run").
	 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
	 * @param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40 fps).
	 * @param	Looped		Whether or not the animation is looped or just plays once.
	 */
	public function addAnimation(Name:String, Frames:Array<Int>, ?FrameRate:Int = 0, ?Looped:Bool = true):Void
	{
		_animations.push(new FlxAnim(Name, Frames, FlxU.fromIntToUInt(FrameRate), Looped));
	}
	
	/**
	 * Pass in a function to be called whenever this sprite's animation changes.
	 * @param	AnimationCallback		A function that has 3 parameters: a string name, a uint frame number, and a uint frame index.
	 */
	#if flash
	public function addAnimationCallback(AnimationCallback:String->UInt->UInt->Void):Void
	#else
	public function addAnimationCallback(AnimationCallback:String->Int->Int->Void):Void
	#end
	{
		_callback = AnimationCallback;
	}
	
	/**
	 * Plays an existing animation (e.g. "run").
	 * If you call an animation that is already playing it will be ignored.
	 * @param	AnimName	The string name of the animation you want to play.
	 * @param	Force		Whether to force the animation to restart.
	 */
	public function play(AnimName:String, ?Force:Bool = false):Void
	{
		if (!Force && (_curAnim != null) && (AnimName == _curAnim.name) && (!_curAnim.looped || !finished)) return;
		_curFrame = 0;
		_curIndex = 0;
		#if (cpp || neko)
		if (_framesData != null)
		{
			_frameID = _framesData.frameIDs[_curIndex];
		}
		#end
		_frameTimer = 0;
		var i:Int = 0;
		var l:Int = _animations.length;
		while(i < l)
		{
			if(_animations[i].name == AnimName)
			{
				_curAnim = _animations[i];
				if (_curAnim.delay <= 0)
				{
					finished = true;
				}
				else
				{
					finished = false;
				}
				_curIndex = _curAnim.frames[_curFrame];
				#if (cpp || neko)
				if (_framesData != null)
				{
					_frameID = _framesData.frameIDs[_curIndex];
				}
				#end
				dirty = true;
				return;
			}
			i++;
		}
		FlxG.log("WARNING: No animation called \""+AnimName+"\"");
	}
	
	/**
	 * Tell the sprite to change to a random frame of animation
	 * Useful for instantiating particles or other weird things.
	 */
	public function randomFrame():Void
	{
		_curAnim = null;
		_curIndex = Math.floor(FlxG.random() * (_pixels.width / frameWidth));
		#if (cpp || neko)
		if (_framesData != null)
		{
			_frameID = _framesData.frameIDs[_curIndex];
		}
		#end
		dirty = true;
	}
	
	/**
	 * Helper function that just sets origin to (0,0)
	 */
	public function setOriginToCorner():Void
	{
		origin.x = origin.y = 0;
	}
	
	/**
	 * Helper function that adjusts the offset automatically to center the bounding box within the graphic.
	 * @param	AdjustPosition		Adjusts the actual X and Y position just once to match the offset change. Default is false.
	 */
	public function centerOffsets(?AdjustPosition:Bool = false):Void
	{
		offset.x = (frameWidth - width) * 0.5;
		offset.y = (frameHeight - height) * 0.5;
		if (AdjustPosition)
		{
			x += offset.x;
			y += offset.y;
		}
	}
	
	#if flash
	public function replaceColor(Color:UInt, NewColor:UInt, ?FetchPositions:Bool = false):Array<FlxPoint>
	#else
	public function replaceColor(Color:BitmapInt32, NewColor:BitmapInt32, ?FetchPositions:Bool = false):Array<FlxPoint>
	#end
	{
		var positions:Array<FlxPoint> = null;
		if (FetchPositions)
		{
			positions = new Array<FlxPoint>();
		}
		
		var row:Int = 0;
		var column:Int;
		var rows:Int = _pixels.height;
		var columns:Int = _pixels.width;
		while(row < rows)
		{
			column = 0;
			while(column < columns)
			{
				if(_pixels.getPixel32(column,row) == Color)
				{
					_pixels.setPixel32(column,row,NewColor);
					if (FetchPositions)
					{
						positions.push(new FlxPoint(column, row));
					}
					dirty = true;
				}
				column++;
			}
			row++;
		}
		
		updateTileSheet();
		
		return positions;
	}
	
	public var pixels(getPixels, setPixels):BitmapData;
	
	/**
	 * Set <code>pixels</code> to any <code>BitmapData</code> object.
	 * Automatically adjust graphic size and render helpers.
	 */
	public function getPixels():BitmapData
	{
		return _pixels;
	}
	
	/**
	 * @private
	 */
	public function setPixels(Pixels:BitmapData):BitmapData
	{
		_pixels = Pixels;
		width = frameWidth = _pixels.width;
		height = frameHeight = _pixels.height;
		resetHelpers();
		
		updateTileSheet();
		
		return _pixels;
	}
	
	/**
	 * Set <code>facing</code> using <code>FlxSprite.LEFT</code>,<code>RIGHT</code>,
	 * <code>UP</code>, and <code>DOWN</code> to take advantage of
	 * flipped sprites and/or just track player orientation more easily.
	 */
	public function getFacing():Int
	{
		return _facing;
	}
	
	/**
	 * @private
	 */
	public function setFacing(Direction:Int):Int
	{
		if (_facing != Direction)
		{
			dirty = true;
		}
		_facing = Direction;
		return _facing;
	}
	
	public var alpha(getAlpha, setAlpha):Float;
	
	/**
	 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of the sprite.
	 */
	public function getAlpha():Float
	{
		return _alpha;
	}
	
	/**
	 * @private
	 */
	public function setAlpha(Alpha:Float):Float
	{
		if (Alpha > 1)
		{
			Alpha = 1;
		}
		if (Alpha < 0)
		{
			Alpha = 0;
		}
		if (Alpha == _alpha)
		{
			return _alpha;
		}
		_alpha = Alpha;
		#if flash
		if ((_alpha != 1) || (_color != 0x00ffffff))
		{
			_colorTransform = new ColorTransform((_color >> 16) * 0.00392, (_color >> 8 & 0xff) * 0.00392, (_color & 0xff) * 0.00392, _alpha);
		}
		else
		{
			_colorTransform = null;
		}
		dirty = true;
		#end
		return _alpha;
	}
	
	/**
	 * Set <code>color</code> to a number in this format: 0xRRGGBB.
	 * <code>color</code> IGNORES ALPHA.  To change the opacity use <code>alpha</code>.
	 * Tints the whole sprite to be this color (similar to OpenGL vertex colors).
	 */
	#if flash
	public function getColor():UInt
	#else
	public function getColor():BitmapInt32
	#end
	{
		return _color;
	}
	
	/**
	 * @private
	 */
	#if flash
	public function setColor(Color:UInt):UInt
	#else
	public function setColor(Color:BitmapInt32):BitmapInt32
	#end
	{
		#if neko
		if (_color.rgb == Color.rgb)
		{
			return _color;
		}
		_color = Color;
		if ((_alpha != 1) || (_color.rgb != 0xffffff))
		{
			_colorTransform = new ColorTransform((_color.rgb >> 16) * 0.00392, (_color.rgb >> 8 & 0xff) * 0.00392, (_color.rgb & 0xff) * 0.00392, _alpha);
		}
		else
		{
			_colorTransform = null;
		}
		#else
		Color &= 0x00ffffff;
		if (_color == Color)
		{
			return _color;
		}
		_color = Color;
		if ((_alpha != 1) || (_color != 0x00ffffff))
		{
			_colorTransform = new ColorTransform((_color >> 16) * 0.00392, (_color >> 8 & 0xff) * 0.00392, (_color & 0xff) * 0.00392, _alpha);
		}
		else
		{
			_colorTransform = null;
		}
		#end
		
		dirty = true;
		
		#if cpp
		_red = (_color >> 16) * 0.00392;
		_green = (_color >> 8 & 0xff) * 0.00392;
		_blue = (_color & 0xff) * 0.00392;
		#elseif neko
		_red = (_color.rgb >> 16) * 0.00392;
		_green = (_color.rgb >> 8 & 0xff) * 0.00392;
		_blue = (_color.rgb & 0xff) * 0.00392;
		#end
		
		#if (cpp || neko)
		
		#if cpp
		if (_color != 0x00ffffff)
		#else
		if (_color.rgb != 0xffffff)
		#end
		{
			if (_tileSheetData != null)
			{
				_tileSheetData.isColored = true;
			}
		}
		#end
		
		return _color;
	}
	
	/**
	 * Tell the sprite to change to a specific frame of animation.
	 * 
	 * @param	Frame	The frame you want to display.
	 */
	#if flash
	public function getFrame():UInt
	#else
	public function getFrame():Int
	#end
	{
		return _curIndex;
	}
	
	/**
	 * @private
	 */
	#if flash
	public function setFrame(Frame:UInt):UInt
	#else
	public function setFrame(Frame:Int):Int
	#end
	{
		_curAnim = null;
		_curIndex = Frame % frames;
		#if (cpp || neko)
		if (_framesData != null)
		{
			_frameID = _framesData.frameIDs[_curIndex];
		}
		#end
		dirty = true;
		return Frame;
	}
	
	/**
	 * Check and see if this object is currently on screen.
	 * Differs from <code>FlxObject</code>'s implementation
	 * in that it takes the actual graphic into account,
	 * not just the hitbox or bounding box or whatever.
	 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether the object is on screen or not.
	 */
	override public function onScreen(?Camera:FlxCamera = null):Bool
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		getScreenXY(_point, Camera);
		_point.x = _point.x - offset.x;
		_point.y = _point.y - offset.y;

		if (((angle == 0) || (_bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1))
		{
			return ((_point.x + frameWidth > 0) && (_point.x < Camera.width) && (_point.y + frameHeight > 0) && (_point.y < Camera.height));
		}
		
		var halfWidth:Float = 0.5 * frameWidth;
		var halfHeight:Float = 0.5 * frameHeight;
		var absScaleX:Float = (scale.x > 0)?scale.x: -scale.x;
		var absScaleY:Float = (scale.y > 0)?scale.y: -scale.y;
		#if flash
		var radius:Float = Math.sqrt(halfWidth * halfWidth + halfHeight * halfHeight) * ((absScaleX >= absScaleY)?absScaleX:absScaleY);
		#else
		var radius:Float = ((frameWidth >= frameHeight) ? frameWidth : frameHeight) * ((absScaleX >= absScaleY)?absScaleX:absScaleY);
		#end
		_point.x += halfWidth;
		_point.y += halfHeight;
		return ((_point.x + radius > 0) && (_point.x - radius < Camera.width) && (_point.y + radius > 0) && (_point.y - radius < Camera.height));
	}
	
	/**
	 * Checks to see if a point in 2D world space overlaps this <code>FlxSprite</code> object's current displayed pixels.
	 * This check is ALWAYS made in screen space, and always takes scroll factors into account.
	 * @param	Point		The point in world space you want to check.
	 * @param	Mask		Used in the pixel hit test to determine what counts as solid.
	 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether or not the point overlaps this object.
	 */
	#if flash
	public function pixelsOverlapPoint(point:FlxPoint, ?Mask:UInt = 0xFF, ?Camera:FlxCamera = null):Bool
	#else
	public function pixelsOverlapPoint(point:FlxPoint, ?Mask:Int = 0xFF, ?Camera:FlxCamera = null):Bool
	#end
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		getScreenXY(_point, Camera);
		_point.x = _point.x - offset.x;
		_point.y = _point.y - offset.y;
		_flashPoint.x = (point.x - Camera.scroll.x) - _point.x;
		_flashPoint.y = (point.y - Camera.scroll.y) - _point.y;
		#if flash
		return framePixels.hitTest(_flashPointZero, Mask, _flashPoint);
		#else
		// 1. Check to see if the point is outside of framePixels rectangle
		if (_flashPoint.x < 0 || _flashPoint.x > frameWidth || _flashPoint.y < 0 || _flashPoint.y > frameHeight)
		{
			return false;
		}
		else // 2. Check pixel at (_flashPoint.x, _flashPoint.y)
		{
			// this code is from calcFrame() method
			var indexX:Int = _curIndex * frameWidth;
			var indexY:Int = 0;

			//Handle sprite sheets
			var widthHelper:Int = (_flipped != 0) ? _flipped : _pixels.width;
			if(indexX >= widthHelper)
			{
				indexY = Math.floor(indexX / widthHelper) * frameHeight;
				indexX %= widthHelper;
			}
			
			#if cpp
			var pixelColor:BitmapInt32 = 0x00000000;
			#else
			var pixelColor:BitmapInt32 = {rgb: 0x000000, a: 0x00};
			#end
			// handle reversed sprites
			if ((_flipped != 0) && (_facing == FlxObject.LEFT))
			{
				pixelColor = _pixels.getPixel32(Math.floor(indexX + frameWidth - _flashPoint.x), Math.floor(indexY + _flashPoint.y));
			}
			else
			{
				pixelColor = _pixels.getPixel32(Math.floor(indexX + _flashPoint.x), Math.floor(indexY + _flashPoint.y));
			}
			// end of code from calcFrame() method
			#if cpp
			var pixelAlpha:Int = (pixelColor >> 24) & 0xFF;
			#else
			var pixelAlpha:Int = pixelColor.a * 255;
			#end
			return (pixelAlpha >= Mask);
		}
		#end
	}
	
	/**
	 * Internal function to update the current animation frame.
	 */
	#if flash
	private function calcFrame():Void
	#else
	private function calcFrame(?AreYouSure:Bool = false):Void
	#end
	{
	#if (cpp || neko)
		if (AreYouSure)
		{
			if ((framePixels == null) || (framePixels.width != width) || (framePixels.height != height))
			{
				framePixels = new BitmapData(Math.floor(width), Math.floor(height));
			}
	#end
		
			var indexX:Int = _curIndex * frameWidth;
			var indexY:Int = 0;

			//Handle sprite sheets
			var widthHelper:Int = (_flipped != 0) ? _flipped : _pixels.width;
			if(indexX >= widthHelper)
			{
				indexY = Math.floor(indexX / widthHelper) * frameHeight;
				indexX %= widthHelper;
			}
			
			//handle reversed sprites
			if ((_flipped != 0) && (_facing == FlxObject.LEFT))
			{
				indexX = (_flipped << 1) - indexX - frameWidth;
			}
			
			//Update display bitmap
			_flashRect.x = indexX;
			_flashRect.y = indexY;
			framePixels.copyPixels(_pixels, _flashRect, _flashPointZero);
			_flashRect.x = _flashRect.y = 0;
			
			if (_colorTransform != null) 
			{
				framePixels.colorTransform(_flashRect, _colorTransform);
			}
	#if (cpp || neko)	
		}
	#end
		
		if (_callback != null)
		{
			Reflect.callMethod(this, Reflect.field(this, "_callback"), [((_curAnim != null) ? (_curAnim.name) : null), _curFrame, _curIndex]);
		}
		dirty = false;
	}
	
	#if (cpp || neko)
	public var antialiasing(getAntialiasing, setAntialiasing):Bool;
	
	public function getAntialiasing():Bool
	{
		return _antialiasing;
	}
	
	public function setAntialiasing(val:Bool):Bool
	{
		_antialiasing = val;
		if (_tileSheetData != null)
		{
			_tileSheetData.antialiasing = val;
		}
		return val;
	}
	
	/**
	 * Gets FlxSprite's TileSheetData index in TileSheetManager
	 */
	public function getTileSheetIndex():Int
	{
		if (_tileSheetData != null)
		{
			return TileSheetManager.getTileSheetIndex(_tileSheetData);
		}
		
		return -1;
	}
	#end
	
	/**
	 * If the Sprite is flipped.
	 */
	public var flipped(getFlipped, null):Int;
	
	public function getFlipped():Int
	{
		return _flipped;
	}
	
	/**
	 * If the Sprite has baked rotation.
	 */
	public var bakedRotation(get_bakedRotation, null):Float;
	
	private function get_bakedRotation():Float 
	{
		return _bakedRotation;
	}
	
	/**
	 * If the Sprite is beeing rendered in simple mode.
	 */
	public var simpleRender(getSimpleRender, null):Bool;
	
	public function getSimpleRender():Bool
	{ 
		return (((angle == 0) || (_bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1) && (blend == null));
	}
	
	/**
	 * Use this method for creating tileSheet for FlxSprite. Must be called after makeGraphic(), loadGraphic or loadRotatedGraphic().
	 * If you forget to call it then you will not see this FlxSprite on c++ target
	 */
	public function updateTileSheet():Void
	{
	#if (cpp || neko)
		if (_pixels != null && frameWidth >= 1 && frameHeight >= 1)
		{
			_tileSheetData = TileSheetManager.addTileSheet(_pixels);
			_tileSheetData.antialiasing = _antialiasing;
			if (frames > 1)
			{
				_framesData = _tileSheetData.addSpriteFramesData(Math.floor(frameWidth), Math.floor(frameHeight), null, 0, 0, 0, 0, 1, 1);
			}
			else
			{
				_framesData = _tileSheetData.addSpriteFramesData(Math.floor(frameWidth), Math.floor(frameHeight));
			}
		}
	#end
	}
	
}