package flixel.effects.particles;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

/**
 * This is a simple particle class that extends the default behavior
 * of FlxSprite to have slightly more specialized behavior
 * common to many game scenarios.  You can override and extend this class
 * just like you would FlxSprite. While FlxEmitter
 * used to work with just any old sprite, it now requires a
 * FlxParticle based class.
*/
class FlxParticle extends FlxSprite implements IFlxParticle
{
	/**
	 * How long this particle lives before it disappears.
	 * NOTE: this is a maximum, not a minimum; the object
	 * could get recycled before its lifespan is up.
	 */
	public var lifespan:Float = 0;
	/**
	 * Determines how quickly the particles come to rest on the ground.
	 * Only used if the particle has gravity-like acceleration applied.
	 */
	public var friction:Float = 500;
	/**
	 * If this is set to true, particles will slowly fade away by
	 * decreasing their alpha value based on their lifespan.
	*/
	public var useFading:Bool = false;
	/**
	 * If this is set to true, particles will slowly decrease in scale
	 * based on their lifespan.
	 * WARNING: This severely impacts performance on flash target.
	*/
	public var useScaling:Bool = false;
	/**
	 * If this is set to true, particles will change their color
	 * based on their lifespan and start and range color components values.
	 */
	public var useColoring:Bool = false;
	/**
	 * Helper variable for fading, scaling and coloring particle.
	 */
	public var maxLifespan:Float;
	/**
	 * Start value for particle's alpha
	 */
	public var startAlpha:Float;
	/**
	 * Range of alpha change during particle's life
	 */
	public var rangeAlpha:Float;
	/**
	 * Start value for particle's scale.x and scale.y
	 */
	public var startScale:Float;
	/**
	 * Range of scale change during particle's life
	 */
	public var rangeScale:Float;
	/**
	 * Start value for particle's color
	 */
	public var startColor:FlxColor;
	/**
	 * End value for particle's color
	 */
	public var endColor:FlxColor;
	
	/**
	 * Instantiate a new particle. Like FlxSprite, all meaningful creation
	 * happens during loadGraphic() or makeGraphic() or whatever.
	 */
	public function new()
	{
		super();
		exists = false;
	}
	
	/**
	 * The particle's main update logic.  Basically it checks to see if it should
	 * be dead yet, and then has some special bounce behavior if there is some gravity on it.
	 */
	override public function update():Void
	{
		// Lifespan behavior
		if (lifespan > 0)
		{
			lifespan -= FlxG.elapsed;
			if (lifespan <= 0)
			{
				kill();
			}
			
			var lifespanRatio:Float = (1 - lifespan / maxLifespan);
			
			// Fading
			if (useFading)
			{
				alpha = startAlpha + lifespanRatio * rangeAlpha;
			}
			
			// Changing size
			if (useScaling)
			{
				scale.x = scale.y = startScale + lifespanRatio * rangeScale;
			}
			
			// Tinting
			if (useColoring)
			{
				color = FlxColor.interpolate(startColor, endColor, lifespanRatio);
			}
			
			// Simpler bounce/spin behavior for now
			if (touching != 0)
			{
				if (angularVelocity != 0)
				{
					angularVelocity = -angularVelocity;
				}
			}
			// Special behavior for particles with gravity
			if (acceleration.y > 0)
			{
				if ((touching & FlxObject.FLOOR) != 0)
				{
					drag.x = friction;
					
					if ((wasTouching & FlxObject.FLOOR) == 0)
					{
						if (velocity.y < -elasticity * 10)
						{
							if (angularVelocity != 0)
							{
								angularVelocity *= -elasticity;
							}
						}
						else
						{
							velocity.y = 0;
							angularVelocity = 0;
						}
					}
				}
				else
				{
					drag.x = 0;
				}
			}
		}
		
		if (exists && alive)
		{
			super.update();
		}
	}
	
	override public function reset(X:Float, Y:Float):Void 
	{
		super.reset(X, Y);
		
		alpha = 1.0;
		scale.x = scale.y = 1.0;
		color = FlxColor.WHITE;
	}
	
	/**
	 * Triggered whenever this object is launched by a FlxEmitter.
	 * You can override this to add custom behavior like a sound or AI or something.
	 */
	public function onEmit():Void {}	
}

interface IFlxParticle extends IFlxSprite
{
	public var lifespan:Float;
	public var friction:Float;
	public var useFading:Bool;
	public var useScaling:Bool;
	public var useColoring:Bool;
	public var maxLifespan:Float;
	public var startAlpha:Float;
	public var rangeAlpha:Float;
	public var startScale:Float;
	public var rangeScale:Float;
	public var startColor:FlxColor;
	public var endColor:FlxColor;
	
	public function onEmit():Void;
}