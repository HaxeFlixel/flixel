package;

import flixel.FlxG;
import flixel.util.FlxRandom;

class Wisp extends Bit
{
	private var _lastDirection:Float = 0;
	private var _fading:Bool = false;
	
	public function new( X:Int, Y:Int )
	{
		super( X, Y, 0, 0xffFFFFFF );
		init( X, Y );
	}
	
	public function init( X:Int, Y:Int ):Void
	{
		super.reset( X, Y );
		
		alpha = FlxRandom.floatRanged( 0.1, 0.6 );
		_lastDirection = Reg.PS.wind;
		_fading = false;
	}
	
	override public function kill():Void
	{
		_fading = true;
	}
	
	override public function update():Void
	{
		if ( !alive || !exists )
		{
			return;
		}
		
		if ( _fading )
		{
			alpha -= 0.2;
			
			if ( alpha <= 0 )
			{
				alive = false;
				exists = false;
			}
		}
		else if ( Math.abs( Reg.PS.wind ) <= 3 )
		{
			kill();
		}
		else if ( _lastDirection < 0 && ( x < 0 || Reg.PS.wind >= 0 ) )
		{
			kill();
		}
		else if ( _lastDirection > 0 && ( x > FlxG.width || Reg.PS.wind <= 0 ) )
		{
			kill();
		}
		
		velocity.x = FlxRandom.floatRanged( Reg.PS.wind * 15, Reg.PS.wind * 25 );
		velocity.y = FlxRandom.floatRanged( Reg.PS.wind * -0.0125, Reg.PS.wind * 0.0125 );
		_lastDirection = Reg.PS.wind;
		
		super.update();
	}
}