package flixel.math;
import flash.geom.Matrix;

/**
 * Helper class for making fast matrix calculations for rendering.
 * It mostly copies Matrix class, but with some additions for
 * faster rotation by 90 degrees.
 */
class FlxMatrix extends Matrix
{
	/**
	 * Helper object, which you can use without instantiation of
	 * additional objects.
	 */
	public static var matrix:FlxMatrix = new FlxMatrix();
	
	public function new(a:Float = 1, b:Float = 0, c:Float = 0, d:Float = 1, tx:Float = 0, ty:Float = 0)
	{
		super(a, b, c, d, tx, ty);
	}
	
	/**
	 * Rotates this matrix, but takes the values of sine and cosine,
	 * so it might be useful when you rotate multiple matrices by the same angle
	 * @param	cos	The cosine value for rotation angle
	 * @param	sin	The sine value for rotation angle
	 * @return	this transformed matrix
	 */
	public inline function rotateWithTrig(cos:Float, sin:Float):FlxMatrix
	{
		var a1:Float = a * cos - b * sin;
		b = a * sin + b * cos;
		a = a1;
		
		var c1:Float = c * cos - d * sin;
		d = c * sin + d * cos;
		c = c1;
		
		var tx1:Float = tx * cos - ty * sin;
		ty = tx * sin + ty * cos;
		tx = tx1;
		
		return this;
	}
	
	/**
	 * Adds 90 degrees to rotation of this matrix
	 * @return	rotated matrix
	 */
	public inline function rotateByPositive90():FlxMatrix
	{
		this.setTo( -b, a, -d, c, -ty, tx);
		return this;
	}
	
	/**
	 * Substract 90 degrees from rotation of this matrix
	 * @return	rotated matrix
	 */
	public inline function rotateByNegative90():FlxMatrix
	{
		this.setTo(b, -a, d, -c, ty, -tx);
		return this;
	}
}