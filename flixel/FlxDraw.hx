package flixel;

import flixel.util.FlxColor;
import openfl.geom.Point;

/**
 * Class for drawing shapes on GPU.
 * Almost all code is written by Matt Tuttle (https://github.com/MattTuttle) for HaxePunk engine, and I only adapted it for flixel.
 * @author Matt Tuttle
 * @author Zaphod
 */
class FlxDraw extends FlxStrip
{
	private static var aa:Point = new Point();
	private static var bb:Point = new Point();
	private static var a:Point = new Point();
	private static var b:Point = new Point();
	private static var c:Point = new Point(); // current
	private static var u:Point = new Point();
	private static var v:Point = new Point();
	private static var prev:Point = new Point();
	private static var next:Point = new Point();
	private static var delta:Point = new Point();
	
	public var fillColor:FlxColor = FlxColor.WHITE;
	
	public var lineColor:FlxColor = FlxColor.WHITE;
	
	public var lineThickness:Float = 1.0;
	
	public function new(?X:Float = 0, ?Y:Float = 0, numVertices:Int = 4092, numIndices:Int = 4092)
	{
		super(X, Y);
		
		data.setMaxVertices(numVertices);
		data.setMaxIndices(numIndices);
	}
	
	/**
	 * Set line style for next API calls
	 * 
	 * @param	color		color of the line
	 * @param	thickness	thickness of the line
	 */
	public function lineStyle(color:FlxColor = FlxColor.WHITE, thickness:Float = 1.0):Void
	{
		lineColor = color;
		lineThickness = thickness;
	}

	/**
	 * Draws a line between two points.
	 * 
	 * @param	x1			Starting x position.
	 * @param	y1			Starting y position.
	 * @param	x2			Ending x position.
	 * @param	y2			Ending y position.
	 */
	public function drawLine(x1:Float, y1:Float, x2:Float, y2:Float)
	{
		// create perpendicular delta vector
		var dx:Float = -(x2 - x1);
		var dy:Float = y2 - y1;
		var length = Math.sqrt(dx * dx + dy * dy);
		
		if (length == 0) 
			return;
		
		// normalize line and set delta to half thickness
		var ht:Float = 0.5 * lineThickness;
		var tx:Float = dx;
		dx = (dy / length) * ht;
		dy = (tx / length) * ht;
		
		drawQuad(
			x1 + dx, y1 + dy,
			x1 - dx, y1 - dy,
			x2 - dx, y2 - dy,
			x2 + dx, y2 + dy,
			lineColor
		);
	}

	/**
	 * Draws a triangulated line polygon to the screen. This must be a closed loop of concave lines
	 * @param	points		An array of floats containing the points of the polygon. The array is ordered in x, y format and must have an even number of values.
	 */
	public function drawPolygon(points:Array<Float>)
	{
		if (points.length < 4 || (points.length % 2) == 1)
			throw "Invalid number of points. Expected an even number greater than 4.";

		var ht:Float = lineThickness / 2;
		var last:Int = points.length >> 1;
		
		for (i in 0...last)
		{
			var index = i * 2;
			
			c.x = points[index];
			c.y = points[index + 1];
			
			// vector u (difference between last and current)
			u.x = c.x - wrap(points, index - 2);
			u.y = c.y - wrap(points, index - 1);
			
			// vector v (difference between current and next)
			v.x = c.x - wrap(points, index + 2);
			v.y = c.y - wrap(points, index + 3);
			
			delta.setTo(u.x + v.x, u.y + v.y);
			delta.normalize(ht);
			
			u.setTo(c.x + delta.x, c.y + delta.y);
			v.setTo(c.x - delta.x, c.y - delta.y);
			
			if ((u.x * v.x) + (u.y * v.y) < 0)
			{
				delta.x = -delta.x;
				delta.y = -delta.y;
			}
			
			if (i == 0)
			{
				aa.copyFrom(u);
				bb.copyFrom(v);
			}
			else
			{
				drawQuad(
					a.x, a.y, b.x, b.y,
					v.x, v.y, u.x, u.y,
					lineColor
				);
			}
			
			a.copyFrom(u);
			b.copyFrom(v);
		}
		
		drawQuad(
			a.x, a.y, b.x, b.y,
			bb.x, bb.y, aa.x, aa.y,
			lineColor
		);
	}

