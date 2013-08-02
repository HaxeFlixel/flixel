package flixel.tile;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.layer.DrawStackItem;
import flixel.util.FlxAngle;
import flixel.util.FlxRandom;
import flixel.util.FlxSpriteUtil;

/**
 * This is a basic "environment object" class, used to create simple walls and floors.
 * It can be filled with a random selection of tiles to quickly add detail.
 */
class FlxTileblock extends FlxSprite
{		
	
	#if !(flash || js)
	private var _tileWidth:Int;
	private var _tileHeight:Int;
	private var _tileData:Array<Float>;
	
	private var _tileIndices:Array<Int>;
	#end
	
	/**
	 * Helper variable for non-flash targets. Adjust it's value if you'll see tilemap tearing (empty pixels between tiles). To something like 1.02 or 1.03
	 */
	public var tileScaleHack:Float = 1.01;
	
	/**
	 * Creates a new <code>FlxBlock</code> object with the specified position and size.
	 * 
	 * @param	X			The X position of the block.
	 * @param	Y			The Y position of the block.
	 * @param	Width		The width of the block.
	 * @param	Height		The height of the block.
	 */
	public function new(X:Int, Y:Int, Width:Int, Height:Int)
	{
		super(X, Y);
		
		#if (flash || js)
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
	 * 
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
		
		// First create a tile brush
		var sprite:FlxSprite = new FlxSprite().loadGraphic(TileGraphic, true, false, TileWidth, TileHeight);
		var spriteWidth:Int = Std.int(sprite.width);
		var spriteHeight:Int = Std.int(sprite.height);
		var total:Int = sprite.frames + Empties;
		
		// Then prep the "canvas" as it were (just doublechecking that the size is on tile boundaries)
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
		
		#if (flash || js)
		if (regen)
		{
			makeGraphic(Std.int(width), Std.int(height), 0, true);
		}
		else
		{
			FlxSpriteUtil.fill(this, 0);
		}
		#end
		
		// Stamp random tiles onto the canvas
		var row:Int = 0;
		var column:Int;
		var destinationX:Int;
		var destinationY:Int = 0;
		var widthInTiles:Int = Std.int(width / spriteWidth);
		var heightInTiles:Int = Std.int(height / spriteHeight);
		
		#if !(flash || js)
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
		frameWidth = Std.int(width);
		frameHeight = Std.int(height);
		
		setCachedGraphics(sprite.cachedGraphics);
		_region = sprite.region.clone();
		updateFrameData();
		resetHelpers();
		#end
		while (row < heightInTiles)
		{
			destinationX = 0;
			column = 0;
			
			while(column < widthInTiles)
			{
				if (Math.random() * total > Empties)
				{
					#if (flash || js)
					sprite.randomFrame();
					sprite.drawFrame();
					stamp(sprite, destinationX, destinationY);
					#else
					var tileIndex:Int = Std.int(Math.random() * _framesData.frames.length);
					_tileIndices.push(tileIndex);
					_tileData.push(_framesData.frames[tileIndex].tileID);
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
		
		sprite.destroy();
		return this;
	}
	
	#if !(flash || js)
	override public function draw():Void 
	{
		if (cameras == null)
		{
			cameras = FlxG.cameras.list;
		}
		
		var camera:FlxCamera;
		var i:Int = 0;
		var currDrawData:Array<Float>;
		var currIndex:Int;
		var drawItem:DrawStackItem;
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
		
		var relativeX:Float;
		var relativeY:Float;
		
		while (i < l)
		{
			camera = cameras[i++];
			drawItem = camera.getDrawStackItem(_cachedGraphics, isColored, _blendInt, antialiasing);
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			if (!camera.visible || !camera.exists || !onScreen(camera))
			{
				continue;
			}
			
			_point.x = x - (camera.scroll.x * scrollFactor.x) - (offset.x) + origin.x;
			_point.y = y - (camera.scroll.y * scrollFactor.y) - (offset.y) + origin.y;
			
			if (_tileData != null)
			{
				var csx:Float = tileScaleHack;
				var ssy:Float = 0;
				var ssx:Float = 0;
				var csy:Float = tileScaleHack;
				var x1:Float = 0;
				var y1:Float = 0;
				
				if (!simpleRenderSprite())
				{
					if (_angleChanged)
					{
						var radians:Float = -angle * FlxAngle.TO_RAD;
						_sinAngle = Math.sin(radians);
						_cosAngle = Math.cos(radians);
						_angleChanged = false;
					}
					
					// Tilemap tearing hack
					var sx:Float = tileScaleHack * scale.x;
					var sy:Float = tileScaleHack * scale.y;
					
					csx = _cosAngle * sx;
					ssy = _sinAngle * sy;
					ssx = _sinAngle * sx;
					csy = _cosAngle * sy;
					
					x1 = (origin.x - _halfWidth);
					y1 = (origin.y - _halfHeight);
				}
				
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
					currDrawData[currIndex++] = ssx;
					currDrawData[currIndex++] = -ssy;
					currDrawData[currIndex++] = csy;

					if (isColored)
					{
						currDrawData[currIndex++] = _red; 
						currDrawData[currIndex++] = _green;
						currDrawData[currIndex++] = _blue;
					}
					
					currDrawData[currIndex++] = alpha;
					j++;
				}
				
				drawItem.position = currIndex;
			}
			
			#if !FLX_NO_DEBUG
			FlxBasic._VISIBLECOUNT++;
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
		if (_cachedGraphics != null && _tileWidth >= 1 && _tileHeight >= 1)
		{
			_framesData = _cachedGraphics.tilesheet.getSpriteSheetFrames(_region, null);
			
			if (_tileData != null)
			{
				for (i in 0..._tileIndices.length)
				{
					_tileData[i * 3] = _framesData.frames[_tileIndices[i]].tileID;
				}
			}
		}
	}
	#end
}