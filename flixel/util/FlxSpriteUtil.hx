package flixel.util;

import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;
import openfl.display.BlendMode;
import openfl.display.CapsStyle;
import openfl.display.Graphics;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

// TODO: pad(): Pad the sprite out with empty pixels left/right/above/below it
// TODO: rotateClockwise(): Takes the bitmapData from the given source FlxSprite and rotates it 90 degrees clockwise

/**
 * Some handy functions for FlxSprite (FlxObject) manipulation, mostly drawing-related.
 * Note that stage quality impacts the results of the draw() functions -
 * use FlxG.stage.quality = openfl.display.StageQuality.BEST; for best results.
 */
class FlxSpriteUtil
{
	/**
	 * Useful helper objects for doing Flash-specific rendering.
	 * Primarily used for "debug visuals" like drawing bounding boxes directly to the screen buffer.
	 */
	public static var flashGfxSprite(default, null):Sprite = new Sprite();

	public static var flashGfx(default, null):Graphics = flashGfxSprite.graphics;

	/**
	 * Takes two source images (typically from Embedded bitmaps) and puts the resulting image into the output FlxSprite.
	 * Note: It assumes the source and mask are the same size. Different sizes may result in undesired results.
	 * It works by copying the source image (your picture) into the output sprite. Then it removes all areas of it that do not
	 * have an alpha color value in the mask image. So if you draw a big black circle in your mask with a transparent edge, you'll
	 * get a circular image to appear.
	 * May lead to unexpected results if `source` does not have an alpha channel.
	 *
	 * @param	output		The FlxSprite you wish the resulting image to be placed in (will adjust width/height of image)
	 * @param	source		The source image. Typically the one with the image / picture / texture in it.
	 * @param	mask		The mask to apply. Remember the non-alpha zero areas are the parts that will display.
	 * @return 	The FlxSprite for chaining
	 */
	public static function alphaMask(output:FlxSprite, source:FlxGraphicSource, mask:FlxGraphicSource):FlxSprite
	{
		var data:BitmapData = FlxAssets.resolveBitmapData(source);
		var maskData:BitmapData = FlxAssets.resolveBitmapData(mask);

		if (data == null || maskData == null)
		{
			return null;
		}

		data = data.clone();
		data.copyChannel(maskData, new Rectangle(0, 0, data.width, data.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		output.pixels = data;
		return output;
	}

	/**
	 * Takes the image data from two FlxSprites and puts the resulting image into the output FlxSprite.
	 * Note: It assumes the source and mask are the same size. Different sizes may result in undesired results.
	 * It works by copying the source image (your picture) into the output sprite. Then it removes all areas of it that do not
	 * have an alpha color value in the mask image. So if you draw a big black circle in your mask with a transparent edge, you'll
	 * get a circular image appear.
	 * May lead to unexpected results if `sprite`'s graphic does not have an alpha channel.
	 *
	 * @param	sprite		The source FlxSprite. Typically the one with the image / picture / texture in it.
	 * @param	mask		The FlxSprite containing the mask to apply. Remember the non-alpha zero areas are the parts that will display.
	 * @param	output		The FlxSprite you wish the resulting image to be placed in (will adjust width/height of image)
	 * @return 	The output FlxSprite for chaining
	 */
	public static function alphaMaskFlxSprite(sprite:FlxSprite, mask:FlxSprite, output:FlxSprite):FlxSprite
	{
		sprite.drawFrame();
		var data:BitmapData = sprite.pixels.clone();
		data.copyChannel(mask.pixels, new Rectangle(0, 0, sprite.width, sprite.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		output.pixels = data;
		return output;
	}

	/**
	 * Checks the x/y coordinates of the FlxSprite and keeps them within the
	 * area of 0, 0, FlxG.width, FlxG.height (i.e. wraps it around the screen)
	 *
	 * @param	sprite		The FlxSprite to keep within the screen
	 * @param	Left		Whether to activate screen wrapping on the left side of the screen
	 * @param	Right		Whether to activate screen wrapping on the right side of the screen
	 * @param	Top			Whether to activate screen wrapping on the top of the screen
	 * @param	Bottom		Whether to activate screen wrapping on the bottom of the screen
	 * @return	The FlxSprite for chaining
	 */
	public static function screenWrap(sprite:FlxSprite, Left:Bool = true, Right:Bool = true, Top:Bool = true, Bottom:Bool = true):FlxSprite
	{
		if (Left && ((sprite.x + sprite.frameWidth / 2) <= 0))
		{
			sprite.x = FlxG.width;
		}
		else if (Right && (sprite.x >= FlxG.width))
		{
			sprite.x = 0;
		}

		if (Top && ((sprite.y + sprite.frameHeight / 2) <= 0))
		{
			sprite.y = FlxG.height;
		}
		else if (Bottom && (sprite.y >= FlxG.height))
		{
			sprite.y = 0;
		}
		return sprite;
	}
	
	/**
	 * Makes sure a FlxSprite doesn't leave the specified area - most common use case is to call this every frame in update().
	 * If you call this without specifying an area, the game area (FlxG.width / height as max) will be used. Takes the graphic size into account.
	 *
	 * @param	sprite	The FlxSprite to bound to an area
	 * @param	MinX	The minimum x position allowed
	 * @param	MaxX	The maximum x position allowed
	 * @param	MinY	The minimum y position allowed
	 * @param	MaxY	The minimum y position allowed
	 * @return	The FlxSprite for chaining
	 */
	public static function bound(sprite:FlxSprite, MinX:Float = 0, MaxX:Float = 0, MinY:Float = 0, MaxY:Float = 0):FlxSprite
	{
		if (MaxX <= 0)
		{
			MaxX = FlxG.width;
		}
		if (MaxY <= 0)
		{
			MaxY = FlxG.height;
		}

		MaxX -= sprite.frameWidth;
		MaxY -= sprite.frameHeight;

		sprite.x = FlxMath.bound(sprite.x, MinX, MaxX);
		sprite.y = FlxMath.bound(sprite.y, MinY, MaxY);

		return sprite;
	}

	/**
	 * Checks the sprite's screen bounds of the FlxSprite and keeps them within the camera by wrapping it around.
	 *
	 * @param	sprite	The FlxSprite to wrap.
	 * @param	camera	The camera to wrap around. If left null, `FlxG.camera` is used.
	 * @param	edges	The edges FROM which to wrap. Use constants like `LEFT`, `RIGHT`, `UP|DOWN` or `ANY`.
	 * @return	The FlxSprite for chaining
	 * @since 4.11.0
	 */
	public static function cameraWrap(sprite:FlxSprite, ?camera:FlxCamera, edges:FlxDirectionFlags = ANY):FlxSprite
	{
		if (camera == null)
			camera = FlxG.camera;
		
		var spriteBounds = sprite.getScreenBounds(camera);
		var offset = FlxPoint.get(
			sprite.x - spriteBounds.x - camera.scroll.x,
			sprite.y - spriteBounds.y - camera.scroll.y
		);
		
		if (edges.has(LEFT) && spriteBounds.right < camera.viewMarginLeft)
			sprite.x = camera.viewRight + offset.x;
		else if (edges.has(RIGHT) && spriteBounds.left > camera.viewMarginRight)
			sprite.x = camera.viewLeft + offset.x - spriteBounds.width;
		
		if (edges.has(UP) && spriteBounds.bottom < camera.viewMarginTop)
			sprite.y = camera.viewBottom + offset.y;
		else if (edges.has(DOWN) && spriteBounds.top > camera.viewMarginBottom)
			sprite.y = camera.viewTop + offset.y - spriteBounds.height;
		
		spriteBounds.put();
		offset.put();
		
		return sprite;
	}
	
	/**
	 * Checks the sprite's screen bounds and keeps it entirely within the camera.
	 *
	 * @param	sprite	The FlxSprite to restrict.
	 * @param	camera	The camera resitricting the sprite. If left null, `FlxG.camera` is used.
	 * @param	edges	The edges to restrict. Use constants like `LEFT`, `RIGHT`, `UP|DOWN` or `ANY`.
	 * @return	The FlxSprite for chaining
	 * @since 4.11.0
	 */
	public static function cameraBound(sprite:FlxSprite, ?camera:FlxCamera, edges:FlxDirectionFlags = ANY):FlxSprite
	{
		if (camera == null)
			camera = FlxG.camera;
		
		var spriteBounds = sprite.getScreenBounds(camera);
		var offset = FlxPoint.get(
			sprite.x - spriteBounds.x - camera.scroll.x,
			sprite.y - spriteBounds.y - camera.scroll.y
		);
		
		if (edges.has(LEFT) && spriteBounds.left < camera.viewMarginLeft)
			sprite.x = camera.viewLeft + offset.x;
		else if (edges.has(RIGHT) && spriteBounds.right > camera.viewMarginRight)
			sprite.x = camera.viewRight + offset.x - spriteBounds.width;
		
		if (edges.has(UP) && spriteBounds.top < camera.viewMarginTop)
			sprite.y = camera.viewTop + offset.y;
		else if (edges.has(DOWN) && spriteBounds.bottom > camera.viewMarginBottom)
			sprite.y = camera.viewBottom + offset.y - spriteBounds.height;
		
		spriteBounds.put();
		offset.put();
		
		return sprite;
	}
	
	/**
	 * Aligns a set of FlxObjects so there is equal spacing between them
	 *
	 * @param	objects				An Array of FlxObjects
	 * @param	startX				The base X coordinate to start the spacing from
	 * @param	startY				The base Y coordinate to start the spacing from
	 * @param	horizontalSpacing	The amount of pixels between each sprite horizontally. Set to `null` to just keep the current X position of each object.
	 * @param	verticalSpacing		The amount of pixels between each sprite vertically. Set to `null` to just keep the current Y position of each object.
	 * @param	spaceFromBounds		If set to true the h/v spacing values will be added to the width/height of the sprite, if false it will ignore this
	 * @param	position			A function with the signature `(target:FlxObject, x:Float, y:Float):Void`. You can use this to tween objects into their spaced position, etc.
	 */
	public static function space(objects:Array<FlxObject>, startX:Float, startY:Float, ?horizontalSpacing:Float, ?verticalSpacing:Float,
			spaceFromBounds:Bool = false, ?position:FlxObject->Float->Float->Void):Void
	{
		var prevWidth:Float = 0;
		var runningX:Float = 0;

		if (horizontalSpacing != null)
		{
			if (spaceFromBounds)
			{
				prevWidth = objects[0].width;
			}
			runningX = startX;
		}
		else
		{
			runningX = objects[0].x;
		}

		var prevHeight:Float = 0;
		var runningY:Float = 0;

		if (verticalSpacing != null)
		{
			if (spaceFromBounds)
			{
				prevHeight = objects[0].height;
			}
			runningY = startY;
		}
		else
		{
			runningY = objects[0].y;
		}

		if (position != null)
		{
			position(objects[0], runningX, runningY);
		}
		else
		{
			objects[0].x = runningX;
			objects[0].y = runningY;
		}

		var curX:Float = 0;
		var curY:Float = 0;

		for (i in 1...objects.length)
		{
			var object = objects[i];

			if (horizontalSpacing != null)
			{
				curX = runningX + prevWidth + horizontalSpacing;
				runningX = curX;
			}
			else
			{
				curX = object.x;
			}

			if (verticalSpacing != null)
			{
				curY = runningY + prevHeight + verticalSpacing;
				runningY = curY;
			}
			else
			{
				curY = object.y;
			}

			if (position != null)
			{
				position(object, curX, curY);
			}
			else
			{
				object.x = curX;
				object.y = curY;
			}

			if (spaceFromBounds)
			{
				prevWidth = object.width;
				prevHeight = object.height;
			}
		}
	}

	/**
	 * This function draws a line on a FlxSprite from position X1,Y1
	 * to position X2,Y2 with the specified color.
	 *
	 * @param	sprite		The FlxSprite to manipulate
	 * @param	StartX		X coordinate of the line's start point.
	 * @param	StartY		Y coordinate of the line's start point.
	 * @param	EndX		X coordinate of the line's end point.
	 * @param	EndY		Y coordinate of the line's end point.
	 * @param	lineStyle	A LineStyle typedef containing the params of Graphics.lineStyle()
	 * @param	drawStyle	A DrawStyle typedef containing the params of BitmapData.draw()
	 * @return 	The FlxSprite for chaining
	 */
	public static function drawLine(sprite:FlxSprite, StartX:Float, StartY:Float, EndX:Float, EndY:Float, ?lineStyle:LineStyle, ?drawStyle:DrawStyle):FlxSprite
	{
		lineStyle = getDefaultLineStyle(lineStyle);
		beginDraw(0x0, lineStyle);
		flashGfx.moveTo(StartX, StartY);
		flashGfx.lineTo(EndX, EndY);
		endDraw(sprite, drawStyle);
		return sprite;
	}

	/**
	 * This function draws a curve on a FlxSprite from position X1,Y1
	 * to anchor position X2,Y2 using control points X3,Y3 with the specified color.
	 *
	 * @param	sprite		The FlxSprite to manipulate
	 * @param	StartX		X coordinate of the curve's start point.
	 * @param	StartY		Y coordinate of the curve's start point.
	 * @param	EndX		X coordinate of the curve's end/anchor point.
	 * @param	EndY		Y coordinate of the curve's end/anchor point.
	 * @param	ControlX	X coordinate of the curve's control point.
	 * @param	ControlY	Y coordinate of the curve's control point.
	 * @param	FillColor		The ARGB color to fill this curve with. FlxColor.TRANSPARENT (0x0) means no fill. Filling a curve draws a line from End to Start to complete the figure.
	 * @param	lineStyle	A LineStyle typedef containing the params of Graphics.lineStyle()
	 * @param	drawStyle	A DrawStyle typedef containing the params of BitmapData.draw()
	 * @return 	The FlxSprite for chaining
	 */
	public static function drawCurve(sprite:FlxSprite, StartX:Float, StartY:Float, EndX:Float, EndY:Float, ControlX:Float, ControlY:Float,
			FillColor:FlxColor = FlxColor.TRANSPARENT, ?lineStyle:LineStyle, ?drawStyle:DrawStyle):FlxSprite
	{
		lineStyle = getDefaultLineStyle(lineStyle);
		beginDraw(FillColor, lineStyle);
		flashGfx.moveTo(StartX, StartY);
		flashGfx.curveTo(EndX, EndY, ControlX, ControlY);
		endDraw(sprite, drawStyle);
		return sprite;
	}

	/**
	 * This function draws a rectangle on a FlxSprite.
	 *
	 * @param	sprite		The FlxSprite to manipulate
	 * @param	X			X coordinate of the rectangle's start point.
	 * @param	Y			Y coordinate of the rectangle's start point.
	 * @param	Width		Width of the rectangle
	 * @param	Height		Height of the rectangle
	 * @param	FillColor		The ARGB color to fill this rectangle with. FlxColor.TRANSPARENT (0x0) means no fill.
	 * @param	lineStyle	A LineStyle typedef containing the params of Graphics.lineStyle()
	 * @param	drawStyle	A DrawStyle typedef containing the params of BitmapData.draw()
	 * @return 	The FlxSprite for chaining
	 */
	public static function drawRect(sprite:FlxSprite, X:Float, Y:Float, Width:Float, Height:Float, FillColor:FlxColor = FlxColor.WHITE, ?lineStyle:LineStyle,
			?drawStyle:DrawStyle):FlxSprite
	{
		beginDraw(FillColor, lineStyle);
		flashGfx.drawRect(X, Y, Width, Height);
		endDraw(sprite, drawStyle);
		return sprite;
	}

	/**
	 * This function draws a rounded rectangle on a FlxSprite.
	 *
	 * @param	sprite			The FlxSprite to manipulate
	 * @param	X				X coordinate of the rectangle's start point.
	 * @param	Y				Y coordinate of the rectangle's start point.
	 * @param	Width			Width of the rectangle
	 * @param	Height			Height of the rectangle
	 * @param	EllipseWidth	The width of the ellipse used to draw the rounded corners
	 * @param	EllipseHeight	The height of the ellipse used to draw the rounded corners
	 * @param	FillColor			The ARGB color to fill this rectangle with. FlxColor.TRANSPARENT (0x0) means no fill.
	 * @param	lineStyle		A LineStyle typedef containing the params of Graphics.lineStyle()
	 * @param	drawStyle		A DrawStyle typedef containing the params of BitmapData.draw()
	 * @return 	The FlxSprite for chaining
	 */
	public static function drawRoundRect(sprite:FlxSprite, X:Float, Y:Float, Width:Float, Height:Float, EllipseWidth:Float, EllipseHeight:Float,
			FillColor:FlxColor = FlxColor.WHITE, ?lineStyle:LineStyle, ?drawStyle:DrawStyle):FlxSprite
	{
		beginDraw(FillColor, lineStyle);
		flashGfx.drawRoundRect(X, Y, Width, Height, EllipseWidth, EllipseHeight);
		endDraw(sprite, drawStyle);
		return sprite;
	}

	#if (flash || openfl >= "8.0.0")
	/**
	 * This function draws a rounded rectangle on a FlxSprite. Same as drawRoundRect,
	 * except it allows you to determine the radius of each corner individually.
	 *
	 * @param	sprite				The FlxSprite to manipulate
	 * @param	X					X coordinate of the rectangle's start point.
	 * @param	Y					Y coordinate of the rectangle's start point.
	 * @param	Width				Width of the rectangle
	 * @param	Height				Height of the rectangle
	 * @param	TopLeftRadius		The radius of the top left corner of the rectangle
	 * @param	TopRightRadius		The radius of the top right corner of the rectangle
	 * @param	BottomLeftRadius	The radius of the bottom left corner of the rectangle
	 * @param	BottomRightRadius	The radius of the bottom right corner of the rectangle
	 * @param	FillColor				The ARGB color to fill this rectangle with. FlxColor.TRANSPARENT (0x0) means no fill.
	 * @param	lineStyle			A LineStyle typedef containing the params of Graphics.lineStyle()
	 * @param	drawStyle			A DrawStyle typedef containing the params of BitmapData.draw()
	 * @return 	The FlxSprite for chaining
	 */
	public static function drawRoundRectComplex(sprite:FlxSprite, X:Float, Y:Float, Width:Float, Height:Float, TopLeftRadius:Float, TopRightRadius:Float,
			BottomLeftRadius:Float, BottomRightRadius:Float, FillColor:FlxColor = FlxColor.WHITE, ?lineStyle:LineStyle, ?drawStyle:DrawStyle):FlxSprite
	{
		beginDraw(FillColor, lineStyle);
		flashGfx.drawRoundRectComplex(X, Y, Width, Height, TopLeftRadius, TopRightRadius, BottomLeftRadius, BottomRightRadius);
		endDraw(sprite, drawStyle);
		return sprite;
	}
	#end

	/**
	 * This function draws a circle on a FlxSprite at position X,Y with the specified color.
	 *
	 * @param	sprite		The FlxSprite to manipulate
	 * @param	X 			X coordinate of the circle's center (automatically centered on the sprite if -1)
	 * @param	Y 			Y coordinate of the circle's center (automatically centered on the sprite if -1)
	 * @param	Radius 		Radius of the circle (makes sure the circle fully fits on the sprite's graphic if < 1, assuming and and y are centered)
	 * @param	FillColor 		The ARGB color to fill this circle with. FlxColor.TRANSPARENT (0x0) means no fill.
	 * @param	lineStyle	A LineStyle typedef containing the params of Graphics.lineStyle()
	 * @param	drawStyle	A DrawStyle typedef containing the params of BitmapData.draw()
	 * @return 	The FlxSprite for chaining
	 */
	public static function drawCircle(sprite:FlxSprite, X:Float = -1, Y:Float = -1, Radius:Float = -1, FillColor:FlxColor = FlxColor.WHITE,
			?lineStyle:LineStyle, ?drawStyle:DrawStyle):FlxSprite
	{
		if (X == -1 || Y == -1)
		{
			var midPoint = sprite.getGraphicMidpoint();

			if (X == -1)
				X = midPoint.x - sprite.x;
			if (Y == -1)
				Y = midPoint.y - sprite.y;

			midPoint.put();
		}

		if (Radius < 1)
		{
			var minVal = Math.min(sprite.frameWidth, sprite.frameHeight);
			Radius = (minVal / 2);
		}

		beginDraw(FillColor, lineStyle);
		flashGfx.drawCircle(X, Y, Radius);
		endDraw(sprite, drawStyle);
		return sprite;
	}

	/**
	 * This function draws an ellipse on a FlxSprite.
	 *
	 * @param	sprite		The FlxSprite to manipulate
	 * @param	X			X coordinate of the ellipse's start point.
	 * @param	Y			Y coordinate of the ellipse's start point.
	 * @param	Width		Width of the ellipse
	 * @param	Height		Height of the ellipse
	 * @param	FillColor		The ARGB color to fill this ellipse with. FlxColor.TRANSPARENT (0x0) means no fill.
	 * @param	lineStyle	A LineStyle typedef containing the params of Graphics.lineStyle()
	 * @param	drawStyle	A DrawStyle typedef containing the params of BitmapData.draw()
	 * @return 	The FlxSprite for chaining
	 */
	public static function drawEllipse(sprite:FlxSprite, X:Float, Y:Float, Width:Float, Height:Float, FillColor:FlxColor = FlxColor.WHITE,
			?lineStyle:LineStyle, ?drawStyle:DrawStyle):FlxSprite
	{
		beginDraw(FillColor, lineStyle);
		flashGfx.drawEllipse(X, Y, Width, Height);
		endDraw(sprite, drawStyle);
		return sprite;
	}

	/**
	 * This function draws a simple, equilateral triangle on a FlxSprite.
	 *
	 * @param	sprite		The FlxSprite to manipulate
	 * @param	X			X position of the triangle
	 * @param	Y			Y position of the triangle
	 * @param	Height		Height of the triangle
	 * @param	FillColor		The ARGB color to fill this triangle with. FlxColor.TRANSPARENT (0x0) means no fill.
	 * @param	lineStyle	A LineStyle typedef containing the params of Graphics.lineStyle()
	 * @param	drawStyle	A DrawStyle typedef containing the params of BitmapData.draw()
	 * @return 	The FlxSprite for chaining
	 */
	public static function drawTriangle(sprite:FlxSprite, X:Float, Y:Float, Height:Float, FillColor:FlxColor = FlxColor.WHITE, ?lineStyle:LineStyle,
			?drawStyle:DrawStyle):FlxSprite
	{
		beginDraw(FillColor, lineStyle);
		flashGfx.moveTo(X + Height / 2, Y);
		flashGfx.lineTo(X + Height, Height + Y);
		flashGfx.lineTo(X, Height + Y);
		flashGfx.lineTo(X + Height / 2, Y);
		endDraw(sprite, drawStyle);
		return sprite;
	}

	/**
	 * This function draws a polygon on a FlxSprite.
	 *
	 * @param	sprite		The FlxSprite to manipulate
	 * @param	Vertices	Array of Vertices to use for drawing the polygon
	 * @param	FillColor		The ARGB color to fill this polygon with. FlxColor.TRANSPARENT (0x0) means no fill.
	 * @param	lineStyle	A LineStyle typedef containing the params of Graphics.lineStyle()
	 * @param	drawStyle	A DrawStyle typedef containing the params of BitmapData.draw()
	 * @return 	The FlxSprite for chaining
	 */
	public static function drawPolygon(sprite:FlxSprite, Vertices:Array<FlxPoint>, FillColor:FlxColor = FlxColor.WHITE, ?lineStyle:LineStyle,
			?drawStyle:DrawStyle):FlxSprite
	{
		beginDraw(FillColor, lineStyle);
		var p:FlxPoint = Vertices.shift();
		flashGfx.moveTo(p.x, p.y);
		for (p in Vertices)
		{
			flashGfx.lineTo(p.x, p.y);
		}
		endDraw(sprite, drawStyle);
		Vertices.unshift(p);
		return sprite;
	}

	/**
	 * Helper function that the drawing functions use at the start to set the color and lineStyle.
	 *
	 * @param	FillColor		The ARGB color to use for drawing
	 * @param	lineStyle	A LineStyle typedef containing the params of Graphics.lineStyle()
	 */
	@:noUsing
	public static inline function beginDraw(FillColor:FlxColor, ?lineStyle:LineStyle):Void
	{
		flashGfx.clear();
		setLineStyle(lineStyle);

		if (FillColor != FlxColor.TRANSPARENT)
		{
			flashGfx.beginFill(FillColor.to24Bit(), FillColor.alphaFloat);
		}
	}

	/**
	 * Helper function that the drawing functions use at the end.
	 *
	 * @param	sprite		The FlxSprite to draw to
	 * @param	drawStyle	A DrawStyle typedef containing the params of BitmapData.draw()
	 * @return 	The FlxSprite for chaining
	 */
	public static inline function endDraw(sprite:FlxSprite, ?drawStyle:DrawStyle):FlxSprite
	{
		flashGfx.endFill();
		updateSpriteGraphic(sprite, drawStyle);
		return sprite;
	}

	/**
	 * Just a helper function that is called at the end of the draw functions
	 * to handle a few things related to updating a sprite's graphic.
	 *
	 * @param	Sprite		The FlxSprite to manipulate
	 * @param	drawStyle	A DrawStyle typedef containing the params of BitmapData.draw()
	 * @return 	The FlxSprite for chaining
	 */
	public static function updateSpriteGraphic(sprite:FlxSprite, ?drawStyle:DrawStyle):FlxSprite
	{
		if (drawStyle == null)
		{
			drawStyle = {smoothing: false};
		}
		else if (drawStyle.smoothing == null)
		{
			drawStyle.smoothing = false;
		}

		sprite.pixels.draw(flashGfxSprite, drawStyle.matrix, drawStyle.colorTransform, drawStyle.blendMode, drawStyle.clipRect, drawStyle.smoothing);
		sprite.dirty = true;
		return sprite;
	}

	/**
	 * Just a helper function that is called in the draw functions
	 * to set the lineStyle via Graphics.lineStyle()
	 *
	 * @param	lineStyle	The lineStyle typedef
	 */
	@:noUsing
	public static inline function setLineStyle(lineStyle:LineStyle):Void
	{
		if (lineStyle != null)
		{
			var color = (lineStyle.color == null) ? FlxColor.BLACK : lineStyle.color;

			if (lineStyle.thickness == null)
				lineStyle.thickness = 1;
			if (lineStyle.pixelHinting == null)
				lineStyle.pixelHinting = false;
			if (lineStyle.miterLimit == null)
				lineStyle.miterLimit = 3;

			flashGfx.lineStyle(lineStyle.thickness, color.to24Bit(), color.alphaFloat, lineStyle.pixelHinting, lineStyle.scaleMode, lineStyle.capsStyle,
				lineStyle.jointStyle, lineStyle.miterLimit);
		}
	}

	/**
	 * Helper function for the default line styles of drawLine() and drawCurve()
	 *
	 * @param   lineStyle   The lineStyle typedef
	 */
	public static inline function getDefaultLineStyle(?lineStyle:LineStyle):LineStyle
	{
		if (lineStyle == null)
			lineStyle = {thickness: 1, color: FlxColor.WHITE};
		if (lineStyle.thickness == null)
			lineStyle.thickness = 1;
		if (lineStyle.color == null)
			lineStyle.color = FlxColor.WHITE;

		return lineStyle;
	}

	/**
	 * Fills this sprite's graphic with a specific color.
	 *
	 * @param	Sprite	The FlxSprite to manipulate
	 * @param	FillColor	The color with which to fill the graphic, format 0xAARRGGBB.
	 * @return 	The FlxSprite for chaining
	 */
	public static function fill(sprite:FlxSprite, FillColor:FlxColor):FlxSprite
	{
		sprite.pixels.fillRect(sprite.pixels.rect, FillColor);

		if (sprite.pixels != sprite.framePixels)
		{
			sprite.dirty = true;
		}

		return sprite;
	}

	/**
	 * A simple flicker effect for sprites achieved by toggling visibility.
	 *
	 * @param	Object				The sprite.
	 * @param	Duration			How long to flicker for (in seconds). `0` means "forever".
	 * @param	Interval			In what interval to toggle visibility. Set to `FlxG.elapsed` if `<= 0`!
	 * @param	EndVisibility		Force the visible value when the flicker completes, useful with fast repetitive use.
	 * @param	ForceRestart		Force the flicker to restart from beginning, discarding the flickering effect already in progress if there is one.
	 * @param	CompletionCallback	An optional callback that will be triggered when a flickering has finished.
	 * @param	ProgressCallback	An optional callback that will be triggered when visibility is toggled.
	 * @return The FlxFlicker object. FlxFlickers are pooled internally, so beware of storing references.
	 */
	public static inline function flicker(Object:FlxObject, Duration:Float = 1, Interval:Float = 0.04, EndVisibility:Bool = true, ForceRestart:Bool = true,
			?CompletionCallback:FlxFlicker->Void, ?ProgressCallback:FlxFlicker->Void):FlxFlicker
	{
		return FlxFlicker.flicker(Object, Duration, Interval, EndVisibility, ForceRestart, CompletionCallback, ProgressCallback);
	}

	/**
	 * Returns whether an object is flickering or not.
	 *
	 * @param  Object 	The object to check against.
	 */
	public static inline function isFlickering(Object:FlxObject):Bool
	{
		return FlxFlicker.isFlickering(Object);
	}

	/**
	 * Stops flickering of the object. Also it will make the object visible.
	 *
	 * @param  Object 	The object to stop flickering.
	 * @return The FlxObject for chaining
	 */
	public static inline function stopFlickering(Object:FlxObject):FlxObject
	{
		FlxFlicker.stopFlickering(Object);
		return Object;
	}

	/**
	 * Fade in a sprite, tweening alpha to 1.
	 *
	 * @param  sprite 	The object to fade.
	 * @param  Duration How long the fade will take (in seconds).
	 * @return The FlxSprite for chaining
	 */
	public static inline function fadeIn(sprite:FlxSprite, Duration:Float = 1, ?ResetAlpha:Bool, ?OnComplete:TweenCallback):FlxSprite
	{
		if (ResetAlpha)
		{
			sprite.alpha = 0;
		}
		FlxTween.num(sprite.alpha, 1, Duration, {onComplete: OnComplete}, alphaTween.bind(sprite));
		return sprite;
	}

	/**
	 * Fade out a sprite, tweening alpha to 0.
	 *
	 * @param  sprite 	The object to fade.
	 * @param  Duration How long the fade will take (in seconds).
	 * @return The FlxSprite for chaining
	 */
	public static inline function fadeOut(sprite:FlxSprite, Duration:Float = 1, ?OnComplete:TweenCallback):FlxSprite
	{
		FlxTween.num(sprite.alpha, 0, Duration, {onComplete: OnComplete}, alphaTween.bind(sprite));
		return sprite;
	}

	static function alphaTween(sprite:FlxSprite, f:Float):Void
	{
		sprite.alpha = f;
	}
	
	/**
	 * Change's this sprite's color transform to apply a tint effect.
	 * Mimics Adobe Animate's "Tint" color effect
	 * 
	 * @param   tint  The color to tint the sprite, where alpha determines the strength
	 * 
	 * @since 5.4.0
	 */
	public static inline function setTint(sprite:FlxSprite, tint:FlxColor)
	{
		final strength = tint.alphaFloat;
		inline function scaleInt(i:Int):Int
		{
			return Math.round(i * strength);
		}
		
		final mult = 1 - strength;
		sprite.setColorTransform(mult, mult, mult, 1.0, scaleInt(tint.red), scaleInt(tint.green), scaleInt(tint.blue));
	}
	
	/**
	 * Uses `FlxTween.num` to call `setTint` on the target sprite
	 * 
	 * @param   tint        The color to tint the sprite, where alpha determines the max strength
	 * @param   duration    How long the flash lasts
	 * @param   func        Controls the amount of tint over time. The input float goes from 0 to
	 *                      1.0, an output of 1.0 means the tint is fully applied. If omitted,
	 *                      `(n)->1-n` is used, meaning it starts at full tint and fades away
	 * @param   onComplete  Called when the flash is complete
	 * 
	 * @since 5.4.0
	 */
	public static inline function flashTint(sprite:FlxSprite, tint = FlxColor.WHITE, duration = 0.5,
		?func:(Float)->Float, ?onComplete:()->Void)
	{
		final options:TweenOptions = onComplete != null ? { onComplete: (_)->onComplete} : null;
		if (func == null)
			func = (n)->1-FlxEase.circIn(n);// start at full, fade out
		
		var color = tint.rgb;
		final strength = tint.alphaFloat;
		FlxTween.num(0, 1, duration, options, function(n)
		{
			color.alphaFloat = strength * func(n);
			setTint(sprite, color);
		});
		
		return sprite;
	}
	
	/**
	 * Change's this sprite's color transform to brighten or darken it.
	 * Mimics Adobe Animate's "Brightness" color effect
	 * 
	 * @param   brightness  Use 1.0 to fully brighten, -1.0 to fully darken, or anything inbetween
	 * 
	 * @since 5.4.0
	 */
	public static inline function setBrightness(sprite:FlxSprite, brightness:Float)
	{
		final mult = 1.0 - Math.abs(brightness);
		final offset = Math.round(Math.max(0, 0xFF * brightness));
		sprite.setColorTransform(mult, mult, mult, 1.0, offset, offset, offset);
	}
}

typedef LineStyle =
{
	?thickness:Float,
	?color:FlxColor,
	?pixelHinting:Bool,
	?scaleMode:LineScaleMode,
	?capsStyle:CapsStyle,
	?jointStyle:JointStyle,
	?miterLimit:Float
}

typedef DrawStyle =
{
	?matrix:Matrix,
	?colorTransform:ColorTransform,
	?blendMode:BlendMode,
	?clipRect:Rectangle,
	?smoothing:Bool
}