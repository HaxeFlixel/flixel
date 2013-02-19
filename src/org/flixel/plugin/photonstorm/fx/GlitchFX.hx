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
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.plugin.photonstorm.FlxColor;

import org.flixel.system.layer.TileSheetData;

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
	public function createFromFlxSprite(source:FlxSprite, maxGlitch:Int, maxSkip:Int, autoUpdate:Bool = false, ?backgroundColor:UInt = 0x0):FlxSprite
	#else
	public function createFromFlxSprite(source:FlxSprite, maxGlitch:Int, maxSkip:Int, autoUpdate:Bool = false, ?backgroundColor:BitmapInt32):FlxSprite
	#end
	{
		#if !flash
		if (backgroundColor == null)
		{
			backgroundColor = FlxG.TRANSPARENT;
		}
		#end
		
		#if flash
		sprite = new FlxSprite(source.x, source.y).makeGraphic(Std.int(source.width + maxGlitch), Std.int(source.height), backgroundColor);
		canvas = new BitmapData(Std.int(sprite.width), Std.int(sprite.height), true, backgroundColor);
		image = source.pixels;
		#else
		sprite = new GlitchSprite(source, maxGlitch, maxSkip, backgroundColor);
		#end
		
		sourceRef = source;
		
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
		
		#if !flash
		if (sprite != null && sourceRef != null)
		{
			var glitch:GlitchSprite = cast(sprite, GlitchSprite);
			glitch.frameWidth = Std.int(sourceRef.frameWidth + maxGlitch);
			glitch.maxGlitch = maxGlitch;
			glitch.glitchSkip = maxSkip;
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
			
			var y:Int = 0;
			
			while (y < sprite.height)
			{
				copyPoint.x = Std.int(Math.random() * glitchSize);
				canvas.copyPixels(image, copyRect, copyPoint);
				
				copyRect.y += rndSkip;
				copyPoint.y += rndSkip;
				y += rndSkip;
			}
			
			canvas.unlock();
			sprite.pixels = canvas;
			sprite.dirty = true;
			#else
			cast(sprite, GlitchSprite).updateLinePositions();
			#end
			
			lastUpdate = 0;
		}
	}
	
}

