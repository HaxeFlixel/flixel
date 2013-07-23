package;

import flixel.FlxG;
import flixel.FlxObject;

class TempoController extends FlxObject
{
	inline static public var SLOWEST_TIME:Float = 2;
	static public var timing:Float;
	
	public var beat:Dynamic;
	
	private var _gap:Float;
	private var _last:Float;
	private var _check:Float;
	
	public function new(Beat:Dynamic)
	{
		super();
		
		beat = Beat;
		_gap = _check = 0;
		_last = timing = 0.5;
	}
	
	override public function update():Void
	{
		_gap += FlxG.elapsed;
		
		if (FlxG.keys.justPressed("SPACE"))
		{
			if (_gap > SLOWEST_TIME)
			{
				_last = timing;
			}
			else
			{
				timing = (timing + _gap + _last) / 3;
				
				var bpm:Int = Std.int(60 / timing);
				bpm = Std.int((bpm + 2.5) / 5) * 5 + 3;
				timing = 60 / bpm;
				
				_last = _gap;
			}
			
			_gap = 0;
			_check = timing;
		}
		
		_check += FlxG.elapsed;
		
		if ((_check >= timing) || FlxG.keys.UP || FlxG.keys.DOWN || FlxG.keys.LEFT || FlxG.keys.RIGHT)
		{
			if (_check > 0)
			{
				_check -= timing;
			}
			
			beat();
		}
		
		if( FlxG.keys.justPressed("UP") ||
			FlxG.keys.justPressed("DOWN") ||
			FlxG.keys.justPressed("LEFT") ||
			FlxG.keys.justPressed("RIGHT") )
		{
			FlxG.cameras.flash(0xffffff, 0.2, null, true);
		}
		
		if (FlxG.keys.justPressed("ONE"))
		{
			timing *= 2;
		}
		if (FlxG.keys.justPressed("TWO"))
		{
			timing *= 0.5;
		}
	}
}