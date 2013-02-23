package org.flixel;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.system.layer.DrawStackItem;

/**
 * This is a basic "environment object" class, used to create simple walls and floors.
 * It can be filled with a random selection of tiles to quickly add detail.
 */
class FlxTileblock extends FlxSprite
{		
	
	#if !flash
	private var _tileWidth:Int;
	private var _tileHeight:Int;
	private var _tileData:Array<Float>;
	
	private var _tileIndices:Array<Int>;
	#end
	
	/**
	 * Creates a new <code>FlxBlock</code> object with the specified position and size.
	 * @param	X			The X position of the block.
	 * @param	Y			The Y position of the block.
	 * @param	Width		The width of the block.
	 * @param	Height		The height of the block.
	 */
	public function new(X:Int, Y:Int, Width:Int, Height:Int)
	{
		super(X, Y);
		#if flash
		makeGraphic(Width, Height, 0, true);
		#else
		bakedRotation = 0;
		width = frameWidth = Width;
		height = frameHeight = Height;
		resetHelpers();
		_tileData = null;
		_tileIndices = null;
		#end
		active = false;
		immovable = true;
		moves = false;
	}
	
	/**
	 * Fills the block with a randomly arranged selection of graphics from the image provided.
	 * @param	TileGraphic 	The graphic class that contains the tiles that should fill this block.
	 * @param	TileWidth		The width of a single tile in the graphic.
	 * @param	TileHeight		The height of a single tile in the graphic.
	 * @param	Empties			The number of "empty" tiles to add to the auto-fill algorithm (e.g. 8 tiles + 4 empties = 1/3 of block will be open holes).
	 */
	public function loadTiles(TileGraphic:Dynamic, TileWidth:Int = 0, TileHeight:Int = 0, Empties:Int = 0):FlxTileblock
	{
		if (TileGraphic == null)
		{
			return this;
		}
		
		//First create a tile brush
		var sprite:FlxSprite = new FlxSprite().loadGraphic(TileGraphic, true, false, TileWidth, TileHeight);
		#if !flash
		_bitmapDataKey = FlxG._lastBitmapDataKey;
		#end
		var spriteWidth:Int = Std.int(sprite.width);
		var spriteHeight:Int = Std.int(sprite.height);
		var total:Int = sprite.frames + Empties;
		
		//Then prep the "canvas" as it were (just doublechecking that the size is on tile boundaries)
		var regen:Bool = false;
		if (width % sprite.width != 0)
		{
			width = Std.int((width / spriteWidth + 1)) * spriteWidth;
			regen = true;
		}
		if (height % sprite.height != 0)
		{
			height = Std.int((height / spriteHeight + 1)) * spriteHeight;
			regen = true;
		}
		
		#if flash
		if (regen)
		{
			makeGraphic(Std.int(width), Std.int(height), 0, true);
		}
		else
		{
	//		this.fill(0);
		}
		#end
		
		//Stamp random tiles onto the canvas
		var row:Int = 0;
		var column:Int;
		var destinationX:Int;
		var destinationY:Int = 0;
		var widthInTiles:Int = Std.int(width / spriteWidth);
		var heightInTiles:Int = Std.int(height / spriteHeight);
		#if !flash
		if (_tileData != null)
		{
			_tileData.splice(0, _tileData.length);
			_tileIndices.splice(0, _tileIndices.length);
		}
		else
		{
			_tileData = [];
			_tileIndices = [];
		}
		_tileWidth = sprite.frameWidth;
		_tileHeight = sprite.frameHeight;
		_pixels = FlxG.addBitmap(TileGraphic, false, false, null, _tileWidth, _tileHeight);
		frameWidth = Std.int(width);
		frameHeight = Std.int(height);
		resetHelpers();
		updateAtlasInfo();
		#end
		while (row < heightInTiles)
		{
			destinationX = 0;
			column = 0;
			while(column < widthInTiles)
			{
				if (FlxG.random() * total > Empties)
				{
					#if flash
					sprite.randomFrame();
					sprite.drawFrame();
					stamp(sprite, destinationX, destinationY);
					#else
					var tileIndex:Int = Std.int(FlxG.random() * _framesData.frameIDs.length);
					_tileIndices.push(tileIndex);
					_tileData.push(_framesData.frameIDs[tileIndex]);
					_tileData.push(destinationX - _halfWidth + 0.5 * _tileWidth);
					_tileData.push(destinationY - _halfHeight + 0.5 * _tileHeight);
					#end
				}
				
				destinationX += spriteWidth;
				column++;
			}
			destinationY += spriteHeight;
			row++;
		}
		#if !flash
		updateFrameData();
		#end
		return this;
	}
	
