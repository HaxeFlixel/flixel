package flixel.effects.particles;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.interfaces.IFlxParticle;

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
	 * @default 500
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
	 * Start value for particle's red color component
	 */
	public var startRed:Float;
	/**
	 * Start value for particle's green color component
	 */
	public var startGreen:Float;
	/**
	 * Start value for particle's blue color component
	 */
	public var startBlue:Float;
	/**
	 * Range of red color component change during particle's life
	 */
	public var rangeRed:Float;
	/**
	 * Range of green color component change during particle's life
	 */
	public var rangeGreen:Float;
	/**
	 * Range of blue color component change during particle's life
	 */
	public var rangeBlue:Float;
	
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
				var redComp:Float = startRed + lifespanRatio * rangeRed;
				var greenComp:Float = startGreen + lifespanRatio * rangeGreen;
				var blueComp:Float = startBlue + lifespanRatio * rangeBlue;
				
				color = Std.int(255 * redComp) << 16 | Std.int(255 * greenComp) << 8 | Std.int(255 * blueComp);
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
		color = 0xffffff;
	}
	
	/**
	 * Triggered whenever this object is launched by a FlxEmitter.
	 * You can override this to add custom behavior like a sound or AI or something.
	 */
	public function onEmit():Void { }	
}