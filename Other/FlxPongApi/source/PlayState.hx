package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.effects.particles.FlxEmitter;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	private var _player:PongSprite;
	private var _debris:Emitter;
	private var _enemy:PongSprite;
	private var _enemyBullets:Emitter;
	private var _ball:PongSprite;
	private var _obstacles:FlxGroup;
	
	override public function create():Void
	{
		Reg.CS = this;
		FlxG.cameras.bgColor = Reg.lite;
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.hide();
		#end
		
		_debris = new Emitter(FlxG.width, 0, 2, Reg.med_lite );
		_debris.height = FlxG.height;
		_debris.setXSpeed( -100, -40 );
		_debris.setYSpeed( -10, 10 );
		
		_player = new PongSprite( 16, Std.int( ( FlxG.height - 16 ) / 2 ), 4, 16, Reg.dark );
		
		_enemy = new PongSprite( FlxG.width - 16, Std.int( ( FlxG.height - 16 ) / 2 ), 4, 16, Reg.dark );
		
		_ball = new PongSprite( Std.int( _enemy.x - 4 ), Std.int( _enemy.y - 6 ), 4, 4, Reg.dark );
		_ball.velocity = new FlxPoint( -64, -64 );
		
		add( _debris );
		add( _player );
		add( _enemy );
		add( _ball );
		
		_debris.start( false );
		
		super.create();
	}
	
	override public function update():Void
	{
		_player.y = FlxMath.bound( FlxG.mouse.y, 0, FlxG.height - _player.height );
		
		if ( _ball.y < 0 ) {
			_ball.y = 0;
			_ball.velocity.y = -_ball.velocity.y;
		}
		
		if ( _ball.y > FlxG.height - _ball.height ) {
			_ball.y = FlxG.height - _ball.height;
			_ball.velocity.y = -_ball.velocity.y;
		}
		
		if ( _ball.x > FlxG.width ) {
			var win:FlxText = new FlxText( 0, 0, FlxG.width, "You win!" );
			win.alignment = "center";
			win.color = Reg.med_dark;
			win.y = Std.int( ( FlxG.height - win.height ) / 2 );
			add( win );
			FlxTimer.start( 4, endGame, 1 );
		}
		
		if ( _ball.x < 0 ) {
			var lose:FlxText = new FlxText( 0, 0, FlxG.width, "You lose!" );
			lose.alignment = "center";
			lose.color = Reg.med_dark;
			lose.y = Std.int( ( FlxG.height - lose.height ) / 2 );
			add( lose );
			FlxTimer.start( 4, endGame, 1 );
		}
		
		FlxG.overlap( _player, _ball, paddleBounce );
		
		super.update();
	}
	
	private function paddleBounce( a:Dynamic, b:Dynamic ):Void
	{
		_ball.velocity.x = -_ball.velocity.x;
		_ball.x ++;
	}
	
	public function createToast( ReturnMap:Dynamic ):Void
	{
		// here
	}
	
	private function endGame( f:FlxTimer ):Void
	{
		Reg.genColors();
		FlxG.switchState( new MenuState() );
	}
}