package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;

class Branch extends Bit
{
	/**
	 * A "branch" is a 1px by 1px part of a tree.
	 * 
	 * @param	X		The X position for this "branch".
	 * @param	Y		The Y position for this "branch".
	 * @param	Weight	The weight of this "branch". Assigned in the PlayState; trunk branches are much heavier.
	 */
	public function new( X:Int, Y:Int, Weight:Int )
	{
		super( X, Y, Weight, FlxColor.BLACK );
		solid = true;
		moves = true;
		immovable = false;
	}
	
	override public function push( Force:Float ):Void
	{
		super.push( Force );
		
		if ( _movement > 0 && FlxRandom.chanceRoll( 10 ) )
		{
			if ( Math.ceil( _movement / 2 ) <= 2 )
			{
				x = _initialPoint.x + ( _direction * Math.ceil( _movement / 2 ) );
			}
			else
			{
				x = ( _initialPoint.x + 2 ) * _direction;
			}
		}
		else
		{
			x = _initialPoint.x;
			y = _initialPoint.y;
		}
	}
}