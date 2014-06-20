package;

import flixel.addons.effects.FlxTrailArea;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;

class ParticleState extends FlxState
{
	public static inline var PARTICLE_AMOUNT:Int = 100;
	
	private var _emitter:FlxEmitter;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Sets up the FlxTrail area on the top left of the screen with an area over the whole black part of the screen
		var trailArea = new FlxTrailArea(0, 0, FlxG.width - 200, FlxG.height);
		
		// Sets up the emitter for the particle explosion
		_emitter = new FlxEmitter(200, FlxG.height / 2, PARTICLE_AMOUNT);
		_emitter.color.set(0xff0000, 0x00ff00);
		
		var particle:FlxParticle;
		for (i in 0...PARTICLE_AMOUNT)
		{
			particle = new FlxParticle();
			particle.makeGraphic(5, 5);
			_emitter.add(particle);
			
			// This adds all the particles to the FlxTrailArea so they get a trail effect
			trailArea.add(particle);
		}
		
		// Add the different elements in correct order
		add(trailArea);
		add(_emitter);
		add(new GUI(trailArea, startEmitter));
		
		// Start the emitter with a small delay to avoid the initial laggieness on startup
		new FlxTimer(0.5, function(_) { 
			_emitter.start(true, 0.5); 
		});
		
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		_emitter = FlxDestroyUtil.destroy(_emitter);
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		
		// This starts the emitter at the mouse position
		if (FlxG.mouse.x <= (FlxG.width - GUI.WIDTH)) 
		{
			startEmitter();
		}
		
		// Toggle states
		if (FlxG.keys.justReleased.SPACE) {
			FlxG.switchState(new BlurState());
		}
	}	
	
	/**
	 * Helper function to start the emtitter. Called from the FlxSliders!
	 */
	private inline function startEmitter(?Value:Null<Float>):Void
	{
		// Prevent emitter from restarting when using a slider before releasing the mouse
		if (FlxG.mouse.justPressed) 
		{
			// If this was called from a FlxSlider, we set the position to the screen center
			if (Value != null) {
				_emitter.x = 200;
				_emitter.y = FlxG.height / 2;
			}
			else {
				_emitter.x = FlxG.mouse.x;
				_emitter.y = FlxG.mouse.y;
			}
			
			_emitter.start(true);
		}
	}
}