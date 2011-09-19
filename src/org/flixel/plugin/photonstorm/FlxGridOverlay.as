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

package org.flixel.plugin.photonstorm 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.*;
	
	public class FlxGridOverlay 
	{
		public function FlxGridOverlay() 
		{
		}
		
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
		public static function create(cellWidth:int, cellHeight:int, width:int = -1, height:int = -1, addLegend:Boolean = false, alternate:Boolean = true, color1:uint = 0xffe7e6e6, color2:uint = 0xffd9d5d5):FlxSprite
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
			
			var output:FlxSprite = new FlxSprite().makeGraphic(width, height);
			
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
		public static function overlay(source:FlxSprite, cellWidth:int, cellHeight:int, width:int = -1, height:int = -1, addLegend:Boolean = false, alternate:Boolean = true, color1:uint = 0x88e7e6e6, color2:uint = 0x88d9d5d5):FlxSprite
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
		
		public static function addLegend(source:FlxSprite, cellWidth:int, cellHeight:int, xAxis:Boolean = true, yAxis:Boolean = true):FlxSprite
		{
			if (cellWidth > source.width)
			{
				throw Error("cellWidth larger than FlxSprites width");
				return source;
			}
			
			if (cellHeight > source.height)
			{
				throw Error("cellHeight larger than FlxSprites height");
				return source;
			}
			
			if (source.width < cellWidth || source.height < cellHeight)
			{
				throw Error("source FlxSprite width or height smaller than requested cell width or height");
				return source;
			}
			
			//	Valid cell width/height and source to work on
			
			return source;
			
		}
		
		public static function createGrid(cellWidth:int, cellHeight:int, width:int, height:int, alternate:Boolean, color1:uint, color2:uint):BitmapData
		{
			//	How many cells can we fit into the width/height? (round it UP if not even, then trim back)
			
			var rowColor:uint = color1;
			var lastColor:uint = color1;
			var grid:BitmapData = new BitmapData(width, height, true);
			
			//	If there aren't an even number of cells in a row then we need to swap the lastColor value
			
			for (var y:int = 0; y <= height; y += cellHeight)
			{
				if (y > 0 && lastColor == rowColor && alternate)
				{
					(lastColor == color1) ? lastColor = color2 : lastColor = color1;
				}
				else if (y > 0 && lastColor != rowColor && alternate == false)
				{
					(lastColor == color2) ? lastColor = color1 : lastColor = color2;
				}
				
				for (var x:int = 0; x <= width; x += cellWidth)
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
				}
			}

			return grid;
		}
		
		
	}

}