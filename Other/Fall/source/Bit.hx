package;

import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;

class Bit extends FlxSprite
{
	private var _initialPoint:FlxPoint;
	
	private var _weight:Int = 0;
	private var _direction:Int = 1;
	private var _movement:Float = 0.0;
	
	/**
	 * This is a generic sprite class extended by Branch, Leaf, and Wisp, since they share so many functions in common.
	 * Always 1px by 1px.
	 * 
	 * @param	X
	 * @param	Y
	 * @param	Weight
	 * @param	Color
	 */
	public function new( X:Int, Y:Int, Weight:Int, Color:Int )
	{
		super( X, Y );
		makeGraphic( 1, 1, Color );
		_weight = Weight;
		reset( X, Y );
	}
	
	override public function reset( X:Float, Y:Float )
	{
		super.reset( X, Y );
		_initialPoint = new FlxPoint( X, Y );
	}
	
	public function push( Force:Float )
	{
		_movement = Math.abs( Force ) - _weight;
		_direction = ( Force < 0 ) ? -1 : 1;
	}
	
	public var weight(get, null):Int;
	
	private function get_weight():Int
	{
		return _weight;
	}
}