package flixel.effects.fx;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.system.layer.TileSheetData;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;

// TODO: Add reduction from really high glitch value down to zero, will smooth the image into place and look cool :)
// TODO: Add option to glitch vertically?

/**
 * Creates a static / glitch / monitor-corruption style effect on an FlxSprite
 * 
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm 
 */
class GlitchFX extends BaseFX
{
	private var _glitchSize:Int;
	private var _glitchSkip:Int;
	
	public function new() 
	{
		super();
	}
	
	public function createFromFlxSprite(Source:FlxSprite, MaxGlitch:Int, MaxSkip:Int, AutoUpdate:Bool = false, BackgroundColor:Int = 0x0):FlxSprite
	{
		#if flash
		sprite = new FlxSprite(Source.x, Source.y).makeGraphic(Std.int(Source.width + MaxGlitch), Std.int(Source.height), BackgroundColor);
		canvas = new BitmapData(Std.int(sprite.width), Std.int(sprite.height), true, BackgroundColor);
		_image = Source.pixels;
		#else
		sprite = new GlitchSprite(Source, MaxGlitch, MaxSkip, BackgroundColor);
		#end
		
		_sourceRef = Source;
		
		_updateFromSource = AutoUpdate;
		
		_glitchSize = MaxGlitch;
		_glitchSkip = MaxSkip;
		
		_clsColor = BackgroundColor;
		
		_copyPoint = new Point(0, 0);
		
		#if flash
		_clsRect = new Rectangle(0, 0, canvas.width, canvas.height);
		_copyRect = new Rectangle(0, 0, _image.width, 1);
		#end
		
		active = true;
		
		return sprite;
	}
	
	public function changeGlitchValues(MaxGlitch:Int, MaxSkip:Int):Void
	{
		_glitchSize = MaxGlitch;
		_glitchSkip = MaxSkip;
		
		#if !flash
		if (sprite != null && _sourceRef != null)
		{
			var glitch:GlitchSprite = cast(sprite, GlitchSprite);
			glitch.frameWidth = Std.int(_sourceRef.frameWidth + MaxGlitch);
			glitch.maxGlitch = MaxGlitch;
			glitch.glitchSkip = MaxSkip;
		}
		#end
	}
	
	override public function draw():Void
	{
		if (_ready)
		{
			if (_lastUpdate != _updateLimit)
			{
				_lastUpdate++;
				return;
			}
			
			if (_updateFromSource && _sourceRef.exists)
			{
				#if flash
				_image = _sourceRef.framePixels;
				#else
				cast(sprite, GlitchSprite).updateFromSourceSprite();
				#end
			}
			
			var rndSkip:Int = 1 + Std.int(Math.random() * _glitchSkip);
			
			#if flash
			canvas.lock();
			canvas.fillRect(_clsRect, _clsColor);
			
			_copyRect.y = 0;
			_copyPoint.y = 0;
			_copyRect.height = rndSkip;
			
			var y:Int = 0;
			
			while (y < sprite.height)
			{
				_copyPoint.x = Std.int(Math.random() * _glitchSize);
				canvas.copyPixels(_image, _copyRect, _copyPoint);
				
				_copyRect.y += rndSkip;
				_copyPoint.y += rndSkip;
				y += rndSkip;
			}
			
			canvas.unlock();
			sprite.pixels = canvas;
			sprite.dirty = true;
			#else
			cast(sprite, GlitchSprite).updateLinePositions();
			#end
			
			_lastUpdate = 0;
		}
	}
}

#if !flash
private class GlitchSprite extends FlxSprite
{
	/**
	 * Information about each line in glitched sprite
	 */
	public var imageLines:Array<ImageLine>;
	
	public var maxGlitch:Float;
	public var glitchSkip:Float;
	
	public var sourceFrame:Int = -1;
	
