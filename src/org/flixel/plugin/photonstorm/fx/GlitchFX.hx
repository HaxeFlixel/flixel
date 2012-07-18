/**
 * GlitchFX - Special FX Plugin
 * -- Part of the Flixel Power Tools set
 * 
 * v1.2 Fixed updateFromSource github issue #8 (thanks CoderBrandon)
 * v1.1 Added changeGlitchValues support
 * v1.0 First release
 * 
 * @version 1.2 - August 8th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm.fx;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import nme.display.BitmapInt32;
import org.flixel.FlxSprite;
import org.flixel.plugin.photonstorm.FlxColor;
import org.flixel.tileSheetManager.TileSheetData;
import org.flixel.tileSheetManager.TileSheetManager;

/**
 * Creates a static / glitch / monitor-corruption style effect on an FlxSprite
 * 
 * TODO:
 * 
 * Add reduction from really high glitch value down to zero, will smooth the image into place and look cool :)
 * Add option to glitch vertically?
 * 
 */
class GlitchFX extends BaseFX
{
	private var glitchSize:Int;
	private var glitchSkip:Int;
	
	public function new() 
	{
		super();
	}
	
	#if flash
	public function createFromFlxSprite(source:FlxSprite, maxGlitch:Int, maxSkip:Int, ?autoUpdate:Bool = false, ?backgroundColor:UInt = 0x0):FlxSprite
	#else
	public function createFromFlxSprite(source:FlxSprite, maxGlitch:Int, maxSkip:Int, ?autoUpdate:Bool = false, ?backgroundColor:BitmapInt32 = null):FlxSprite
	#end
	{
		#if (cpp || neko)
		if (backgroundColor == null)
		{
			#if neko
			backgroundColor = { rgb: 0x000000, a: 0x00 };
			#else
			backgroundColor = 0x00000000;
			#end
		}
		#end
		
		#if flash
		sprite = new FlxSprite(source.x, source.y).makeGraphic(Math.floor(source.width + maxGlitch), Math.floor(source.height), backgroundColor);
		canvas = new BitmapData(Math.floor(sprite.width), Math.floor(sprite.height), true, backgroundColor);
		image = source.pixels;
		#else
		sprite = new GlitchSprite(source, maxGlitch, backgroundColor);
		#end
		
		updateFromSource = autoUpdate;
		
		glitchSize = maxGlitch;
		glitchSkip = maxSkip;
		
		clsColor = backgroundColor;
		
		copyPoint = new Point(0, 0);
		
		#if flash
		clsRect = new Rectangle(0, 0, canvas.width, canvas.height);
		copyRect = new Rectangle(0, 0, image.width, 1);
		#end
		
		active = true;
		return sprite;
	}
	
	public function changeGlitchValues(maxGlitch:Int, maxSkip:Int):Void
	{
		glitchSize = maxGlitch;
		glitchSkip = maxSkip;
		
		#if (cpp || neko)
		if (sprite != null)
		{
			sprite.frameWidth = Math.floor(sourceRef.frameWidth + maxGlitch);
			cast(sprite, GlitchSprite).maxGlitch = maxGlitch;
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
			#end
			
			var y:Int = 0;
			
			#if flash
			while (y < sprite.height)
			{
				copyPoint.x = Std.int(Math.random() * glitchSize);
				canvas.copyPixels(image, copyRect, copyPoint);
				
				copyRect.y += rndSkip;
				copyPoint.y += rndSkip;
				y += rndSkip;
			}
			
			canvas.unlock();
			
			lastUpdate = 0;
			
			sprite.pixels = canvas;
			sprite.dirty = true;
			#else
			cast(sprite, GlitchSprite).updateLinePositions();
			#end
		}
	}
	
}

#if (cpp || neko)
class GlitchSprite extends FlxSprite
{
	/**
	 * Information about each line in glitched sprite
	 */
	public var imageLines:Array<ImageLine>;
	
	private var _sourceSprite:FlxSprite;
	
	/**
	 * link to source image tilesheet data
	 */
	private var _imageTileSheetData:TileSheetData;
	
	/**
	 * storage for each frame's lines tile IDs
	 */
	private var _imageTileIDs:IntHash<Array<Int>>;
	
	private var _bgRed:Float;
	private var _bgGreen:Float;
	private var _bgBlue:Float;
	private var _bgAlpha:Float;
	
	public var maxGlitch:Float;
	
	public function new(Source:FlxSprite, MaxGlitch:Int, BgColor:BitmapInt32)
	{
		super();
		
		_sourceSprite = Source;
		
		_imageTileIDs = new IntHash<Array<Int>>();
		imageLines = new Array<ImageLine>();
		
		#if !neko
		makeGraphic(1, 1, 0xffffffff);
		#else
		makeGraphic(1, 1, {rgb: 0xffffff, a: 0xff});
		#end
		
		_frameID = _framesData.frameIDs[0];
		
		var rgba:RGBA = FlxColor.getRGB(BgColor);
		_bgRed = rgba.red / 255;
		_bgGreen = rgba.green / 255;
		_bgBlue = rgba.blue / 255;
		_bgAlpha = rgba.alpha / 255;
		
		this.x = _sourceSprite.x;
		this.y = _sourceSprite.y;
		
		this.width = _sourceSprite.width + MaxGlitch;
		this.height = _sourceSprite.height;
		
		this.frameWidth = Math.floor(this.width);
		this.frameHeight = Math.floor(this.height);
		
		this.maxGlitch = MaxGlitch;
	}
	
