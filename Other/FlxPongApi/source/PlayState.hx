package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.effects.particles.FlxEmitter;

class PlayState extends FlxState
{
	private var _player:PongSprite;
	private var _playerBullets:Emitter;
	private var _enemy:PongSprite;
	private var _enemyBullets:Emitter;
	private var _obstacles:FlxGroup;
	
	override public function create():Void
	{
		Reg.CS = this;
		FlxG.cameras.bgColor = Reg.lite;
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.hide();
		#end
		
		_player = new PongSprite( 16, Std.int( ( FlxG.height - 16 ) / 2 ), 4, 16, Reg.med_dark );
		_playerBullets = new Emitter( Std.int( _player.x + _player.width ), Std.int( _player.y + _player.height / 2 ), 4 );
		_playerBullets.setXSpeed( 10, 100 );
		_playerBullets.setYSpeed( -1, 1 );
		_playerBullets.start( false );
		
		add( _playerBullets );
		add( _player );
		
		super.create();
	}
	
	override public function update():Void
	{
		_player.y = FlxG.mouse.y;
		_playerBullets.y = Std.int( _player.y + _player.height / 2 );
		
		if ( FlxG.mouse.pressed ) {
			//_playerBullets.emitParticle();
		}
		
		super.update();
	}	
}