package;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxRandom;
import flixel.util.FlxSave;

class PlayState extends FlxState
{
	private var _player:Player;
	private var _bounceLeft:FlxSprite;
	private var _bounceRight:FlxSprite;
	private var _paddleLeft:Paddle;
	private var _paddleRight:Paddle;
	private var _spikeBottom:FlxSprite;
	private var _spikeTop:FlxSprite;
	private var _scoreDisplay:FlxText;
	private var _feathers:FlxEmitter;
	private var _highScore:FlxText;
	
	inline static private var SAVE_DATA:String = "FLAPPYBALT";
	
	override public function create():Void
	{
		super.create();
		
		// Keep a reference to this state in Reg for global access.
		
		Reg.PS = this;
		
		// Set background color identical to the bottom of the "city", so on tall screens there's not a big black bar at the bottom.
		
		FlxG.camera.bgColor = 0xff646A7D;
		
		// Hide the mouse.
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = false;
		#end
		
		// The background city.
		
		add(new FlxSprite(0, 0, "assets/bg.png"));
		
		// Current score.
		
		_scoreDisplay = new FlxText(0, 180, FlxG.width);
		_scoreDisplay.alignment = CENTER;
		_scoreDisplay.color = 0xff868696;
		add(_scoreDisplay);
		
		#if mobile
		_scoreDisplay.text = "Tap to start";
		#else
		_scoreDisplay.text = "Press Space to start";
		#end
		
		// Update all-time high score.
		
		Reg.highScore = loadScore();
		
		// Display high score.
		
		_highScore = new FlxText(0, 40, FlxG.width, "");
		_highScore.alignment = CENTER;
		_highScore.color = 0xff868696;
		add(_highScore);
		
		if (Reg.highScore > 0)
			_highScore.text = Std.string(Reg.highScore);
		
		// The left bounce panel. Drawn via code in Reg to fit screen height.
		
		_bounceLeft = new FlxSprite(1, 17);
		_bounceLeft.loadGraphic(Reg.getBounceImage(FlxG.height - 34), true, 4, FlxG.height - 34);
		_bounceLeft.animation.add("flash", [1,0], 8, false);
		add(_bounceLeft);
		
		// The right bounce panel.
		
		_bounceRight = new FlxSprite(FlxG.width - 5, 17);
		_bounceRight.loadGraphic(Reg.getBounceImage(FlxG.height - 34), true, 4, FlxG.height - 34);
		_bounceRight.animation.add("flash", [1,0], 8, false);
		add(_bounceRight);
		
		// The left spiky paddle
		
		_paddleLeft = new Paddle(6, FlxObject.RIGHT);
		add(_paddleLeft);
		
		// The right spiky paddle
		
		_paddleRight = new Paddle(FlxG.width-15, FlxObject.LEFT);
		add(_paddleRight);
		
		// Spikes at the bottom of the screen
		
		_spikeBottom = new FlxSprite(0, 0, "assets/spike.png");
		_spikeBottom.y = FlxG.height - _spikeBottom.height;
		add(_spikeBottom);
		
		// Spikes at the top of the screen. Rotated to reduce number of assets.
		
		_spikeTop = new FlxSprite(0, 0);
		_spikeTop.loadRotatedGraphic("assets/spike.png", 4);
		_spikeTop.angle = 180;
		_spikeTop.y = -72;
		add(_spikeTop);
		
		// The bird.
		
		_player = new Player();
		add(_player);
		
		// A simple emitter to make some feathers when the bird gets spiked.
		
		_feathers = new FlxEmitter();
		_feathers.loadParticles("assets/feather.png", 50, 32);
		_feathers.velocity.set( -10, -10, 10, 10);
		_feathers.acceleration.set(0, 10);
		add(_feathers);
	}
	
	override public function update(elapsed:Float):Void
	{
		if (FlxG.pixelPerfectOverlap(_player, _spikeBottom) || FlxG.pixelPerfectOverlap(_player, _spikeTop) 
				|| FlxG.pixelPerfectOverlap(_player, _paddleLeft) || FlxG.pixelPerfectOverlap(_player, _paddleRight)) {
			_player.kill();
		} else if (_player.x < 5) {
			_player.x = 5;
			_player.velocity.x = -_player.velocity.x;
			_player.flipX = false;
			increaseScore();
			_bounceLeft.animation.play("flash");
			_paddleRight.randomize();
		} else if (_player.x + _player.width > FlxG.width - 5) {
			_player.x = FlxG.width - _player.width - 5;
			_player.velocity.x = -_player.velocity.x;
			_player.flipX = true;
			increaseScore();
			_bounceRight.animation.play("flash");
			_paddleLeft.randomize();
		}
		
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.justPressed.E && (FlxG.keys.pressed.CONTROL || FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.ALT))
		{
			clearSave();
			FlxG.resetState();
		}
		#end
		
		super.update(elapsed);
	}
	
	public function launchFeathers(X:Float, Y:Float, Amount:Int):Void
	{
		_feathers.x = X;
		_feathers.y = Y;
		_feathers.start(true, 0, Amount);
	}
	
	public function randomPaddleY():Int
	{
		return FlxG.random.int(Std.int(_bounceLeft.y), Std.int(_bounceLeft.y + _bounceLeft.height - _paddleLeft.height));
	}
	
	private function increaseScore():Void
	{
		Reg.score++;
		_scoreDisplay.text = Std.string(Reg.score);
		_scoreDisplay.size = 24;
	}
	
	/**
	 * Resets the state to its initial position without having to call FlxG.resetState().
	 */
	public function reset()
	{
		_paddleLeft.y = FlxG.height;
		_paddleRight.y = FlxG.height;
		_player.flipX = false;
		Reg.score = 0;
		_scoreDisplay.text = "";
		Reg.highScore = loadScore();
		
		if (Reg.highScore > 0)
			_highScore.text = Std.string(Reg.highScore);
	}
	
	/**
	 * Safely store a new high score into the saved session, if possible.
	 */
	static public function saveScore():Void
	{
		Reg.save = new FlxSave();
		
		if (Reg.save.bind(SAVE_DATA))
		{
			if ((Reg.save.data.score == null) || (Reg.save.data.score < Reg.score))
				Reg.save.data.score = Reg.score;
		}
		
		// Have to do this in order for saves to work on native targets!
		
		Reg.save.flush();
	}
	
	/**
	 * Load data from the saved session.
	 * 
	 * @return	The total points of the saved high score.
	 */
	static public function loadScore():Int
	{
		Reg.save = new FlxSave();
		
		if (Reg.save.bind(SAVE_DATA))
		{
			if ((Reg.save.data != null) && (Reg.save.data.score != null))
				return Reg.save.data.score;
		}
		
		return 0;
	}
	
	/**
	 * Wipe save data.
	 */
	static public function clearSave():Void
	{
		Reg.save = new FlxSave();
		
		if (Reg.save.bind(SAVE_DATA))
			Reg.save.erase();
	}
}