#if !flash
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
	public var glitchSkip:Float;
	
	public var sourceFrame:Int;
	
	public function new(Source:FlxSprite, MaxGlitch:Int, GlitchSkip:Int, BgColor:BitmapInt32)
	{
		super();
		
		_sourceSprite = Source;
		sourceFrame = -1;
		
		this.maxGlitch = MaxGlitch;
		this.glitchSkip = GlitchSkip;
		
		_imageTileIDs = new IntHash<Array<Int>>();
		imageLines = new Array<ImageLine>();
		
		makeGraphic(1, 1, FlxG.WHITE);
		
		_frameID = _framesData.frameIDs[0];
		_tileSheetData.isColored = true;
		
		var rgba:RGBA = FlxColor.getRGB(BgColor);
		_bgRed = rgba.red / 255;
		_bgGreen = rgba.green / 255;
		_bgBlue = rgba.blue / 255;
		_bgAlpha = rgba.alpha / 255;
		
		this.x = _sourceSprite.x;
		this.y = _sourceSprite.y;
	}
	
	public function updateFromSourceSprite():Void
	{
		if (_sourceSprite.pixels != _imageTileSheetData.tileSheet.nmeBitmap)
		{
			updateTileSheet();
		}
		else
		{
			updateLineIDs();
		}
	}
	
	private function updateLineIDs():Void
	{
		if (sourceFrame != _sourceSprite.frame)
		{
			var sourceFrameHeight:Int = _sourceSprite.frameHeight;
			var halfFrameWidth:Float = _sourceSprite.frameWidth * 0.5;
			
			sourceFrame = _sourceSprite.frame;
			var frameLines:Array<Int> = _imageTileIDs.get(sourceFrame);
			var halfFrameHeight:Float = sourceFrameHeight * 0.5;
			
			var imageLine:ImageLine;
			
			for (i in 0...(sourceFrameHeight))
			{
				imageLine = imageLines[i];
				if (imageLine == null)
				{
					imageLines[i] = { x: 0, y: i + 0.5, tileID: frameLines[i] };
				}
				else
				{
					imageLine.x = halfFrameWidth;
					imageLine.y = i - sourceFrameHeight + 0.5;
					imageLine.tileID = frameLines[i];
				}
			}
			
			if (imageLines.length > _sourceSprite.frameHeight)
			{
				imageLines.splice(_sourceSprite.frameHeight, (imageLines.length - _sourceSprite.frameHeight));
			}
		}
	}
	
	public function updateLinePositions():Void
	{
		var sourceFrameHeight:Int = _sourceSprite.frameHeight;
		
		var rndSkip:Int = 1 + Std.int(Math.random() * glitchSkip);
		var y:Int = 0;
		var rndX:Float = 0;
		
		for (i in 0...(sourceFrameHeight))
		{
			if (i == y)
			{
				rndX = Std.int(Math.random() * maxGlitch);
				y += rndSkip;
			}
			
			imageLines[i].x = rndX;
		}
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		imageLines = null;
		_sourceSprite = null;
		_imageTileSheetData = null;
		_imageTileIDs = null;
	}
	
	override public function setColor(Color:BitmapInt32):BitmapInt32 
	{
		var col = super.setColor(Color);
		
		#if !neko
		if (_color < 0xffffff)
		#else
		if (_color.rgb < 0xffffff)
		#end
		{
			if (_imageTileSheetData != null)
			{
				_imageTileSheetData.isColored = true;
			}
		}
		
		return col;
	}
	
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
		
		var halfWidth:Float = frameWidth * 0.5;
		var halfHeight:Float = frameHeight * 0.5;
		
		var lineDef:ImageLine;
		
		var lineRed:Float = 1;
		var lineGreen:Float = 1;
		var lineBlue:Float = 1;
		
		#if !neko
		if (_color < 0xffffff)
		#else
		if (_color.rgb < 0xffffff)
		#end
		{
			lineRed = _red;
			lineGreen = _green;
			lineBlue = _blue;
		}
		
		var onCamRed:Float;
		var onCamGreen:Float;
		var onCamBlue:Float;
		
		while (i < l)
		{
			camera = cameras[i++];
			
			if (!onScreenSprite(camera) || !camera.visible || !camera.exists)
			{
				continue;
			}
			
			var onCamRed:Float = lineRed;
			var onCamGreen:Float = lineGreen;
			var onCamBlue:Float = lineBlue;
			
			if (camera.isColored())
			{
				onCamRed = camera.red;
				onCamGreen = camera.green;
				onCamBlue = camera.blue;
			}
			
			var useColor:Bool = (_imageTileSheetData.isColored || camera.isColored());
			
			currDrawData = _tileSheetData.drawData[camera.ID];
			currIndex = _tileSheetData.positionData[camera.ID];
			
			_point.x = (x - (camera.scroll.x * scrollFactor.x) - (offset.x)) + origin.x;
			_point.y = (y - (camera.scroll.y * scrollFactor.y) - (offset.y)) + origin.y;
			
			if (simpleRenderSprite())
			{	//Simple render
				
				// draw background
				if (_bgAlpha > 0)
				{
					currDrawData[currIndex++] = _point.x + halfWidth;
					currDrawData[currIndex++] = _point.y + halfHeight;
					
					currDrawData[currIndex++] = _frameID;
					
					currDrawData[currIndex++] = frameWidth;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = frameHeight;
					
					if (camera.isColored())
					{
						currDrawData[currIndex++] = _bgRed * camera.red; 
						currDrawData[currIndex++] = _bgGreen * camera.green;
						currDrawData[currIndex++] = _bgBlue * camera.blue;
					}
					else
					{
						currDrawData[currIndex++] = _bgRed; 
						currDrawData[currIndex++] = _bgGreen;
						currDrawData[currIndex++] = _bgBlue;
						
					}
					
					currDrawData[currIndex++] = _bgAlpha * alpha;
					_tileSheetData.positionData[camera.ID] = currIndex;
				}
				
				// draw lines
				currDrawData = _imageTileSheetData.drawData[camera.ID];
				currIndex = _imageTileSheetData.positionData[camera.ID];
				
				for (j in 0...(imageLines.length))
				{
					lineDef = imageLines[j];
					
					currDrawData[currIndex++] = _point.x + lineDef.x;
					currDrawData[currIndex++] = _point.y + lineDef.y;
					
					currDrawData[currIndex++] = lineDef.tileID;
					
					currDrawData[currIndex++] = 1;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 0;
					currDrawData[currIndex++] = 1;
					
					if (useColor)
					{
						currDrawData[currIndex++] = onCamRed; 
						currDrawData[currIndex++] = onCamGreen;
						currDrawData[currIndex++] = onCamBlue;
					}
					
					currDrawData[currIndex++] = alpha;
				}
				
				_imageTileSheetData.positionData[camera.ID] = currIndex;
			}
			else
			{	//Advanced render
				radians = angle * FlxG.RAD;
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
					
					currDrawData[currIndex++] = cos * scale.x * frameWidth;
					currDrawData[currIndex++] = -sin * scale.y * frameHeight;
					currDrawData[currIndex++] = sin * scale.x * frameWidth;
					currDrawData[currIndex++] = cos * scale.y * frameHeight;
					
					if (camera.isColored())
					{
						currDrawData[currIndex++] = _bgRed * camera.red; 
						currDrawData[currIndex++] = _bgGreen * camera.green;
						currDrawData[currIndex++] = _bgBlue * camera.blue;
					}
					else
					{
						currDrawData[currIndex++] = _bgRed; 
						currDrawData[currIndex++] = _bgGreen;
						currDrawData[currIndex++] = _bgBlue;
					}
					
					currDrawData[currIndex++] = _bgAlpha * alpha;
					_tileSheetData.positionData[camera.ID] = currIndex;
				}
				
				// draw lines
				currDrawData = _imageTileSheetData.drawData[camera.ID];
				currIndex = _imageTileSheetData.positionData[camera.ID];
				
				for (j in 0...(imageLines.length))
				{
					lineDef = imageLines[j];
					
					var localX:Float = lineDef.x - halfWidth;
					var localY:Float = lineDef.y - halfHeight;
					
					var relativeX:Float = (localX * cos * scale.x - localY * sin * scale.y);
					var relativeY:Float = (localX * sin * scale.x + localY * cos * scale.y);
					
					currDrawData[currIndex++] = _point.x + relativeX;
					currDrawData[currIndex++] = _point.y + relativeY;
					
					currDrawData[currIndex++] = lineDef.tileID;
					
					currDrawData[currIndex++] = cos * scale.x;
					currDrawData[currIndex++] = -sin * scale.y;
					currDrawData[currIndex++] = sin * scale.x;
					currDrawData[currIndex++] = cos * scale.y;
					
					if (useColor)
					{
						currDrawData[currIndex++] = onCamRed; 
						currDrawData[currIndex++] = onCamGreen;
						currDrawData[currIndex++] = onCamBlue;
					}
					
					currDrawData[currIndex++] = alpha;
				}
				
				_imageTileSheetData.positionData[camera.ID] = currIndex;
			}
			
			FlxBasic._VISIBLECOUNT++;
			
			#if !FLX_NO_DEBUG
			if (FlxG.visualDebug && !ignoreDrawDebug)
			{
				drawDebug(camera);
			}
			#end
		} 
	}
	
	public function swapTileSheets():Void
	{
		/*if (_tileSheetData != null && _imageTileSheetData != null)
		{
			var bgIndex:Int = TileSheetManager.getTileSheetIndex(_tileSheetData);
			var imgIndex:Int = TileSheetManager.getTileSheetIndex(_imageTileSheetData);
			
			if (bgIndex > imgIndex)
			{
				TileSheetManager.swapTileSheets(bgIndex, imgIndex);
			}
		}*/
	}
	
	public function updateTileSheet():Void 
	{
		/*
		if (_tileSheetData == null)
		{
			if (_pixels != null)
			{
				_tileSheetData = TileSheetManager.addTileSheet(_pixels);
				_tileSheetData.antialiasing = antialiasing;
				_tileSheetData.isTilemap = false;
				_framesData = _tileSheetData.addSpriteFramesData(1, 1);
			}
		}
		
		if (_sourceSprite != null)
		{
			this.width = _sourceSprite.width + maxGlitch;
			this.height = _sourceSprite.height;
			
			this.frameWidth = Std.int(this.width);
			this.frameHeight = Std.int(this.height);
			
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
				if (((frameX + sourceFrameWidth) >= sourcePixelsWidth) && (i != 0))
				{
					frameX = 0;
					frameY += sourceFrameHeight;
				}
				
				if (((frameY + sourceFrameHeight) <= sourcePixelsHeight))
				{
					frameLines = [];
					
					for (j in 0...(sourceFrameHeight))
					{
						sourceRect = new Rectangle(frameX, frameY + j, sourceFrameWidth, 1);
						tileID = _imageTileSheetData.addTileRect(sourceRect);
						frameLines.push(tileID);
					}
					
					_imageTileIDs.set(i, frameLines);
				}
			}
			
			updateLineIDs();
		}
		
		swapTileSheets();
		*/
	}
	
}

typedef ImageLine = {
	var x:Float;
	var y:Float;
	var tileID:Int;
}
#end