	private var _sourceSprite:FlxSprite;
	/**
	 * Link to source image tilesheet data
	 */
	private var _imageTileSheetData:TileSheetData;
	/**
	 * Storage for each frame's lines tile IDs
	 */
	private var _imageTileIDs:Map<Int, Array<Int>>;
	
	private var _bgRed:Float;
	private var _bgGreen:Float;
	private var _bgBlue:Float;
	private var _bgAlpha:Float;
	
	public function new(Source:FlxSprite, MaxGlitch:Int, GlitchSkip:Int, BgColor:Int)
	{
		super();
		
		_sourceSprite = Source;
		
		maxGlitch = MaxGlitch;
		glitchSkip = GlitchSkip;
		
		_imageTileIDs = new Map<Int, Array<Int>>();
		imageLines = new Array<ImageLine>();
		
		makeGraphic(1, 1, FlxColor.WHITE);
		
		_frameID = _framesData.frameIDs[0];
		_tileSheetData.isColored = true;
		
		var rgba:RGBA = FlxColor.getRGB(BgColor);
		_bgRed = rgba.red / 255;
		_bgGreen = rgba.green / 255;
		_bgBlue = rgba.blue / 255;
		_bgAlpha = rgba.alpha / 255;
		
		x = _sourceSprite.x;
		y = _sourceSprite.y;
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
		
		for (i in 0...sourceFrameHeight)
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
	
	override public function set_color(Color:Int):Int 
	{
		var col = super.set_color(Color);
		
		if (_color < 0xffffff)
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
			cameras = FlxG.cameras.list;
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
		
		if (_color < 0xffffff)
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

			var csx:Float = 1;
			var ssy:Float = 0;
			var ssx :Float = 0;
			var csy: Float = 1;
			var x1:Float = 0;
			var y1:Float = 0;

			if (!simpleRenderSprite ())
			{
				radians = angle * FlxAngle.TO_RAD;
				cos = Math.cos(radians);
				sin = Math.sin(radians);

				csx = cos * scale.x;
				ssy = sin * scale.y;
				ssx = sin * scale.x;
				csy = cos * scale.y;
				x1 = halfWidth;
				y1 = halfHeight;
			}

			_point.x += halfWidth;
			_point.y += halfHeight;
			
			// Draw background
			if (_bgAlpha > 0)
			{
				currDrawData[currIndex++] = _point.x;
				currDrawData[currIndex++] = _point.y;
				
				currDrawData[currIndex++] = _frameID;
				
				currDrawData[currIndex++] = csx * frameWidth;
				currDrawData[currIndex++] = -ssy * frameHeight;
				currDrawData[currIndex++] = ssx * frameWidth;
				currDrawData[currIndex++] = csy * frameHeight;
				
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

			// Draw lines
			currDrawData = _imageTileSheetData.drawData[camera.ID];
			currIndex = _imageTileSheetData.positionData[camera.ID];

			for (j in 0...imageLines.length)
			{
				lineDef = imageLines[j];
				
				var localX:Float = lineDef.x - x1;
				var localY:Float = lineDef.y - y1;
				
				var relativeX:Float = (localX * csx - localY * ssy);
				var relativeY:Float = (localX * ssx + localY * csy);
				
				currDrawData[currIndex++] = _point.x + relativeX;
				currDrawData[currIndex++] = _point.y + relativeY;
				
				currDrawData[currIndex++] = lineDef.tileID;
				
				currDrawData[currIndex++] = csx;
				currDrawData[currIndex++] = -ssy;
				currDrawData[currIndex++] = ssx;
				currDrawData[currIndex++] = csy;
				
				if (useColor)
				{
					currDrawData[currIndex++] = onCamRed;
					currDrawData[currIndex++] = onCamGreen;
					currDrawData[currIndex++] = onCamBlue;
				}
				
				currDrawData[currIndex++] = alpha;
			}
			_imageTileSheetData.positionData[camera.ID] = currIndex;
			
			FlxBasic._VISIBLECOUNT++;
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
				_framesData = _tileSheetData.getSpriteSheetFrames(1, 1);
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