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
	private var _tilePointIDs:Array<TilePointID>;
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
		_tilePointIDs = null;
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
		if (_tilePointIDs != null)
		{
			for (point in _tilePointIDs)
			{
				point.destroy();
			}
		}
		_tilePointIDs = new Array<TilePointID>();
		_tileWidth = sprite.frameWidth;
		_tileHeight = sprite.frameHeight;
		_pixels = sprite.pixels;
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
					_tilePointIDs.push(new TilePointID(new Point(destinationX - origin.x + 0.5 * _tileWidth, destinationY - origin.y + 0.5 * _tileHeight), Math.floor(FlxG.random() * _framesData.frameIDs.length)));
					#end
				}
				#if !flash
				_tilePointIDs.push(new TilePointID(new Point(destinationX - origin.x + 0.5 * _tileWidth, destinationY - origin.y + 0.5 * _tileHeight), -1));
				#end
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
		var camID:Int;
		var l:Int = cameras.length;
		
		var j:Int = 0;
		var numTiles:Int = 0;
		if (_tilePointIDs != null)
		{
			numTiles = _tilePointIDs.length;
		}
		var currTileID:TilePointID;
		
		var radians:Float;
		var cos:Float;
		var sin:Float;
		var relativeX:Float;
		var relativeY:Float;
		
		while(i < l)
		{
			camera = cameras[i++];
			camID = camera.ID;
			
			if (!onScreen(camera))
			{
				continue;
			}
			
			_point.x = x - Math.floor(camera.scroll.x * scrollFactor.x) - Math.floor(offset.x);
			_point.y = y - Math.floor(camera.scroll.y * scrollFactor.y) - Math.floor(offset.y);
			
			if (_tilePointIDs != null && _tileSheetData != null)
			{
				if (simpleRender)
				{	//Simple render
					while (j < numTiles)
					{
						currTileID = _tilePointIDs[j];
						
						if (currTileID.tileID != -1)
						{
							_tileSheetData.drawData[camID].push(Math.floor(_point.x) + origin.x + currTileID.point.x);
							_tileSheetData.drawData[camID].push(Math.floor(_point.y) + origin.y + currTileID.point.y);
							_tileSheetData.drawData[camID].push(_framesData.frameIDs[currTileID.tileID]);
							_tileSheetData.drawData[camID].push(1.0); // scale
							_tileSheetData.drawData[camID].push(0.0); // rotation
							#if neko
							if (camera.color.rgb < 0xffffff)
							#else
							if (camera.color < 0xffffff)
							#end
							{
								_tileSheetData.drawData[camID].push(_red * camera.red); 
								_tileSheetData.drawData[camID].push(_green * camera.green);
								_tileSheetData.drawData[camID].push(_blue * camera.blue);
							}
							else
							{
								_tileSheetData.drawData[camID].push(_red); 
								_tileSheetData.drawData[camID].push(_green);
								_tileSheetData.drawData[camID].push(_blue);
							}
							_tileSheetData.drawData[camID].push(_alpha);
						}
						
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
						currTileID = _tilePointIDs[j];
						
						if (currTileID.tileID != -1)
						{
							relativeX = (currTileID.point.x * cos - currTileID.point.y * sin) * scale.x;
							relativeY = (currTileID.point.x * sin + currTileID.point.y * cos) * scale.x;
							
							_tileSheetData.drawData[camID].push(Math.floor(_point.x) + origin.x + relativeX);
							_tileSheetData.drawData[camID].push(Math.floor(_point.y) + origin.y + relativeY);
							
							_tileSheetData.drawData[camID].push(_framesData.frameIDs[currTileID.tileID]);
							
							_tileSheetData.drawData[camID].push(scale.x); // scale
							_tileSheetData.drawData[camID].push(-radians); // rotation
							#if neko
							if (camera.color.rgb < 0xffffff)
							#else
							if (camera.color < 0xffffff)
							#end
							{
								_tileSheetData.drawData[camID].push(_red * camera.red); 
								_tileSheetData.drawData[camID].push(_green * camera.green);
								_tileSheetData.drawData[camID].push(_blue * camera.blue);
							}
							else
							{
								_tileSheetData.drawData[camID].push(_red); 
								_tileSheetData.drawData[camID].push(_green);
								_tileSheetData.drawData[camID].push(_blue);
							}
							_tileSheetData.drawData[camID].push(_alpha);
						}
						
						j++;
					}
				}
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
		for (point in _tilePointIDs)
		{
			point.destroy();
		}
		_tilePointIDs = null;
		super.destroy();
	}
	
	override public function updateTileSheet():Void
	{
		if (_pixels != null && _tileWidth >= 1 && _tileHeight >= 1)
		{
			_tileSheetData = TileSheetManager.addTileSheet(_pixels);
			_tileSheetData.antialiasing = _antialiasing;
			_framesData = _tileSheetData.addSpriteFramesData(_tileWidth, _tileHeight);
		}
	}
	#end
}

class TilePointID
{
	public var point:Point;
	public var tileID:Int;
	
	public function new(point:Point, tileID:Int)
	{
		this.point = point;
		this.tileID = tileID;
	}
	
	public function destroy():Void
	{
		point = null;
	}
}