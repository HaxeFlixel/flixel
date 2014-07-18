package;

import flash.display.BlendMode;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxRandom;

class PlayState extends FlxState
{
	/**
	 * Allows users to toggle the effect on and off with the space bar.
	 */
	private var _enabled:Bool = true;
	/**
	 * How much light bloom to have - larger numbers = more
	 */
	private var _bloom:Int = 10;
	/**
	 * Our helper sprite - basically a mini screen buffer (see below)
	 */
	private var _fx:FlxSprite;
	
	/**
	 * This is where everything gets set up for the game state
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		#if !flash
		FlxG.log.error("FlxBloom is only supported on Flash target for now.");
		#else
		// Title text, nothing crazy here!
		var text:FlxText;
		text = new FlxText(FlxG.width / 4, FlxG.height / 2 - 20, Math.floor(FlxG.width / 2), "FlxBloom");
		text.setFormat(null, 32, FlxColor.WHITE, CENTER);
		add(text);
		
		text = new FlxText(FlxG.width / 4, FlxG.height / 2 + 20, Math.floor(FlxG.width / 2), "press space to toggle");
		text.setFormat(null, 16, FlxColor.BLUE, CENTER);
		add(text);
		
		// This is the sprite we're going to use to help with the light bloom effect
		// First, we're going to initialize it to be a fraction of the screens size
		_fx = new FlxSprite();
		_fx.makeGraphic(Math.floor(FlxG.width / _bloom), Math.floor(FlxG.height / _bloom), 0, true);
		// Zero out the origin so scaling goes from top-left, not from center
		_fx.origin.set();
		// Scale it up to be the same size as the screen again
		_fx.scale.set(_bloom, _bloom);
		// Set AA to true for maximum blurry
		_fx.antialiasing = true;
		// Set blend mode to "screen" to make the blurred copy transparent and brightening
		_fx.blend = BlendMode.SCREEN;
		// Note that we do not add it to the game state!  It's just a helper, not a "real" sprite.
		
		// Then we scale the screen buffer down, so it draws a smaller version of itself
		// into our tiny FX buffer, which is already scaled up.  The net result of this operation
		// is a blurry image that we can render back over the screen buffer to create the bloom.
		FlxG.camera.screen.scale.set(1 / _bloom, 1 / _bloom);
		
		// This is the particle emitter that spews things off the bottom of the screen.
		// I'm not going to go over it in too much detail here, but basically we
		// create the emitter, then we create 50 16x16 sprites and add them to it.
		var particles:Int = 50;
		var emitter:FlxEmitter = new FlxEmitter(0, FlxG.height + 8, particles);
		emitter.width = FlxG.width;
		emitter.y = FlxG.height + 20;
		emitter.acceleration.set(0, -40);
		emitter.velocity.set( -20, -75, 20, -25);
		var particle:FlxParticle;
		var colors:Array<Int> = [FlxColor.BLUE, (FlxColor.BLUE | FlxColor.GREEN), FlxColor.GREEN, (FlxColor.GREEN | FlxColor.RED), FlxColor.RED];
		
		for (i in 0...particles)
		{
			particle = new FlxParticle();
			particle.makeGraphic(32, 32, colors[Std.int(FlxG.random.float() * colors.length)]);
			particle.exists = false;
			emitter.add(particle);
		}
		
		emitter.start(false, 0.1);
		add(emitter);
		#end
	}
	
	override public function update():Void
	{
		if (FlxG.keys.justPressed.SPACE)
		{
			_enabled = !_enabled;
		}
		
		super.update();
	}
	
	/**
	 * This is where we do the actual drawing logic for the game state
	 */ 
	override public function draw():Void
	{
		// This draws all the game objects
		super.draw();
		#if flash
		if (_enabled)
		{
			//The actual blur process is quite simple now.
			//First we draw the contents of the screen onto the tiny FX buffer:
			_fx.stamp(FlxG.camera.screen);
			//Then we draw the scaled-up contents of the FX buffer back onto the screen:
			_fx.draw();
		}
		#end
	}
}