	#if !flash
	override public function draw():Void 
	{
		if (_atlas == null)
		{
			return;
		}
		
		if (_flickerTimer != 0)
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
		var currDrawData:Array<Float>;
		var currIndex:Int;
		var drawItem:DrawStackItem;
		var isColored:Bool = isColored();
		var l:Int = cameras.length;
		
		var j:Int = 0;
		var numTiles:Int = 0;
		if (_tileData != null)
		{
			numTiles = Std.int(_tileData.length / 3);
		}
		
		var currPosInArr:Int;
		var currTileID:Float;
		var currTileX:Float;
		var currTileY:Float;
		
		var radians:Float;
		var cos:Float;
		var sin:Float;
		var relativeX:Float;
		var relativeY:Float;
		
		while(i < l)
		{
			camera = cameras[i++];
			#if !js
			var isColoredCamera:Bool = camera.isColored();
			drawItem = camera.getDrawStackItem(_atlas, (isColored || isColoredCamera), _blendInt);
			#else
			var useAlpha:Bool = (alpha < 1);
			drawItem = camera.getDrawStackItem(_atlas, useAlpha);
			#end
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			if (!onScreenSprite(camera) || !camera.visible || !camera.exists)
			{
				continue;
			}
			
			_point.x = x - (camera.scroll.x * scrollFactor.x) - (offset.x) + origin.x;
			_point.y = y - (camera.scroll.y * scrollFactor.y) - (offset.y) + origin.y;
			
			#if js
			_point.x = Math.floor(_point.x);
			_point.y = Math.floor(_point.y);
			#end
			
			var redMult:Float = 1;
			var greenMult:Float = 1;
			var blueMult:Float = 1;
			
			#if !js
			if (isColoredCamera)
			{
				redMult = _red * camera.red; 
				greenMult = _green * camera.green;
				blueMult = _blue * camera.blue;
			}
			else
			{
				redMult = _red; 
				greenMult = _green;
				blueMult = _blue;
			}
			#end
			
			if (_tileData != null)
			{
				if (simpleRenderSprite())
				{	//Simple render
					while (j < numTiles)
					{
						currPosInArr = j * 3;
						currTileID = _tileData[currPosInArr];
						currTileX = _tileData[currPosInArr + 1];
						currTileY = _tileData[currPosInArr + 2];
						
						currDrawData[currIndex++] = (_point.x) + currTileX;
						currDrawData[currIndex++] = (_point.y) + currTileY;
						currDrawData[currIndex++] = currTileID;
						
						currDrawData[currIndex++] = 1;
						currDrawData[currIndex++] = 0;
						currDrawData[currIndex++] = 0;
						currDrawData[currIndex++] = 1;
						
						#if !js
						if (isColored || isColoredCamera)
						{
							currDrawData[currIndex++] = redMult; 
							currDrawData[currIndex++] = greenMult;
							currDrawData[currIndex++] = blueMult;
						}
						currDrawData[currIndex++] = alpha;
						#else
						if (useAlpha)
						{
							currDrawData[currIndex++] = alpha;
						}
						#end
						j++;
					}
				}
				else
				{	
					//Advanced render
					radians = angle * FlxG.RAD;
					cos = Math.cos(radians);
					sin = Math.sin(radians);
					
					var csx:Float = cos * scale.x;
					var ssy:Float = sin * scale.y;
					var ssx:Float = sin * scale.x;
					var csy:Float = cos * scale.y;
					
					var x1:Float = (origin.x - _halfWidth);
					var y1:Float = (origin.y - _halfHeight);
					
					while (j < numTiles)
					{
						currPosInArr = j * 3;
						currTileID = _tileData[currPosInArr];
						currTileX = _tileData[currPosInArr + 1] + x1;
						currTileY = _tileData[currPosInArr + 2] + y1;
						
						relativeX = (currTileX * csx - currTileY * ssy);
						relativeY = (currTileX * ssx + currTileY * csy);
						
						currDrawData[currIndex++] = (_point.x) + relativeX;
						currDrawData[currIndex++] = (_point.y) + relativeY;
						
						currDrawData[currIndex++] = currTileID;
						
						currDrawData[currIndex++] = csx;
						currDrawData[currIndex++] = -ssy;
						currDrawData[currIndex++] = ssx;
						currDrawData[currIndex++] = csy;
						
						#if !js
						if (isColored || isColoredCamera)
						{
							currDrawData[currIndex++] = redMult; 
							currDrawData[currIndex++] = greenMult;
							currDrawData[currIndex++] = blueMult;
						}
						currDrawData[currIndex++] = alpha;
						#else
						if (useAlpha)
						{
							currDrawData[currIndex++] = alpha;
						}
						#end
						
						j++;
					}
				}
				
				drawItem.position = currIndex;
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
	
	override public function destroy():Void 
	{
		_tileData = null;
		_tileIndices = null;
		super.destroy();
	}
	
	override public function updateFrameData():Void
	{
		if (_node != null && _tileWidth >= 1 && _tileHeight >= 1)
		{
			_framesData = _node.addSpriteFramesData(_tileWidth, _tileHeight, null, 0, 0, 0, 0, 1, 1);
			
			if (_tileData != null)
			{
				for (i in 0...(_tileIndices.length))
				{
					_tileData[i * 3] = _framesData.frameIDs[_tileIndices[i]];
				}
			}
		}
	}
	#end
}