package flixel.util;

import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.MultiVarTween;
import flixel.effects.FlxFlicker;

// TODO: pad(): Pad the sprite out with empty pixels left/right/above/below it
// TODO: flip(): Flip image data horizontally / vertically without changing the angle (mirror / reverse)
// TODO: rotateClockwise(): Takes the bitmapData from the given source FlxSprite and rotates it 90 degrees clockwise

/**
 * Some handy functions for <code>FlxSprite</code>s manipulation.
*/
class FlxSpriteUtil
{
	/**
	 * Useful helper objects for doing Flash-specific rendering.
	 * Primarily used for "debug visuals" like drawing bounding boxes directly to the screen buffer.
	 */
	static public var flashGfxSprite(default, null):Sprite = new Sprite();
	static public var flashGfx(default, null):Graphics = flashGfxSprite.graphics;
	
	/**
	 * Takes two source images (typically from Embedded bitmaps) and puts the resulting image into the output FlxSprite.<br>
	 * Note: It assumes the source and mask are the same size. Different sizes may result in undesired results.<br>
	 * It works by copying the source image (your picture) into the output sprite. Then it removes all areas of it that do not<br>
	 * have an alpha color value in the mask image. So if you draw a big black circle in your mask with a transparent edge, you'll<br>
	 * get a circular image appear. Look at the mask PNG files in the assets/pics folder for examples.
	 * 
	 * @param	source		The source image. Typically the one with the image / picture / texture in it.
	 * @param	mask		The mask to apply. Remember the non-alpha zero areas are the parts that will display.
	 * @param	output		The FlxSprite you wish the resulting image to be placed in (will adjust width/height of image)
	 * @return	The output FlxSprite for those that like chaining
	 */
	static public function alphaMask(source:Dynamic, mask:Dynamic, output:FlxSprite):FlxSprite
	{
		var data:BitmapData = null;
		if (Std.is(source, String))
		{
			data = FlxAssets.getBitmapData(source);
		}
		else if (Std.is(source, Class))
		{
			data = Type.createInstance(source, []).bitmapData;
		}
		else if (Std.is(source, BitmapData))
		{
			data = cast(source, BitmapData).clone();
		}
		else
		{
			return null;
		}
		var maskData:BitmapData = null;
		if (Std.is(mask, String))
		{
			maskData = FlxAssets.getBitmapData(mask);
		}
		else if (Std.is(mask, Class))
		{
			maskData = Type.createInstance(mask, []).bitmapData;
		}
		else if (Std.is(mask, BitmapData))
		{
			maskData = mask;
		}
		else
		{
			return null;
		}
		
		data.copyChannel(maskData, new Rectangle(0, 0, data.width, data.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		
		output.pixels = data;
		
		return output;
	}
	
	/**
	 * Takes the image data from two FlxSprites and puts the resulting image into the output FlxSprite.<br>
	 * Note: It assumes the source and mask are the same size. Different sizes may result in undesired results.<br>
	 * It works by copying the source image (your picture) into the output sprite. Then it removes all areas of it that do not<br>
	 * have an alpha color value in the mask image. So if you draw a big black circle in your mask with a transparent edge, you'll<br>
	 * get a circular image appear. Look at the mask PNG files in the assets/pics folder for examples.
	 * 
	 * @param	Sprite		The source <code>FlxSprite</code>. Typically the one with the image / picture / texture in it.
	 * @param	mask		The FlxSprite containing the mask to apply. Remember the non-alpha zero areas are the parts that will display.
	 * @param	output		The FlxSprite you wish the resulting image to be placed in (will adjust width/height of image)
	 * @return	The output FlxSprite for those that like chaining
	 */
	static public function alphaMaskFlxSprite(sprite:FlxSprite, mask:FlxSprite, output:FlxSprite):FlxSprite
	{
		var data:BitmapData = sprite.pixels;
		
		data.copyChannel(mask.pixels, new Rectangle(0, 0, sprite.width, sprite.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		
		output.pixels = data;
		
		return output;
	}
	
	/**
	 * Takes the image data from two FlxSprites and draws one on top of the other.<br>
	 * Note: It assumes the source and mask are the same size. Different sizes may result in undesired results.<br>
	 * 
	 * @param	BottomSprite	The <code>FlxSprite</code> that you want to draw onto.
	 * @param	TopSprite		The <code>FlxSprite</code> that will be copied onto the BottomSprite.
	 * @return	The output FlxSprite for those that like chainging.
	 */
	static public function mergeFlxSprite(BottomSprite:FlxSprite, TopSprite:FlxSprite):FlxSprite
	{
		var data:BitmapData = BottomSprite.pixels;
		
		data.copyPixels(TopSprite.pixels, new Rectangle(0, 0, BottomSprite.width, BottomSprite.height), new Point());
		
		return data;
	}
	
	/**
	 * Checks the x/y coordinates of the source FlxSprite and keeps them within the area of 0, 0, FlxG.width, FlxG.height (i.e. wraps it around the screen)
	 * 
	 * @param	Sprite		The <code>FlxSprite</code> to keep within the screen
	 * @param	Left		Whether to activate screen wrapping on the left side of the screen
	 * @param	Right		Whether to activate screen wrapping on the right side of the screen
	 * @param	Top			Whether to activate screen wrapping on the top of the screen
	 * @param	Bottom		Whether to activate screen wrapping on the bottom of the screen
	 */
	static public function screenWrap(sprite:FlxSprite, Left:Bool = true, Right:Bool = true, Top:Bool = true, Bottom:Bool = true):Void
	{
		if (Left && sprite.x < 0)
		{
			sprite.x = FlxG.width;
		}
		else if (Right && sprite.x > FlxG.width)
		{
			sprite.x = 0;
		}
		
		if (Top && sprite.y < 0)
		{
			sprite.y = FlxG.height;
		}
		else if (Bottom && sprite.y > FlxG.height)
		{
			sprite.y = 0;
		}
	}
	
	/**
	 * Aligns a set of FlxSprites so there is equal spacing between them
	 * 
	 * @param	sprites				An Array of FlxSprites
	 * @param	startX				The base X coordinate to start the spacing from
	 * @param	startY				The base Y coordinate to start the spacing from
	 * @param	horizontalSpacing	The amount of pixels between each sprite horizontally (default 0)
	 * @param	verticalSpacing		The amount of pixels between each sprite vertically (default 0)
	 * @param	spaceFromBounds		If set to true the h/v spacing values will be added to the width/height of the sprite, if false it will ignore this
	 */
	static public function space(sprites:Array<FlxSprite>, startX:Int, startY:Int, horizontalSpacing:Int = 0, verticalSpacing:Int = 0, spaceFromBounds:Bool = false):Void
	{
		var prevWidth:Int = 0;
		var prevHeight:Int = 0;
		
		for (i in 0...(sprites.length))
		{
			var sprite:FlxSprite = sprites[i];
			
			if (spaceFromBounds)
			{
				sprite.x = startX + prevWidth + (i * horizontalSpacing);
				sprite.y = startY + prevHeight + (i * verticalSpacing);
			}
			else
			{
				sprite.x = startX + (i * horizontalSpacing);
				sprite.y = startY + (i * verticalSpacing);
			}
		}
	}
	
	/**
	 * Centers the given FlxSprite on the screen, either by the X axis, Y axis, or both
	 * 
	 * @param	Sprite			The <code>FlxSprite<code> to center
	 * @param	Horizontally	Boolean true if you want it centered horizontally
	 * @param	Vertically		Boolean	true if you want it centered vertically
	 * @return	The FlxSprite for chaining
	 */
	static public function screenCenter(sprite:FlxSprite, xAxis:Bool = true, yAxis:Bool = true):FlxSprite
	{
		if (xAxis)
		{
			sprite.x = (FlxG.width / 2) - (sprite.width / 2);
		}
		
		if (yAxis)
		{
			sprite.y = (FlxG.height / 2) - (sprite.height / 2);
		}
		
		return sprite;
	}
	
	/**
	 * This function draws a line on a sprite from position X1,Y1
	 * to position X2,Y2 with the specified color.
	 * 
	 * @param	Sprite		The <code>FlxSprite</code> to manipulate
	 * @param	StartX		X coordinate of the line's start point.
	 * @param	StartY		Y coordinate of the line's start point.
	 * @param	EndX		X coordinate of the line's end point.
	 * @param	EndY		Y coordinate of the line's end point.
	 * @param	Color		The line's color.
	 * @param	Thickness	How thick the line is in pixels (default value is 1).
	 */
	static public function drawLine(sprite:FlxSprite, StartX:Float, StartY:Float, EndX:Float, EndY:Float, Color:Int, Thickness:Int = 1):Void
	{
		// Draw line
		var gfx:Graphics = flashGfx;
		gfx.clear();
		gfx.moveTo(StartX, StartY);
		var alphaComponent:Float = ((Color >> 24) & 255) / 255;
		
		if (alphaComponent < 0)
		{
			alphaComponent = 0;
		}
		
		gfx.lineStyle(Thickness, Color, alphaComponent);
		gfx.lineTo(EndX, EndY);
		
		updateSpriteGraphic(sprite);
	}
	
	/**
	 * This function draws a rectangle on a sprite.
	 * 
	 * @param	Sprite		The <code>FlxSprite</code> to manipulate
	 * @param	X			X coordinate of the rectangle's start point.
	 * @param	Y			Y coordinate of the rectangle's start point.
	 * @param	Width		Width of the rectangle
	 * @param	Height		Height of the rectangle
	 * @param	Color		The rectangle's color.
	 */
	static public function drawRect(sprite:FlxSprite, X:Float, Y:Float, Width:Float, Height:Float, Color:Int):Void
	{
		flashGfx.clear();
		flashGfx.beginFill(FlxColorUtil.RGBAtoRGB(Color));
		flashGfx.drawRect(X, Y, Width, Height);
		flashGfx.endFill();
		
		updateSpriteGraphic(sprite);
	}
	
	/**
	 * This function draws a rounded rectangle on a sprite.
	 * 
	 * @param	Sprite			The <code>FlxSprite</code> to manipulate
	 * @param	X				X coordinate of the rectangle's start point.
	 * @param	Y				Y coordinate of the rectangle's start point.
	 * @param	Width			Width of the rectangle
	 * @param	Height			Height of the rectangle
	 * @param	EllipseWidth	The width of the ellipse used to draw the rounded corners
	 * @param	EllipseHeight	The height of the ellipse used to draw the rounded corners
	 * @param	Color			The rectangle's color.
	 */
	static public function drawRoundRect(sprite:FlxSprite, X:Float, Y:Float, Width:Float, Height:Float, EllipseWidth:Float, EllipseHeight:Float, Color:Int):Void
	{
		flashGfx.clear();
		flashGfx.beginFill(FlxColorUtil.RGBAtoRGB(Color));
		flashGfx.drawRoundRect(X, Y, Width, Height, EllipseWidth, EllipseHeight);
		flashGfx.endFill();
		
		updateSpriteGraphic(sprite);
	}
	
	#if flash
	/**
	 * This function draws a rounded rectangle on a sprite. Same as <code>drawRoundRect</code>,
	 * except it allows you to determine the radius of each corner individually.
	 * 
	 * @param	Sprite				The <code>FlxSprite</code> to manipulate
	 * @param	X					X coordinate of the rectangle's start point.
	 * @param	Y					Y coordinate of the rectangle's start point.
	 * @param	Width				Width of the rectangle
	 * @param	Height				Height of the rectangle
	 * @param	TopLeftRadius		The radius of the top left corner of the rectangle
	 * @param	TopRightRadius		The radius of the top right corner of the rectangle
	 * @param	BottomLeftRadius	The radius of the bottom left corner of the rectangle
	 * @param	BottomRightRadius	The radius of the bottom right corner of the rectangle
	 * @param	Color				The rectangle's color.
	 */
	static public function drawRoundRectComplex(sprite:FlxSprite, X:Float, Y:Float, Width:Float, Height:Float, TopLeftRadius:Float, TopRightRadius:Float, BottomLeftRadius:Float, BottomRightRadius:Float, Color:Int):Void
	{
		flashGfx.clear();
		flashGfx.beginFill(FlxColorUtil.RGBAtoRGB(Color));
		flashGfx.drawRoundRectComplex(X, Y, Width, Height, TopLeftRadius, TopRightRadius, BottomLeftRadius, BottomRightRadius);
		flashGfx.endFill();
		
		updateSpriteGraphic(sprite);
	}
	#end
	
	/**
	 * This function draws a circle on this sprite at position X,Y
	 * with the specified color.
	 * 
	 * @param	Sprite	The <code>FlxSprite</code> to manipulate
	 * @param 	X 		X coordinate of the circle's center
	 * @param 	Y 		Y coordinate of the circle's center
	 * @param 	Radius 	Radius of the circle
	 * @param 	Color 	Color of the circle
	*/
	static public function drawCircle(sprite:FlxSprite, X:Float, Y:Float, Radius:Float, Color:Int):Void
	{
		flashGfx.clear();
		flashGfx.beginFill(FlxColorUtil.RGBAtoRGB(Color));
		flashGfx.drawCircle(X, Y, Radius);
		flashGfx.endFill();
		
		updateSpriteGraphic(sprite);
	}
	
	/**
	 * This function draws an ellipse on a sprite.
	 * 
	 * @param	Sprite		The <code>FlxSprite</code> to manipulate
	 * @param	X			X coordinate of the ellipse's start point.
	 * @param	Y			Y coordinate of the ellipse's start point.
	 * @param	Width		Width of the ellipse
	 * @param	Height		Height of the ellipse
	 * @param	Color		The ellipse's color.
	 */
	static public function drawEllipse(sprite:FlxSprite, X:Float, Y:Float, Width:Float, Height:Float, Color:Int):Void
	{
		flashGfx.clear();
		flashGfx.beginFill(FlxColorUtil.RGBAtoRGB(Color));
		flashGfx.drawEllipse(X, Y, Width, Height);
		flashGfx.endFill();
		
		updateSpriteGraphic(sprite);
	}
	
	/**
	 * Just a helper function that is called at the end of the draw functions
	 * to handle a few things related to updating a sprite's graphic.
	 * 
	 * @param	Sprite	The <code>FlxSprite</code> to manipulate
	 */
	static public function updateSpriteGraphic(sprite:FlxSprite):Void
	{
		sprite.pixels.draw(flashGfxSprite);
		sprite.dirty = true;
		sprite.resetFrameBitmapDatas();
	}
	
	/**
	 * Fills this sprite's graphic with a specific color.
	 * 
	 * @param	Sprite	The <code>FlxSprite</code> to manipulate
	 * @param	Color	The color with which to fill the graphic, format 0xAARRGGBB.
	 */
	static public function fill(sprite:FlxSprite, Color:Int):Void
	{
		sprite.pixels.fillRect(sprite.pixels.rect, Color);
		
		if (sprite.pixels != sprite.framePixels)
		{
			sprite.dirty = true;
		}
		
		sprite.resetFrameBitmapDatas();
	}
	
	/**
	 * A simple flicker effect for sprites achieved by toggling visibility.
	 * 
	 * @param	Object				The sprite.
	 * @param	Duration			How long to flicker for.
	 * @param	Interval			In what interval to toggle visibility. Set to <code>FlxG.elapsed</code> if <= 0!
	 * @param	EndVisibility		Force the visible value when the flicker completes, useful with fast repetitive use.
	 * @param	ForceRestart		Force the flicker to restart from beginnig, discarding the flickering effect already in progress if there is one.
	 * @param	?CompletionCallback	An optional callback that will be triggered when a flickering has finished.
	 * @param	?ProgressCallback	An optional callback that will be triggered when visibility is toggled.
	 */
	inline static public function flicker(Object:FlxObject, Duration:Float = 1, Interval:Float = 0.04, EndVisibility:Bool = true, ForceRestart:Bool = true, ?CompletionCallback:FlxFlicker->Void, ?ProgressCallback:FlxFlicker->Void):Void
	{
		FlxFlicker.flicker(Object, Duration, Interval, EndVisibility, ForceRestart, CompletionCallback, ProgressCallback);
	}
	
	/**
	 * Returns whether an object is flickering or not.
	 * @param  Object The object to check if is flickering.
	 */
	inline static public function isFlickering(Object:FlxObject):Bool
	{
		return FlxFlicker.isFlickering(Object);
	}
	
	/**
	* Stops flickering of the object. Also it will make the object visible.
	* @param  Object The object to stop flickering.
	*/
	inline static public function stopFlickering(Object:FlxObject):Void
	{
		FlxFlicker.stopFlickering(Object);
	}
}
