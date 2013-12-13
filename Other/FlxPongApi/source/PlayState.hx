package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.effects.particles.FlxEmitter;
import flixel.util.FlxCollision;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	private var _player:Player;
	private var _debris:Emitter;
	private var _enemy:Enemy;
	private var _enemyBullets:Emitter;
	public var ball:Ball;
	private var _obstacles:FlxTypedGroup<PongSprite>;
	private var _centerText:FlxText;
	public var emitterGroup:FlxTypedGroup<Emitter>;
	public var collidables:FlxGroup;
	
	override public function create():Void
	{
		Reg.PS = this;
		FlxG.cameras.bgColor = Reg.lite;
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.hide();
		#end
		
		_debris = new Emitter(FlxG.width, 0, 2, Reg.med_lite );
		_debris.height = FlxG.height;
		_debris.setXSpeed( Reg.level * -10, Reg.level * -1 );
		_debris.setYSpeed( -10, 10 );
		
		_player = new Player();
		
		_enemy = new Enemy();
		
		ball = new Ball();
		
		emitterGroup = new FlxTypedGroup<Emitter>( 5 );
		_obstacles = new FlxTypedGroup<PongSprite>( 10 );
		newObstacle();
		
		_centerText = new FlxText( 0, 0, FlxG.width, "" );
		_centerText.alignment = "center";
		_centerText.color = Reg.med_dark;
		_centerText.y = Std.int( ( FlxG.height - _centerText.height ) / 2 );
		
		add( _debris );
		add( emitterGroup );
		add( _player );
		add( _enemy );
		add( ball );
		add( _obstacles );
		add( _centerText );
		
		collidables = new FlxGroup();
		
		var walls:FlxGroup = FlxCollision.createCameraWall( FlxG.camera, FlxCollision.CAMERA_WALL_OUTSIDE, 5 );
		
		collidables.add( _player );
		collidables.add( _enemy );
		collidables.add( _obstacles );
		collidables.add( walls );
		
		_debris.start( false );
		
		super.create();
	}
	
	override public function update():Void
	{
		_player.y = FlxMath.bound( FlxG.mouse.y, 0, FlxG.height - _player.height );
		
		if ( ball.alive ) {
			if ( ball.x > FlxG.width ) {
				ball.kill();
				_enemy.kill();
				Reg.level++;
				_centerText.text = "Nice! Moving on to level " + Reg.level + "!";
				FlxTimer.start( 4, newEnemy, 1 );
			}
			
			if ( ball.x < 0 ) {
				ball.kill();
				_player.kill();
				_centerText.text = "Aww! You lost. You got as far as level " + Reg.level + " though, so there's that.";
				FlxTimer.start( 4, endGame, 1 );
			}
			
			FlxG.collide( _obstacles, ball );
			FlxG.collide( _obstacles, _player );
		}
		
		super.update();
	}
	
	public function newEnemy( f:FlxTimer ):Void
	{
		_centerText.text = "";
		_debris.setXSpeed( Reg.level * -10, Reg.level * -1 );
		_enemy.reset(0,0);
		ball.reset( FlxG.width / 2, FlxG.height / 2 );
		ball.velocity = new FlxPoint( -64, -64 );
		newObstacle();
	}
	
	public function newObstacle():Void
	{
		var obs:PongSprite = _obstacles.recycle( PongSprite, [ FlxG.width, FlxRandom.intRanged( 0, FlxG.height ), FlxRandom.intRanged( 1, 20 ), FlxRandom.intRanged( 4, 40 ), Reg.med_dark ] );
		obs.velocity.x = FlxRandom.floatRanged( -100, -1 );
		obs.velocity.y = FlxRandom.floatRanged( -10, 10 );
	}
	
	private function endGame( f:FlxTimer ):Void
	{
		FlxG.switchState( new MenuState() );
	}
}