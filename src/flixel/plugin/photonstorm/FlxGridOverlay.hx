/**
* FlxGridOverlay
* -- Part of the Flixel Power Tools set
* 
* v1.1 Updated for the Flixel 2.5 Plugin system
* 
* @version 1.1 - April 23rd 2011
* @link http://www.photonstorm.com
* @author Richard Davey / Photon Storm
*/

package flixel.plugin.photonstorm;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;

class FlxGridOverlay 
{
	public function new() { }
	
	/**
	 * Creates an FlxSprite of the given width and height filled with a checkerboard pattern.<br />
	 * Each grid cell is the specified width and height, and alternates between two colors.<br />
	 * If alternate is true each row of the pattern will be offset, for a proper checkerboard style. If false each row will be the same colour, creating a striped-pattern effect.<br />
	 * So to create an 8x8 grid you'd call create(8,8)
	 * 
	 * @param	cellWidth		The grid cell width
	 * @param	cellHeight		The grid cell height
	 * @param	width			The width of the FlxSprite. If -1 it will be the size of the game (FlxG.width)
	 * @param	height			The height of the FlxSprite. If -1 it will be the size of the game (FlxG.height)
	 * @param	addLegend		TODO
	 * @param	alternate		Should the pattern alternate on each new row? Default true = checkerboard effect. False = vertical stripes
	 * @param	color1			The first fill colour in 0xAARRGGBB format
	 * @param	color2			The second fill colour in 0xAARRGGBB format
	 * 
	 * @return	FlxSprite of given width/height
	 */
	public static function create(cellWidth:Int, cellHeight:Int, width:Int = -1, height:Int = -1, addLegend:Bool = false, alternate:Bool = true, color1:Int = 0xffe7e6e6, color2:Int = 0xffd9d5d5):FlxSprite
	{
		if (width == -1)
		{
			width = FlxG.width;
		}
		
		if (height == -1)
		{
			height = FlxG.height;
		}
		
		if (width < cellWidth || height < cellHeight)
		{
			return null;
		}
		
		var grid:BitmapData = createGrid(cellWidth, cellHeight, width, height, alternate, color1, color2);
		
		//var output:FlxSprite = new FlxSprite().makeGraphic(width, height);
		var output:FlxSprite = new FlxSprite();
		
		output.pixels = grid;
		output.dirty = true;
		
		return output;
	}
	
	/**
	 * Creates a checkerboard pattern of the given width/height and overlays it onto the given FlxSprite.<br />
	 * Each grid cell is the specified width and height, and alternates between two colors.<br />
	 * If alternate is true each row of the pattern will be offset, for a proper checkerboard style. If false each row will be the same colour, creating a striped-pattern effect.<br />
	 * So to create an 8x8 grid you'd call create(8,8,
	 * 
	 * @param	source			The FlxSprite you wish to draw the grid on-top of. This updates its pixels value, not just the current frame (don't use animated sprites!)
	 * @param	cellWidth		The grid cell width
	 * @param	cellHeight		The grid cell height
	 * @param	width			The width of the FlxSprite. If -1 it will be the size of the game (FlxG.width)
	 * @param	height			The height of the FlxSprite. If -1 it will be the size of the game (FlxG.height)
	 * @param	addLegend		TODO
	 * @param	alternate		Should the pattern alternate on each new row? Default true = checkerboard effect. False = vertical stripes
	 * @param	color1			The first fill colour in 0xAARRGGBB format
	 * @param	color2			The second fill colour in 0xAARRGGBB format
	 * 
	 * @return	The modified source FlxSprite
	 */
	public static function overlay(source:FlxSprite, cellWidth:Int, cellHeight:Int, width:Int = -1, height:Int = -1, addLegend:Bool = false, alternate:Bool = true, color1:Int = 0x88e7e6e6, color2:Int = 0x88d9d5d5):FlxSprite
	{
		if (width == -1)
		{
			width = FlxG.width;
		}
		
		if (height == -1)
		{
			height = FlxG.height;
		}
		
		if (width < cellWidth || height < cellHeight)
		{
			return null;
		}
		
		var grid:BitmapData = createGrid(cellWidth, cellHeight, width, height, alternate, color1, color2);
		
		var pixels:BitmapData = source.pixels;
		
		pixels.copyPixels(grid, new Rectangle(0, 0, width, height), new Point(0, 0), null, null, true);
		
		source.pixels = pixels;
		
		return source;
	}
	
	public static function addLegend(source:FlxSprite, cellWidth:Int, cellHeight:Int, xAxis:Bool = true, yAxis:Bool = true):FlxSprite
	{
		if (cellWidth > source.width)
		{
			throw "cellWidth larger than FlxSprites width";
			return source;
		}
		
		if (cellHeight > source.height)
		{
			throw "cellHeight larger than FlxSprites height";
			return source;
		}
		
		if (source.width < cellWidth || source.height < cellHeight)
		{
			throw "source FlxSprite width or height smaller than requested cell width or height";
			return source;
		}
		
		//	Valid cell width/height and source to work on
		
		return source;
		
	}
	
	public static function createGrid(cellWidth:Int, cellHeight:Int, width:Int, height:Int, alternate:Bool, color1:Int, color2:Int):BitmapData
	{
		//	How many cells can we fit into the width/height? (round it UP if not even, then trim back)
		var rowColor:Int = color1;
		var lastColor:Int = color1;
		var grid:BitmapData = new BitmapData(width, height, true);
		
		//	If there aren't an even number of cells in a row then we need to swap the lastColor value
		var y:Int = 0;
		while (y <= height)
		{
			if (y > 0 && lastColor == rowColor && alternate)
			{
				(lastColor == color1) ? lastColor = color2 : lastColor = color1;
			}
			else if (y > 0 && lastColor != rowColor && alternate == false)
			{
				(lastColor == color2) ? lastColor = color1 : lastColor = color2;
			}
			
			var x:Int = 0;
			while (x <= width)
			{
				if (x == 0)
				{
					rowColor = lastColor;
				}
				
				grid.fillRect(new Rectangle(x, y, cellWidth, cellHeight), lastColor);
				
				if (lastColor == color1)
				{
					lastColor = color2;
				}
				else
				{
					lastColor = color1;
				}
				x += cellWidth;
			}
			y += cellHeight;
		}

		return grid;
	}
	
}