	// TODO: update imageLines content from _sourceSprite
	public function updateFromSourceSprite():Void
	{
		
	}
	
	// TODO: update imageLines positions
	public function updateLinePositions():Void
	{
		/*while (y < sprite.height)
		{
			copyPoint.x = Std.int(Math.random() * glitchSize);
			canvas.copyPixels(image, copyRect, copyPoint);
			
			copyRect.y += rndSkip;
			copyPoint.y += rndSkip;
			y += rndSkip;
		}*/
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		imageLines = null;
		_sourceSprite = null;
		_imageTileSheetData = null;
		_imageTileIDs = null;
	}
	
	// TODO: implement sprite drawing
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
		
		if (cameras == null)
		{
			cameras = FlxG.cameras;
		}
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		var currDrawData:Array<Float>;
		var currIndex:Int;
		
		var radians:Float;
		var cos:Float;
		var sin:Float;
		
		while (i < l)
		{
			camera = cameras[i++];
			
			if (!onScreen(camera))
			{
				continue;
			}
			
			currDrawData = _tileSheetData.drawData[camera.ID];
			currIndex = _tileSheetData.positionData[camera.ID];
			/*
			_point.x = Math.floor(x - Math.floor(camera.scroll.x * scrollFactor.x) - Math.floor(offset.x)) + origin.x;
			_point.y = Math.floor(y - Math.floor(camera.scroll.y * scrollFactor.y) - Math.floor(offset.y)) + origin.y;
			
			if (simpleRender)
			{	//Simple render
				
				// draw background
				if (_bgAlpha > 0)
				{
					currDrawData[currIndex++] = _point.x + halfWidth;
					currDrawData[currIndex++] = _point.y + halfHeight;
					
					currDrawData[currIndex++] = _frameID;
					
					currDrawData[currIndex++] = width;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = height;
					
					if (camera.isColored)
					{
						currDrawData[currIndex++] = bgRed * camera.red; 
						currDrawData[currIndex++] = bgGreen * camera.green;
						currDrawData[currIndex++] = bgBlue * camera.blue;
					}
					else
					{
						currDrawData[currIndex++] = bgRed; 
						currDrawData[currIndex++] = bgGreen;
						currDrawData[currIndex++] = bgBlue;
					}
					
					currDrawData[currIndex++] = bgAlpha * _alpha;
				}
				
				// draw stars
				for (j in 0...(starData.length))
				{
					starDef = starData[j];
					
					currDrawData[currIndex++] = _point.x + starDef.x + 0.5;
					currDrawData[currIndex++] = _point.y + starDef.y + 0.5;
					
					currDrawData[currIndex++] = _frameID;
					
					currDrawData[currIndex++] = 1;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 1;
					
					starRed = starDef.red;
					starGreen = starDef.green;
					starBlue = starDef.blue;
					
					if (camera.isColored)
					{
						starRed *= camera.red;
						starGreen *= camera.green;
						starBlue *= camera.blue;
					}
					
					#if cpp
					if (_color < 0xffffff)
					#else
					if (_color.rgb < 0xffffff)
					#end
					{
						starRed *= _red;
						starGreen *= _green;
						starBlue *= _blue;
					}
					
					currDrawData[currIndex++] = starRed; 
					currDrawData[currIndex++] = starGreen;
					currDrawData[currIndex++] = starBlue;
					
					currDrawData[currIndex++] = _alpha * starDef.alpha;
				}
				
				_tileSheetData.positionData[camera.ID] = currIndex;
			}
			else
			{	//Advanced render
				radians = angle * 0.017453293;
				cos = Math.cos(radians);
				sin = Math.sin(radians);
				
				_point.x += halfWidth;
				_point.y += halfHeight;
				
				// draw background
				if (_bgAlpha > 0)
				{
					currDrawData[currIndex++] = _point.x;
					currDrawData[currIndex++] = _point.y;
					
					currDrawData[currIndex++] = _frameID;
					
					currDrawData[currIndex++] = cos * scale.x * width;
					currDrawData[currIndex++] = -sin * scale.y * height;
					currDrawData[currIndex++] = sin * scale.x * width;
					currDrawData[currIndex++] = cos * scale.y * height;
					
					if (camera.isColored)
					{
						currDrawData[currIndex++] = bgRed * camera.red; 
						currDrawData[currIndex++] = bgGreen * camera.green;
						currDrawData[currIndex++] = bgBlue * camera.blue;
					}
					else
					{
						currDrawData[currIndex++] = bgRed; 
						currDrawData[currIndex++] = bgGreen;
						currDrawData[currIndex++] = bgBlue;
					}
					
					currDrawData[currIndex++] = bgAlpha * _alpha;
				}
				
				
				// draw stars
				for (j in 0...(starData.length))
				{
					starDef = starData[j];
					
					var localX:Float = starDef.x;
					var localY:Float = starDef.y;
					
					var relativeX:Float = (localX * cos * scale.x - localY * sin * scale.y);
					var relativeY:Float = (localX * sin * scale.x + localY * cos * scale.y);
					
					currDrawData[currIndex++] = _point.x + relativeX;
					currDrawData[currIndex++] = _point.y + relativeY;
					
					currDrawData[currIndex++] = _frameID;
					
					currDrawData[currIndex++] = cos * scale.x;
					currDrawData[currIndex++] = -sin * scale.y;
					currDrawData[currIndex++] = sin * scale.x;
					currDrawData[currIndex++] = cos * scale.y;
					
					starRed = starDef.red;
					starGreen = starDef.green;
					starBlue = starDef.blue;
					
					if (camera.isColored)
					{
						starRed *= camera.red;
						starGreen *= camera.green;
						starBlue *= camera.blue;
					}
					
					#if cpp
					if (_color < 0xffffff)
					#else
					if (_color.rgb < 0xffffff)
					#end
					{
						starRed *= _red;
						starGreen *= _green;
						starBlue *= _blue;
					}
					
					currDrawData[currIndex++] = starRed; 
					currDrawData[currIndex++] = starGreen;
					currDrawData[currIndex++] = starBlue;
					
					currDrawData[currIndex++] = _alpha * starDef.alpha;
				}
				
				_tileSheetData.positionData[camera.ID] = currIndex;
			}
			
			*/
			FlxBasic._VISIBLECOUNT++;
			if (FlxG.visualDebug && !ignoreDrawDebug)
			{
				drawDebug(camera);
			}
		} 
	}
	
	public function swapTileSheets():Void
	{
		if (_tileSheetData != null && _imageTileSheetData != null)
		{
			var bgIndex:Int = TileSheetManager.getTileSheetIndex(_tileSheetData);
			var imgIndex:Int = TileSheetManager.getTileSheetIndex(_imageTileSheetData);
			
			if (bgIndex > imgIndex)
			{
				TileSheetManager.swapTileSheets(bgIndex, imgIndex);
			}
		}
	}
	
	override public function updateTileSheet():Void 
	{
		if (_tileSheetData == null)
		{
			if (_pixels != null)
			{
				_tileSheetData = TileSheetManager.addTileSheet(_pixels);
				_tileSheetData.antialiasing = _antialiasing;
				_framesData = _tileSheetData.addSpriteFramesData(1, 1);
			}
		}
		
		if (_sourceSprite != null)
		{
			_imageTileSheetData = TileSheetManager.addTileSheet(_sourceSprite.pixels);
			
			var frameLines:Array<Int>;
			var frameX:Int = 0;
			var frameY:Int = 0;
			var sourceFrameWidth:Int = _sourceSprite.frameWidth;
			var sourceFrameHeight:Int = _sourceSprite.frameHeight;
			
			var sourcePixelsWidth:Int = _sourceSprite.pixels.width;
			var sourcePixelsHeight:Int = _sourceSprite.pixels.height;
			
			var sourceRect:Rectangle;
			var tileID:Int;
			
			for (i in 0...(_sourceSprite.frames))
			{
				frameX = (sourceFrameWidth + 1) * i;
				if (((frameX + sourceFrameWidth) >= sourcePixelsWidth) || (i == 0))
				{
					frameX = 0;
					frameY += sourceFrameHeight;
				}
				
				if (((frameY + sourceFrameHeight) <= sourcePixelsHeight) || (i == 0))
				{
					frameLines = [];
					
					for (j in 0...(sourceFrameHeight))
					{
						sourceRect = new Rectangle(frameX, frameY, sourceFrameWidth, 1);
						tileID = _imageTileSheetData.addTileRect(sourceRect);
						frameLines.push(tileID);
					}
					
					_imageTileIDs.set(i, frameLines);
				}
			}
			
			frameLines = _imageTileIDs.get(_sourceSprite.frame);
			var halfFrame:Float = sourceFrameWidth * 0.5;
			
			for (i in 0...(_sourceSprite.frameHeight))
			{
				imageLines[i] = { x: halfFrame, y: i, tileID: frameLines[i] };
			}
			
			if (imageLines.length > _sourceSprite.frameHeight)
			{
				imageLines.splice(_sourceSprite.frameHeight, (imageLines.length - _sourceSprite.frameHeight));
			}
			
		}
		
		swapTileSheets();
	}
	
}

typedef ImageLine = {
	var x:Float;
	var y:Float;
	var tileID:Int;
}
#end