	/**
	 * Draws a rectangle outline. Lines are drawn inside the width and height.
	 * 
	 * @param	x			X position of the rectangle.
	 * @param	y			Y position of the rectangle.
	 * @param	width		Width of the rectangle.
	 * @param	height		Height of the rectangle.
	 */
	public function drawRect(x:Float, y:Float, width:Float, height:Float)
	{
		var x2:Float = x + width;
		var y2:Float = y + height;
		drawPolygon([x, y, x2, y, x2, y2, x, y2]);
	}

	/**
	 * Draws rectangle filled with `fillColor`.
	 * 
	 * @param	x			X position of the rectangle.
	 * @param	y			Y position of the rectangle.
	 * @param	width		Width of the rectangle.
	 * @param	height		Height of the rectangle.
	 */
	public function fillRect(x:Float, y:Float, width:Float, height:Float)
	{
		drawQuad(
			x, y,
			x + width, y,
			x + width, y + height,
			x, y + height,
			fillColor
		);
	}

	/**
	 * Draws a circle to the screen.
	 * 
	 * @param	x			X position of the circle's center.
	 * @param	y			Y position of the circle's center.
	 * @param	radius		Radius of the circle.
	 * @param	segments	Increasing will smooth the circle but takes longer to render. Must be a value greater than zero.
	 */
	public inline function drawCircle(x:Float, y:Float, radius:Float, segments:Int = 25)
	{
		drawArc(x, y, radius, 0, 2 * Math.PI, segments);
	}

	/**
	 * Draws circle filled with `fillColor`.
	 * 
	 * @param	x			X position of the circle's center.
	 * @param	y			Y position of the circle's center.
	 * @param	radius		Radius of the circle.
	 * @param	segments	Increasing will smooth the circle but takes longer to render. Must be a value greater than zero.
	 */
	public function fillCircle(x:Float, y:Float, radius:Float, segments:Int = 25)
	{
		var radians:Float = (2 * Math.PI) / segments;
		var x1:Float = x;
		var y1:Float = y + radius;
		
		for (segment in 1...(segments + 1))
		{
			var theta:Float = segment * radians;
			var x2:Float = x + radius * Math.sin(theta);
			var y2:Float = y + radius * Math.cos(theta);
			
			data.start();
			data.addVertex(x, y, 0, 0, fillColor);
			data.addVertex(x1, y1, 0, 0, fillColor);
			data.addVertex(x2, y2, 0, 0, fillColor);
			data.addTriangle(0, 1, 2);
			
			x1 = x2;
			y1 = y2;
		}
	}

	/**
	 * Draws an arc to the screen.
	 * 
	 * @param	x			X position of the circle's center.
	 * @param	y			Y position of the circle's center.
	 * @param	radius		Radius of the circle.
	 * @param	start		The starting angle in radians.
	 * @param	angle		The arc size in radians.
	 * @param	segments	Increasing will smooth the circle but takes longer to render. Must be a value greater than zero.
	 */
	public function drawArc(x:Float, y:Float, radius:Float, start:Float, angle:Float, segments:Int = 25)
	{
		var radians:Float = angle / segments;
		var points:Array<Float> = [];
		
		for (segment in 0...segments)
		{
			var theta:Float = segment * radians + start;
			points.push(x + radius * Math.sin(theta));
			points.push(y + radius * Math.cos(theta));
		}
		
		drawPolygon(points);
	}
	
	/**
	 * Draws a quadratic curve.
	 * @param	x1			X start.
	 * @param	y1			Y start.
	 * @param	x2			X control point, used to determine the curve.
	 * @param	y2			Y control point, used to determine the curve.
	 * @param	x3			X finish.
	 * @param	y3			Y finish.
	 * @param	segments	Increasing will smooth the curve but takes longer to render. Must be a value greater than zero.
	 */
	public function drawCurve(x1:Float, y1:Float, x2:Float, y2:Int, x3:Float, y3:Float, segments:Int = 25)
	{
		var points:Array<Float> = [];
		points.push(x1);
		points.push(y1);
		
		var deltaT:Float = 1 / segments;
		
		for (segment in 1...segments)
		{
			var t:Float = segment * deltaT;
			var x:Float = (1 - t) * (1 - t) * x1 + 2 * t * (1 - t) * x2 + t * t * x3;
			var y:Float = (1 - t) * (1 - t) * y1 + 2 * t * (1 - t) * y2 + t * t * y3;
			points.push(x);
			points.push(y);
		}
		
		points.push(x3);
		points.push(y3);
		
		drawPolyline(points);
	}
	
