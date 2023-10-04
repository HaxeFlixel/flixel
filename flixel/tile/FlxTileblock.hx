package flixel.tile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;

/**
 * This is a basic "environment object" class, used to create simple walls and floors.
 * It can be filled with a random selection of tiles to quickly add detail.
 */
class FlxTileblock extends FlxSprite
{
	var tileSprite:FlxSprite;

	/**
	 * Creates a new FlxBlock object with the specified position and size.
	 *
	 * @param   x       The X position of the block.
	 * @param   y       The Y position of the block.
	 * @param   width   The width of the block.
	 * @param   height  The height of the block.
	 */
	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		super(x, y);
		makeGraphic(width, height, FlxColor.TRANSPARENT, true);
		active = false;
		immovable = true;
		moves = false;
	}

	override public function destroy():Void
	{
		tileSprite = FlxDestroyUtil.destroy(tileSprite);
		super.destroy();
	}

	/**
	 * Fills the block with a randomly arranged selection of frames.
	 *
	 * @param   tileFrames  The frames that should fill this block.
	 * @param   empties     The number of "empty" tiles to add to the auto-fill algorithm (e.g. 8 tiles + 4 empties = 1/3 of block will be open holes).
	 * @return  This tile block.
	 */
	public function loadFrames(tileFrames:FlxTileFrames, empties:Int = 0):FlxTileblock
	{
		if (tileFrames == null)
		{
			return this;
		}

		// First create a tile brush
		tileSprite = (tileSprite == null) ? new FlxSprite() : tileSprite;
		tileSprite.frames = tileFrames;
		var spriteWidth:Int = Std.int(tileSprite.width);
		var spriteHeight:Int = Std.int(tileSprite.height);
		var total:Int = tileSprite.numFrames + empties;

		// Then prep the "canvas" as it were (just double checking that the size is on tile boundaries)
		var regen:Bool = false;

		if (width % tileSprite.width != 0)
		{
			width = Std.int((width / spriteWidth + 1)) * spriteWidth;
			regen = true;
		}

		if (height % tileSprite.height != 0)
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
			FlxSpriteUtil.fill(this, 0);
		}

		// Stamp random tiles onto the canvas
		var row:Int = 0;
		var column:Int;
		var destinationX:Int;
		var destinationY:Int = 0;
		var widthInTiles:Int = Std.int(width / spriteWidth);
		var heightInTiles:Int = Std.int(height / spriteHeight);

		while (row < heightInTiles)
		{
			destinationX = 0;
			column = 0;

			while (column < widthInTiles)
			{
				if (FlxG.random.float() * total > empties)
				{
					tileSprite.animation.randomFrame();
					tileSprite.drawFrame();
					stamp(tileSprite, destinationX, destinationY);
				}

				destinationX += spriteWidth;
				column++;
			}

			destinationY += spriteHeight;
			row++;
		}

		dirty = true;
		return this;
	}

	/**
	 * Fills the block with a randomly arranged selection of graphics from the image provided.
	 *
	 * @param   tileGraphic  The graphic class that contains the tiles that should fill this block.
	 * @param   tileWidth    The width of a single tile in the graphic.
	 * @param   tileHeight   The height of a single tile in the graphic.
	 * @param   empties      The number of "empty" tiles to add to the auto-fill algorithm (e.g. 8 tiles + 4 empties = 1/3 of block will be open holes).
	 * @return  This tile block.
	 */
	public function loadTiles(tileGraphic:FlxGraphicAsset, tileWidth = 0, tileHeight = 0, empties = 0):FlxTileblock
	{
		if (tileGraphic == null)
		{
			return this;
		}

		var graph:FlxGraphic = FlxG.bitmap.add(tileGraphic);
		if (graph == null)
		{
			return this;
		}

		if (tileWidth == 0)
		{
			tileWidth = graph.height;
			tileWidth = (tileWidth > graph.width) ? graph.width : tileWidth;
		}

		if (tileHeight == 0)
		{
			tileHeight = tileWidth;
			tileHeight = (tileHeight > graph.height) ? graph.height : tileHeight;
		}

		var tileFrames:FlxTileFrames = FlxTileFrames.fromGraphic(graph, FlxPoint.get(tileWidth, tileHeight));
		return this.loadFrames(tileFrames, empties);
	}

	public function setTile(x:Int, y:Int, index:Int):Void
	{
		tileSprite.animation.frameIndex = index;
		stamp(tileSprite, x * Std.int(tileSprite.width), y * Std.int(tileSprite.height));
		dirty = true;
	}
}
