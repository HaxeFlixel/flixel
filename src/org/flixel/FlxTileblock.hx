package org.flixel;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;

#if (cpp || neko)
import org.flixel.tileSheetManager.TileSheetManager;
#end

/**
 * This is a basic "environment object" class, used to create simple walls and floors.
 * It can be filled with a random selection of tiles to quickly add detail.
 */
class FlxTileblock extends FlxSprite
{		
	
	#if (cpp || neko)
	private var _tileWidth:Int;
	private var _tileHeight:Int;
	private var _tileData:Array<Float>;
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
		makeGraphic(FlxU.fromIntToUInt(Width), FlxU.fromIntToUInt(Height), 0, true);
		#else
		_bakedRotation = 0;
		width = frameWidth = Width;
		height = frameHeight = Height;
		resetHelpers();
		_tileData = null;
		#end
		active = false;
		immovable = true;
	}
	
	/**
	 * Fills the block with a randomly arranged selection of graphics from the image provided.
	 * @param	TileGraphic 	The graphic class that contains the tiles that should fill this block.
	 * @param	TileWidth		The width of a single tile in the graphic.
	 * @param	TileHeight		The height of a single tile in the graphic.
	 * @param	Empties			The number of "empty" tiles to add to the auto-fill algorithm (e.g. 8 tiles + 4 empties = 1/3 of block will be open holes).
	 */
	public function loadTiles(TileGraphic:Dynamic, ?TileWidth:Int = 0, ?TileHeight:Int = 0, ?Empties:Int = 0):FlxTileblock
	{
		TileWidth = FlxU.fromIntToUInt(TileWidth);
		TileHeight = FlxU.fromIntToUInt(TileHeight);
		Empties = FlxU.fromIntToUInt(Empties);
		
		if (TileGraphic == null)
		{
			return this;
		}
		
		//First create a tile brush
		var sprite:FlxSprite = new FlxSprite().loadGraphic(TileGraphic, true, false, TileWidth, TileHeight);
		var spriteWidth:Int = Std.int(sprite.width);
		var spriteHeight:Int = Std.int(sprite.height);
		var total:Int = sprite.frames + Empties;
		
		//Then prep the "canvas" as it were (just doublechecking that the size is on tile boundaries)
		var regen:Bool = false;
		if(width % sprite.width != 0)
		{
			width = Std.int((width / spriteWidth + 1)) * spriteWidth;
			regen = true;
		}
		if(height % sprite.height != 0)
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
			this.fill(0);
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
		}
		else
		{
			_tileData = [];
		}
		_tileWidth = sprite.frameWidth;
		_tileHeight = sprite.frameHeight;
		#if flash
		_pixels = sprite.pixels;
		#else
		_pixels = FlxG.addBitmap(TileGraphic);
		#end
		frameWidth = Math.floor(width);
		frameHeight = Math.floor(height);
		resetHelpers();
		updateTileSheet();
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
					_tileData.push(_framesData.frameIDs[Math.floor(FlxG.random() * _framesData.frameIDs.length)]);
					_tileData.push(destinationX - origin.x + 0.5 * _tileWidth);
					_tileData.push(destinationY - origin.y + 0.5 * _tileHeight);
					#end
				}
				
				destinationX += spriteWidth;
				column++;
			}
			destinationY += spriteHeight;
			row++;
		}
		
		return this;
	}
	
	#if (cpp || neko)
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
		var currDrawData:Array<Float>;
		var currIndex:Int;
		var l:Int = cameras.length;
		
		var j:Int = 0;
		var numTiles:Int = 0;
		if (_tileData != null)
		{
			numTiles = Math.floor(_tileData.length / 3);
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
			currDrawData = _tileSheetData.drawData[camera.ID];
			currIndex = _tileSheetData.positionData[camera.ID];
			
			if (!onScreen(camera))
			{
				continue;
			}
			
			_point.x = x - Math.floor(camera.scroll.x * scrollFactor.x) - Math.floor(offset.x);
			_point.y = y - Math.floor(camera.scroll.y * scrollFactor.y) - Math.floor(offset.y);
			
			var redMult:Float = 1;
			var greenMult:Float = 1;
			var blueMult:Float = 1;
			
			var isColoredCamera:Bool = camera.isColored;
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
			
			if (_tileData != null && _tileSheetData != null)
			{
				if (simpleRender)
				{	//Simple render
					while (j < numTiles)
					{
						currPosInArr = j * 3;
						currTileID = _tileData[currPosInArr];
						currTileX = _tileData[currPosInArr + 1];
						currTileY = _tileData[currPosInArr + 2];
						
						currDrawData[currIndex++] = Math.floor(_point.x) + origin.x + currTileX;
						currDrawData[currIndex++] = Math.floor(_point.y) + origin.y + currTileY;
						currDrawData[currIndex++] = currTileID;
						
						currDrawData[currIndex++] = 1;
						currDrawData[currIndex++] = 0;
						currDrawData[currIndex++] = 0;
						currDrawData[currIndex++] = 1;
						
						if (_tileSheetData.isColored || isColoredCamera)
						{
							currDrawData[currIndex++] = redMult; 
							currDrawData[currIndex++] = greenMult;
							currDrawData[currIndex++] = blueMult;
						}
						
						currDrawData[currIndex++] = _alpha;
						j++;
					}
				}
				else
				{	
					//Advanced render
					radians = angle * 0.017453293;
					cos = Math.cos(radians);
					sin = Math.sin(radians);
					
					while (j < numTiles)
					{
						currPosInArr = j * 3;
						currTileID = _tileData[currPosInArr];
						currTileX = _tileData[currPosInArr + 1];
						currTileY = _tileData[currPosInArr + 2];
						
						relativeX = (currTileX * cos * scale.x - currTileY * sin * scale.y);
						relativeY = (currTileX * sin * scale.x + currTileY * cos * scale.y);
						
						currDrawData[currIndex++] = Math.floor(_point.x) + origin.x + relativeX;
						currDrawData[currIndex++] = Math.floor(_point.y) + origin.y + relativeY;
						
						currDrawData[currIndex++] = currTileID;
						
						currDrawData[currIndex++] = cos * scale.x;
						currDrawData[currIndex++] = -sin * scale.y;
						currDrawData[currIndex++] = sin * scale.x;
						currDrawData[currIndex++] = cos * scale.y;
						
						if (_tileSheetData.isColored || isColoredCamera)
						{
							currDrawData[currIndex++] = redMult; 
							currDrawData[currIndex++] = greenMult;
							currDrawData[currIndex++] = blueMult;
						}
						
						currDrawData[currIndex++] = _alpha;
						j++;
					}
				}
				
				_tileSheetData.positionData[camera.ID] = currIndex;
			}
			
			FlxBasic._VISIBLECOUNT++;
			if (FlxG.visualDebug && !ignoreDrawDebug)
			{
				drawDebug(camera);
			}
		}
	}
	
	override public function destroy():Void 
	{
		_tileData = null;
		super.destroy();
	}
	
	override public function updateTileSheet():Void
	{
		if (_pixels != null && _tileWidth >= 1 && _tileHeight >= 1)
		{
			_tileSheetData = TileSheetManager.addTileSheet(_pixels);
			_tileSheetData.antialiasing = _antialiasing;
			//_framesData = _tileSheetData.addSpriteFramesData(_tileWidth, _tileHeight, false, null, 0, 0, 0, 0, 1, 1);
			_framesData = _tileSheetData.addSpriteFramesData(_tileWidth, _tileHeight);
		}
	}
	#end
}