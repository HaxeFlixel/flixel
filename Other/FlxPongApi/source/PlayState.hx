package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

class PlayState extends FlxState
{
	private var _player:FlxSprite;
	private var _playerBullets:FlxEmitter;
	
	override public function create():Void
	{
		FlxG.cameras.bgColor = Reg.LITE;
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.hide();
		#end
		
		_player = new FlxSprite( 10, Reg.halfHeight );
		_player.makeGraphic( 10, 10, Reg.DARK );
		
		_playerBullets = new FlxEmitter( _player.x + _player.width, _player.y + Std.int( _player.y / 2 ), 100 );
		var bullet:FlxSprite = new FlxSprite(0, 0);
		bullet.makeGraphic( 2, 2, Reg.MED_DARK );
		_playerBullets.makeParticles( bullet, 100 );
		
		add( _player );
		
		super.create();
	}
	
	override public function update():Void
	{
		_player.y = FlxG.mouse.y;
		
		if ( FlxG.mouse.pressed ) {
			_playerBullets.emitParticle();
		}
		
		super.update();
	}	
}