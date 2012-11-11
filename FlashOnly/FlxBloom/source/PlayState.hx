package;
import flash.geom.Point;
import flash.geom.Rectangle;
import nme.display.BlendMode;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxParticle;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;

class PlayState extends FlxState
{
	public var toggle:Bool;
	
	private var _bloom:Int = 6;	//How much light bloom to have - larger numbers = more
	private var _fx:FlxSprite;		//Our helper sprite - basically a mini screen buffer (see below)
	
	//This is where everything gets set up for the game state
	override public function create():Void
	{
		//Title text, nothing crazy here!
		var text:FlxText;
		text = new FlxText(FlxG.width / 4, FlxG.height / 2 - 20, Math.floor(FlxG.width / 2), "FlxBloom", true);
		text.setFormat(null, 32, FlxG.WHITE, "center");
		add(text);
		text = new FlxText(FlxG.width / 4, FlxG.height / 2 + 20, Math.floor(FlxG.width / 2), "press space to toggle", true);
		text.setFormat(null, 16, FlxG.BLUE, "center");
		add(text);
		
		//This is the sprite we're going to use to help with the light bloom effect
		//First, we're going to initialize it to be a fraction of the screens size
		_fx = new FlxSprite();
		_fx.makeGraphic(Math.floor(FlxG.width / _bloom), Math.floor(FlxG.height / _bloom), 0, true);
		_fx.setOriginToCorner();	//Zero out the origin so scaling goes from top-left, not from center
		_fx.scale.x = _bloom;		//Scale it up to be the same size as the screen again
		_fx.scale.y = _bloom;		//Scale it up to be the same size as the screen again
		_fx.antialiasing = true;	//Set AA to true for maximum blurry
		_fx.blend = BlendMode.SCREEN;		//Set blend mode to "screen" to make the blurred copy transparent and brightening
		//Note that we do not add it to the game state!  It's just a helper, not a "real" sprite.
		
		//Then we scale the screen buffer down, so it draws a smaller version of itself
		// into our tiny FX buffer, which is already scaled up.  The net result of this operation
		// is a blurry image that we can render back over the screen buffer to create the bloom.
		FlxG.camera.screen.scale.x = 1/_bloom;
		FlxG.camera.screen.scale.y = 1/_bloom;
		
		//This is the particle emitter that spews things off the bottom of the screen.
		//I'm not going to go over it in too much detail here, but basically we
		// create the emitter, then we create 50 16x16 sprites and add them to it.
		var particles:Int = 50;
		var emitter:FlxEmitter = new FlxEmitter(0, FlxG.height + 8, particles);
		emitter.width = FlxG.width;
		emitter.y = FlxG.height + 20;
		emitter.gravity = -40;
		emitter.setXSpeed(-20,20);
		emitter.setYSpeed(-75,-25);
		var particle:FlxParticle;
		var colors:Array<Int> = [FlxG.BLUE, (FlxG.BLUE | FlxG.GREEN), FlxG.GREEN, (FlxG.GREEN | FlxG.RED), FlxG.RED];
		for (i in 0...particles)
		{
			particle = new FlxParticle();
			particle.makeGraphic(32, 32, colors[Std.int(FlxG.random() * colors.length)]);
			particle.exists = false;
			emitter.add(particle);
		}
		emitter.start(false,0,0.1);
		add(emitter);
		
		//Allows users to toggle the effect on and off with the space bar. Effect starts on.
		toggle = true;
	}
	
	override public function update():Void
	{
		if(FlxG.keys.justPressed("SPACE"))
		{
			toggle = !toggle;
		}
			
		super.update();
	}
	
	//This is where we do the actual drawing logic for the game state
	override public function draw():Void
	{
		//This draws all the game objects
		super.draw();
		
		if(toggle)
		{
			//The actual blur process is quite simple now.
			//First we draw the contents of the screen onto the tiny FX buffer:
			_fx.stamp(FlxG.camera.screen);
			//Then we draw the scaled-up contents of the FX buffer back onto the screen:
			_fx.draw();
		}
	}
}