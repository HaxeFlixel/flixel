package flixel.system.render.gl;

import flixel.graphics.FlxMaterial;
import flixel.math.FlxMatrix;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.Vector;
import openfl.display.DisplayObjectContainer;

// TODO: document this class...

/**
 * Display object for camera's debug layer. All debug rendering is done with this object.
 * @author Zaphod
 */
class GLDebugRenderer extends GLDisplayObject
{
	#if FLX_RENDER_GL
	private static var DefaultColorMaterial:FlxMaterial = new FlxMaterial();
	
	private var drawCommands:FlxDrawQuadsCommand = new FlxDrawQuadsCommand(false);
	
	public function new(width:Int, height:Int, context:GLContextHelper)
	{
		super(width, height, context);
	}
	
	override public function destroy():Void
	{
		super.destroy();
		drawCommands = FlxDestroyUtil.destroy(drawCommands);
	}
	
	override public function prepare():Void
	{
		drawCommands.prepare(projection, context, buffer);
		drawCommands.set(null, true, false, DefaultColorMaterial);
	}
	
	public function finish():Void
	{
		drawCommands.flush();
	}
	
	/**
	 * Draws a single pixel to the screen
	 * @param x      the x-axis value of the pixel
	 * @param y      the y-axis value of the pixel
	 * @param color  the color of the pixel
	 * @param size   the overall size of the pixel square
	 */
	public function pixel(x:Float, y:Float, color:FlxColor, size:Float = 1):Void
	{
		var hs = size / 2;
		fillRect(x - hs, y - hs, size, size, color);
	}
	
	/**
	 * Draws a circle to the screen
	 * @param x       the x-axis value of the circle
	 * @param y       the y-axis value of the circle
	 * @param radius  the radius of the circle
	 * @param color   the color of the circle
	 */
	public function circle(x:Float, y:Float, radius:Float, color:FlxColor, numSides:Int = 40):Void
	{
		var sides = numSides,
			angle = 0.0,
			angleStep = (Math.PI * 2) / sides,
			lastX = x + Math.cos(angle) * radius,
			lastY = y + Math.sin(angle) * radius,
			pointX:Float,
			pointY:Float;
		
		for (i in 0...sides)
		{
			angle += angleStep;
			pointX = x + Math.cos(angle) * radius;
			pointY = y + Math.sin(angle) * radius;
			line(lastX, lastY, pointX, pointY, color);
			lastX = pointX;
			lastY = pointY;
		}
	}

	/**
	 * Draws a non-filled rectangle to the screen
	 * @param x          the x-axis value of the rectangle
	 * @param y          the y-axis value of the rectangle
	 * @param width      the width of the rectangle
	 * @param height     the height of the rectangle
	 * @param color      the color of the rectangle
	 * @param thickness  the line thickness of the rectangle
	 */
	public function rect(x:Float, y:Float, width:Float, height:Float, color:FlxColor, thickness:Float = 1):Void
	{
		var ht = thickness / 2,
			x2 = x + width,
			y2 = y + height;
		// offset values to create an inline border
		line(x, y + ht, x2, y + ht, color, thickness);
		line(x2 - ht, y, x2 - ht, y2, color, thickness);
		line(x2, y2 - ht, x, y2 - ht, color, thickness);
		line(x + ht, y2, x + ht, y, color, thickness);
	}

	/**
	 * Draws a filled rectangle to the screen
	 * @param x       the x-axis value of the rectangle
	 * @param y       the y-axis value of the rectangle
	 * @param width   the width of the rectangle
	 * @param height  the height of the rectangle
	 * @param color   the color of the rectangle
	 */
	public function fillRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor):Void
	{
		drawCommands.startQuad(null, DefaultColorMaterial);
		drawCommands.addColoredVertex(x, y, color);
		drawCommands.addColoredVertex(x + width, y, color);
		drawCommands.addColoredVertex(x + width, y + height, color);
		drawCommands.addColoredVertex(x, y + height, color);
	}

	/**
	 * Draws a line to the screen
	 * @param x1         the first x-axis value of the line
	 * @param y1         the first y-axis value of the line
	 * @param x2         the second x-axis value of the line
	 * @param y2         the second y-axis value of the line
	 * @param color      the color of the line
	 * @param thickness  the thickness of the line
	 */
	public function line(x1:Float, y1:Float, x2:Float, y2:Float, color:FlxColor, thickness:Float = 1):Void
	{
		// create perpendicular delta vector
		var dx = -(x2 - x1);
		var dy = y2 - y1;
		var len = Math.sqrt(dx * dx + dy * dy);
		if (len == 0) return;
		// normalize line and set delta to half thickness
		var ht = thickness / 2;
		var tx = dx;
		dx = (dy / len) * ht;
		dy = (tx / len) * ht;
		
		drawCommands.startQuad(null, DefaultColorMaterial);
		drawCommands.addColoredVertex(x1 + dx, y1 + dy, color);
		drawCommands.addColoredVertex(x1 - dx, y1 - dy, color);
		drawCommands.addColoredVertex(x2 - dx, y2 - dy, color);
		drawCommands.addColoredVertex(x2 + dx, y2 + dy, color);
	}
	
	/**
	 * Draws a grid to the screen
	 * @param gx     x-axis value of the grid
	 * @param gy     y-axis value of the grid
	 * @param gw     width of the grid
	 * @param gh     height of the grid
	 * @param color  the color of the grid lines
	 */
	public function grid(gx:Float, gy:Float, gw:Float, gh:Float, cellX:Int, cellY:Int, color:FlxColor):Void
    {
        var offset = gx,
            step = gw / cellX; // horizontal offset
        for (i in 0...cellX+1)
        {
            line(offset, gy, offset, gy + gh, color);
            offset += step;
        }
        offset = gy; // vertical offset
        step = gh / cellY;
        for (i in 0...cellY+1)
        {
            line(gx, offset, gx + gw, offset, color);
            offset += step;
        }
    }
	
	public function triangles(matrix:FlxMatrix, vertices:Vector<Float>, indices:Vector<Int>, color:FlxColor, thickness:Float = 1):Void
	{
		var numTriangles = Std.int(indices.length / 3);
		
		var x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float;
		var xt1:Float, yt1:Float, xt2:Float, yt2:Float, xt3:Float, yt3:Float;
		var index1:Int, index2:Int, index3:Int;
		
		for (i in 0...numTriangles)
		{
			index1 = indices[3 * i];
			index2 = index1 + 1;
			index3 = index2 + 1;
			
			x1 = vertices[index1 * 2];
			y1 = vertices[index1 * 2 + 1];
			
			x2 = vertices[index2 * 2];
			y2 = vertices[index2 * 2 + 1];
			
			x3 = vertices[index3 * 2];
			y3 = vertices[index3 * 2 + 1];
			
			xt1 = matrix.transformX(x1, y1);
			yt1 = matrix.transformY(x1, y1);
			
			xt2 = matrix.transformX(x2, y2);
			yt2 = matrix.transformY(x2, y2);
			
			xt3 = matrix.transformX(x3, y3);
			yt3 = matrix.transformY(x3, y3);
			
			line(x1, y1, x2, y2, color, thickness);
			line(x2, y2, x3, y3, color, thickness);
			line(x1, y1, x3, y3, color, thickness);
		}
	}
	
	#else
	
	public function destroy():Void {}
	
	#end
}