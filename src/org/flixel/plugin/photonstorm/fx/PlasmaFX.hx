/**
* PlasmaFX - Special FX Plugin
* -- Part of the Flixel Power Tools set
* 
* v1.4 Moved to the new Special FX Plugins
* v1.3 Colours updated to include alpha values
* v1.2 Updated for the Flixel 2.5 Plugin system
* 
* @version 1.4 - May 8th 2011
* @link http://www.photonstorm.com
* @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm.fx;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import org.flixel.FlxSprite;
import org.flixel.plugin.photonstorm.FlxColor;


/**
 * Creates a plasma effect FlxSprite
 */

class PlasmaFX extends BaseFX
{
	//private var pos1:uint;
	//private var pos2:uint;
	//private var pos3:uint;
	//private var pos4:uint;
	
	#if flash
	public var pos1:UInt;
	public var pos2:UInt;
	public var pos3:UInt;
	public var pos4:UInt;
	public var depth:UInt;
	
	private var tpos1:UInt;
	private var tpos2:UInt;
	private var tpos3:UInt;
	private var tpos4:UInt;
	
	private var aSin:Array<Float>;
	//private var previousColour:uint;
	private var colours:Array<UInt>;
	private var step:UInt;
	private var span:UInt;
	#else
	public var pos1:Int;
	public var pos2:Int;
	public var pos3:Int;
	public var pos4:Int;
	public var depth:Int;
	
	private var tpos1:Int;
	private var tpos2:Int;
	private var tpos3:Int;
	private var tpos4:Int;
	
	private var aSin:Array<Float>;
	//private var previousColour:uint;
	private var colours:Array<Int>;
	private var step:Int;
	private var span:Int;
	#end
	
	public function new()
	{
		depth = 128;
		step = 0;
		
		super();
	}
	
	#if flash
	public function create(x:Int, y:Int, width:UInt, height:UInt, ?scaleX:UInt = 1, ?scaleY:UInt = 1):FlxSprite
	#else
	public function create(x:Int, y:Int, width:UInt, height:UInt, ?scaleX:UInt = 1, ?scaleY:UInt = 1):FlxSprite
	#end
	{
		sprite = new FlxSprite(x, y).makeGraphic(width, height, 0x0);
		
		if (scaleX != 1 || scaleY != 1)
		{
			sprite.scale = new FlxPoint(scaleX, scaleY);
			sprite.x += width / scaleX;
			sprite.y += height / scaleY;
		}
		
		canvas = new BitmapData(width, height, true, 0x0);
		
		colours = FlxColor.getHSVColorWheel();
		
		//colours = FlxColor.getHSVColorWheel(140);	// now supports alpha :)
		//colours = FlxGradient.createGradientArray(1, 360, [0xff000000, 0xff000000, 0xff000000, 0x00000000, 0xff000000], 2);	//	Lovely black reveal for over an image
		//colours = FlxGradient.createGradientArray(1, 360, [0xff0000FF, 0xff000000, 0xff8F107C, 0xff00FFFF, 0xff0000FF], 1); // lovely purple black blue thingy
		
		span = colours.length - 1;
		
		aSin = new Array();
		
		for (i in 0...512)
		{
			//var rad:Number = (i * 0.703125) * 0.0174532;
			var rad:Float = (i * 0.703125) * 0.0174532;
			
			//	Any power of 2!
			//	http://www.vaughns-1-pagers.com/computer/powers-of-2.htm
			//	256, 512, 1024, 2048, 4096, 8192, 16384
			aSin.push(Math.sin(rad) * 1024);
			
			//aSin[i] = Math.cos(rad) * 1024;
		}
		
		active = true;
		
		tpos1 = 293;
		tpos2 = 483;
		tpos3 = 120;
		tpos4 = 360;
		
		pos1 = 0;
		pos2 = 5;
		pos3 = 0;
		pos4 = 0;
		
		return sprite;
	}
	
	public function draw():Void
	{
		if (step < 10)
		{
			//trace(step, tpos1, tpos2, tpos3, tpos4, pos1, pos2, pos3, pos4, index);
			step++;
		}
		
		tpos4 = pos4;
		tpos3 = pos3;
		
		canvas.lock();
		
		for (y in 0...canvas.height)
		{
			tpos1 = pos1 + 5;
			tpos2 = pos2 + 3;
			
			//tpos1 = pos1;
			//tpos2 = pos2;
			
			tpos2 &= 511;
			tpos3 &= 511;
			
			for (x in 0...canvas.width)
			{
				tpos1 &= 511;
				tpos2 &= 511;
				
				var x2:Int = Math.floor(aSin[tpos1] + aSin[tpos2] + aSin[tpos3] + aSin[tpos4]);
			
				//var index:int = depth + (x2 >> 4);
				var index:Int = depth + (x2 >> 4);
				//p = (128 + (p >> 4)) & 255;

				
				if (index <= 0)
				{
					index += span;
				}
				
				if (index >= Math.floor(span))
				{
					index -= span;
				}
					
				canvas.setPixel32(x, y, colours[index]);
				
				tpos1 += 5;
				tpos2 += 3;
			}
			
			tpos3 += 1;
			tpos4 += 3;
		}
		
		canvas.unlock();
		
		sprite.pixels = canvas;
		sprite.dirty = true;
		
		pos1 += 4;	// horizontal shift
		pos3 += 2;	// vertical shift
	}
	
}