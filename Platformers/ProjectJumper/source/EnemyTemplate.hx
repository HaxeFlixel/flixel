package;

import flixel.FlxSprite;

/**
 * ...
 * @author David Bell
 */
class EnemyTemplate extends FlxSprite
{
	private var _player:Player;
	private var _startx:Float;
	private var _starty:Float;
	
	public function new(X:Float, Y:Float, ThePlayer:Player)
	{
		super(X, Y);
		
		_startx = X;
		_starty = Y;
		_player = ThePlayer;
	}
}
