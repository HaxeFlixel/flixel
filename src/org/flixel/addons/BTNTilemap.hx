package org.flixel.addons;

/**
 * ...
 * @author greglieberman
 */

import org.flixel.FlxPoint;
import org.flixel.FlxTilemap; 

class BTNTilemap extends FlxTilemap
{

	public function new() 
	{
		super();
	}
	
	/**
	* Casts a ray from the start point until it hits either a filled tile, or the edge of the tilemap
	*
	* If the starting point is outside the bounding box of the tilemap,
	* it will not cast the ray, and place the end point at the start point.
	*
	* Warning: If your ray is completely horizontal or vertical, make sure your x or y values are exactly zero.
	* Otherwise you may suffer the wrath of floating point rounding error!
	*
	* Algorithm based on
	* http://www.metanetsoftware.com/technique/tutorialB.html
	* http://www.cse.yorku.ca/~amana/research/grid.pdf
	* http://www.flipcode.com/archives/Raytracing_Topics_Techniques-Part_4_Spatial_Subdivisions.shtml
	*
	* @param start    the starting point of the ray
	* @param direction   the direction to shoot the ray. Does not need to be normalized
	* @param result   where the resulting point is stored, in (x,y) coordinates
	* @param resultInTiles  a point containing the tile that was hit, in tile coordinates (optional)
	* @param maxTilesToCheck The maximum number of tiles you want the ray to pass. -1 means go across the entire tilemap. Only change this if you know what you're doing!
	* @return      true if hit a filled tile, false if it hit the end of the tilemap
	*
	*/
	public function rayCast(start:FlxPoint, direction:FlxPoint, result:FlxPoint = null, resultInTiles:FlxPoint = null, maxTilesToCheck:Int = -1):Bool
	{
		var cx:Float;
		var cy:Float;	   // current x, y, in tiles
		var cbx:Float;
		var cby:Float;    // starting tile cell bounds, in pixels
		var tMaxX:Float;
		var tMaxY:Float;   // maximum time the ray has traveled so far (not distance!)
		var tDeltaX:Float = 0;
		var tDeltaY:Float = 0;  // the time that the ray needs to travel to cross a single tile (not distance!)
		var stepX:Float;
		var stepY:Float;   // step direction, either 1 or -1
		var outX:Float;
		var outY:Float;   // bounds of the tileMap where the ray would exit
		var hitTile:Bool = false;  
		var tResult:Float = 0;
  
		if(start == null)
		{
			return false;
		}
  
		if(result == null)
		{
			result = new FlxPoint();
		}
		
		if (direction == null || (direction.x == 0 && direction.y == 0))
		{
			// no direction, no ray
			result.x = start.x;
			result.y = start.y;
			return false;
		}
		
		// find the tile at the start position of the ray
		cx = coordsToTileX(start.x);
		cy = coordsToTileY(start.y);
		
		if (!inTileRange(cx, cy))
		{
			// outside of the tilemap
			result.x = start.x;
			result.y = start.y;
			return false;   
		}
		
		if (getTile(Std.int(cx), Std.int(cy)) > 0)
		{
			// start point is inside a block
			result.x = start.x;
			result.y = start.y;
			return true;
		}
		
		if (maxTilesToCheck == -1)
		{
			// this number is large enough to guarantee that the ray will pass through the entire tile map
			maxTilesToCheck = widthInTiles * heightInTiles;
		}
		
		// determine step direction, and initial starting block
		if (direction.x > 0)
		{
			stepX = 1;
			outX = widthInTiles;
			cbx = x + (cx + 1) * _tileWidth;
		}
		else
		{
			stepX = -1;
			outX = -1;
			cbx = x + cx * _tileWidth;
		}
		
		if (direction.y > 0)
		{
			stepY = 1;
			outY = heightInTiles;
			cby = y + (cy+1) * _tileHeight;
		}
		else
		{
			stepY = -1;
			outY = -1;
			cby = y + cy * _tileHeight;
		}
		
		// determine tMaxes and deltas
		if (direction.x != 0)
		{
			tMaxX = (cbx - start.x) / direction.x;
			tDeltaX = _tileWidth * stepX / direction.x;
		}
		else
		{
			tMaxX = 1000000;
		}
		
		if (direction.y != 0)
		{
			tMaxY = (cby - start.y) / direction.y;
			tDeltaY = _tileHeight * stepY / direction.y;
		}
		else
		{
			tMaxY = 1000000;
		}
		
		// step through each block  
		for (tileCount in 0...(maxTilesToCheck))
		{
			if (tMaxX < tMaxY)
			{
				cx = cx + stepX;
				if (getTile(Std.int(cx), Std.int(cy)) > 0)
				{
					hitTile = true;
					break;
				}
				
				if (cx == outX)
				{
					hitTile = false;
					break;
				}
				
				tMaxX = tMaxX + tDeltaX;
			}
			else
			{
				cy = cy + stepY;
				if (getTile(Std.int(cx), Std.int(cy)) > 0)
				{
					hitTile = true;
					break;
				}
				
				if (cy == outY)
				{
					hitTile = false;
					break;
				}
				
				tMaxY = tMaxY + tDeltaY;
			}
		}
		
		// result time
		tResult = (tMaxX < tMaxY) ? tMaxX : tMaxY;
		
		// store the result
		result.x = start.x + (direction.x * tResult);
		result.y = start.y + (direction.y * tResult);
		if (resultInTiles != null)
		{
			resultInTiles.x = cx;
			resultInTiles.y = cy;
		}
		
		return hitTile;
	}
   
	public function inTileRange(tileX:Float, tileY:Float):Bool
	{
		return (tileX >= 0 && tileX < widthInTiles && tileY >= 0 && tileY < heightInTiles);
	}
   
	public function tileAt(coordX:Float, coordY:Float):Int
	{
		return getTile(Std.int((coordX - x) / _tileWidth), Std.int((coordY - y) / _tileHeight));
	}
  
	public function tileIndexAt(coordX:Float, coordY:Float):Int
	{
		var X:Int = Std.int((coordX - x) / _tileWidth);
		var Y:Int = Std.int((coordY - y) / _tileHeight);
		return Y * widthInTiles + X;
	}
 
	/**
	*
	* @param X in tiles
	* @param Y in tiles
	* @return
	*
	*/
	public function getTileIndex(X:Int, Y:Int):Int
	{
		return Y * widthInTiles + X;   
	}
   
	public function coordsToTileX(coordX:Float):Float
	{
	return Std.int((coordX - x) / _tileWidth);
	}

	public function coordsToTileY(coordY:Float):Float
	{
		return Std.int((coordY - y) / _tileHeight);
	}

	public function indexToCoordX(index:Int):Float
	{
		return (index % widthInTiles) * _tileWidth + _tileWidth / 2;
	}

	public function indexToCoordY(index:Int):Float
	{
		return Std.int(index / widthInTiles) * _tileHeight + _tileHeight / 2;
	}
	
}