package;

import flixel.addons.effects.FlxTrailArea;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;

/**
 * The state showing a remake of the FlxBlur demo
 */
class BlurState extends FlxState 
{
	public static inline var PARTICLE_AMOUNT:Int = 50;
	
	override public function create():Void 
	{
		// The first thing to do is setting up the FlxTrailArea
		var trailArea = new FlxTrailArea(0, 0, FlxG.width - 200, FlxG.height);
		trailArea.antialiasing = true;
		
		// This just sets up an emitter at the bottom of the screen
		var emitter = new FlxEmitter(0, FlxG.height + 20, 50);
		emitter.width = FlxG.width - 200;
		emitter.acceleration.set(0, -40);
		emitter.velocity.set( -20, -75, 20, -25);
		
		var colors:Array<Int> = [FlxColor.BLUE, (FlxColor.BLUE | FlxColor.GREEN), 
								FlxColor.GREEN, (FlxColor.GREEN | FlxColor.RED), FlxColor.RED];
		var particle:FlxParticle;
		
		for (i in 0...PARTICLE_AMOUNT)
		{
			particle = new FlxParticle();
			particle.makeGraphic(32, 32, colors[Std.int(FlxG.random.float() * colors.length)]);
			
			// Add the particle to the trail area so it has a trail
			trailArea.add(particle);
			emitter.add(particle);
		}
		
		// Add the elements in the correct order
		add(trailArea);
		add(emitter);
		add(new GUI(trailArea, null, false));
		
		// Start the emitter
		emitter.start(false, 0.1);
		
		super.create();
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// Toggle states
		if (FlxG.keys.justReleased.SPACE)
		{
			FlxG.switchState(new ParticleState());
		}
	}
}