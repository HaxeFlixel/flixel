package flixel.ui;

import flixel.FlxStrip;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * Circular progress bar.
 * It is assumed that graphic of this object have equal width and height.
 * @author Zaphod
 */
class FlxCircularBar extends FlxStrip 
{
	/**
	 * Progress indicator.
	 * Accepts values between 0.0 and 1.0.
	 * If the value is outside this range, then it will be clamped.
	 */
	public var percent(default, set):Float = 0;
	
	/**
	 * Start angle of progress bar in degrees.
	 * Must be multiplicative of 90.
	 */
	public var startAngle(default, set):Int = 180;
	
	/**
	 * Fill direction of progress bar.
	 * If `true` then progress bar will be filled counter clockwise.
	 */
	public var ccw(default, set):Bool = false;
	
	public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y, SimpleGraphic);
	}
	
	private function regenData():Void
	{
		if (graphic == null || data == null)
			return;
		
		data.clear();
		
		if (percent <= 0)
			return;
		
		var size:Float = graphic.width;
		var halfSize:Float = 0.5 * size;
		var radius:Float = halfSize * Math.sqrt(2) / 2;
		
		var total:Float = (Math.PI * 2) * percent;
		var oct:Float = Math.PI / 4;
		
		var numSectors:Int = Math.ceil(total / oct);
		
		var start:Float = 0.0;
		var numTriangles:Int = 0;
		
		var dir:Int = (ccw) ? 1 : -1;
		var startOffset:Float = startAngle / 180 * Math.PI;
		total *= dir;
		
		var x:Float, y:Float, u:Float, v:Float;
		var x1:Float, y1:Float;
		
		for (i in 0...numSectors)
		{
			var angle:Float = Math.PI / 4;
			angle *= dir;
			
			if (i == (numSectors - 1))
				angle = total - start;
			
			x1 = radius * Math.sin(start + startOffset);
			y1 = radius * Math.cos(start + startOffset);
			
			var scale:Float = halfSize / Math.max(Math.abs(x1), Math.abs(y1));
			
			x = x1 * scale + halfSize;
			y = y1 * scale + halfSize;
			var u:Float = x / size;
			var v:Float = y / size;
			data.addVertex(x, y, u, v);
			
			x = halfSize;
			y = halfSize;
			u = 0.5;
			v = 0.5;
			data.addVertex(x, y, u, v);
			
			x1 = radius * Math.sin(start + startOffset + angle);
			y1 = radius * Math.cos(start + startOffset + angle);
			
			scale = halfSize / Math.max(Math.abs(x1), Math.abs(y1));
			
			x = x1 * scale + halfSize;
			y = y1 * scale + halfSize;
			u = x / size;
			v = y / size;
			data.addVertex(x, y, u, v);
			
			data.addTriangle(numTriangles * 3, numTriangles * 3 + 1, numTriangles * 3 + 2);
			
			numTriangles++;
			start += angle;
		}
	}
	
	override function set_graphic(value:FlxGraphic):FlxGraphic 
	{
		super.set_graphic(value);
		regenData();
		return value;
	}
	
	private function set_percent(value:Float):Float
	{
		value *= 100;
		value %= 100;
		value /= 100;
		percent = value;
		regenData();
		return value;
	}
	
	private function set_startAngle(value:Int):Int
	{
		value = Std.int(value / 90) * 90;
		startAngle = value;
		regenData();
		return value;
	}
	
	private function set_ccw(value:Bool):Bool
	{
		ccw = value;
		regenData();
		return value;
	}
}