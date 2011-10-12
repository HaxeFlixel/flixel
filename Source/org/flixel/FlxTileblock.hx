package org.flixel;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Rectangle;

/**
 * This is a basic "environment object" class, used to create simple walls and floors.
 * It can be filled with a random selection of tiles to quickly add detail.
 */
class FlxTileblock extends FlxSprite
{		
	/**
	 * Creates a new <code>FlxBlock</code> object with the specified position and size.
	 * @param	X			The X position of the block.
	 * @param	Y			The Y position of the block.
	 * @param	Width		The width of the block.
	 * @param	Height		The height of the block.
	 */
	#if flash
	public function new(X:Int, Y:Int, Width:UInt, Height:UInt)
	#else
	public function new(X:Int, Y:Int, Width:Int, Height:Int)
	#end
	{
		super(X, Y);
		makeGraphic(Width, Height, 0, true);
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
	#if flash
	public function loadTiles(TileGraphic:Class<Bitmap>, ?TileWidth:UInt = 0, ?TileHeight:UInt = 0, ?Empties:UInt = 0):FlxTileblock
	#else
	public function loadTiles(TileGraphic:Class<Bitmap>, ?TileWidth:Int = 0, ?TileHeight:Int = 0, ?Empties:Int = 0):FlxTileblock
	#end
	{
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
			width = Std.int((width/spriteWidth+1)) * spriteWidth;
			regen = true;
		}
		if(height % sprite.height != 0)
		{
			height = Std.int((height / spriteHeight + 1)) * spriteHeight;
			regen = true;
		}
		if (regen)
		{
			makeGraphic(Std.int(width), Std.int(height), 0, true);
		}
		else
		{
			this.fill(0);
		}
		
		//Stamp random tiles onto the canvas
		var row:Int = 0;
		var column:Int;
		var destinationX:Int;
		var destinationY:Int = 0;
		var widthInTiles:Int = Std.int(width / spriteWidth);
		var heightInTiles:Int = Std.int(height / spriteHeight);
		while(row < heightInTiles)
		{
			destinationX = 0;
			column = 0;
			while(column < widthInTiles)
			{
				if(FlxG.random()*total > Empties)
				{
					sprite.randomFrame();
					sprite.drawFrame();
					stamp(sprite, destinationX, destinationY);
				}
				destinationX += spriteWidth;
				column++;
			}
			destinationY += spriteHeight;
			row++;
		}
		
		return this;
	}
}