	/**
	 * Draws a cubic curve.
	 * @param	x1			X start.
	 * @param	y1			Y start.
	 * @param	x2			X of the first control point, used to determine the curve.
	 * @param	y2			Y of the first control point, used to determine the curve.
	 * @param	x3			X of the second control point, used to determine the curve.
	 * @param	y3			X of the second control point, used to determine the curve.
	 * @param	x4			X finish.
	 * @param	y4			Y finish.
	 * @param	segments	Increasing will smooth the curve but takes longer to render. Must be a value greater than zero.
	 */
	public function drawCubicCurve(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, x4:Float, y4:Float, segments:Int = 25)
	{
		var points:Array<Float> = [];
		points.push(x1);
		points.push(y1);
		
		var deltaT:Float = 1 / segments;
		
		for (segment in 1...segments)
		{
			var t:Float = segment * deltaT;
			var invT:Float = (1.0 - t);
			var x:Float = invT * invT * invT * x1 + 3 * invT * invT * t * x2 + 3 * invT * t * t * x3 + t * t * t * x4;
			var y:Float = invT * invT * invT * y1 + 3 * invT * invT * t * y2 + 3 * invT * t * t * y3 + t * t * t * y4;
			points.push(x);
			points.push(y);
		}
		
		points.push(x4);
		points.push(y4);
		
		drawPolyline(points);
	}
	
	/**
	 * Draws a triangulated polyline to the screen.
	 * @param	points		An array of floats containing the points of the polygon. The array is ordered in x, y format and must have an even number of values.
	 */
	public function drawPolyline(points:Array<Float>)
	{
		if (points.length < 4 || (points.length % 2) == 1)
			throw "Invalid number of points. Expected an even number greater than 4.";
		
		var numPoints:Int = points.length >> 1;
		prev.setTo(points[0], points[1]);
		var ht:Float = lineThickness / 2;
		
		for (i in 0...numPoints)
		{
			var index:Int = i * 2;
			
			c.x = points[index];
			c.y = points[index + 1];
			
			if (i < numPoints - 1)
			{
				next.x = points[index + 2];
				next.y = points[index + 3];
			}
			else
			{
				next.copyFrom(c);
			}
			
			delta.y = -(next.x - prev.x);
			delta.x = next.y - prev.y;
			delta.normalize(ht);
			
			if (i != 0)
			{
				u.x = c.x - delta.x;
				u.y = c.y - delta.y;
				v.x = c.x + delta.x;
				v.y = c.y + delta.y;
				
				drawQuad(	
					a.x, a.y,
					b.x, b.y,
					u.x, u.y,
					v.x, v.y,
					lineColor);
			}
			
			a.x = c.x + delta.x;
			a.y = c.y + delta.y;
			b.x = c.x - delta.x;
			b.y = c.y - delta.y;
			
			prev.copyFrom(c);
		}
	}

	/**
	 * Draws quad filled with `fillColor`
	 */
	public function drawQuad(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float, x4:Float, y4:Float, color:FlxColor)
	{
		data.start();
		
		data.addVertex(x1, y1, 0.0, 0.0, color);
		data.addVertex(x2, y2, 0.0, 0.0, color);
		data.addVertex(x3, y3, 0.0, 0.0, color);
		data.addVertex(x4, y4, 0.0, 0.0, color);
		
		data.addTriangle(0, 1, 2);
		data.addTriangle(0, 2, 3);
	}

	/** @private Helper function that wraps an index around the list limits */
	static inline function wrap<T>(list:Array<T>, index:Int):T
	{
		return list[index < 0 ? list.length + index : index % list.length];
	}
}