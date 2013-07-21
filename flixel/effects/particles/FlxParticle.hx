package flixel.effects.particles;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * This is a simple particle class that extends the default behavior
 * of <code>FlxSprite</code> to have slightly more specialized behavior
 * common to many game scenarios.  You can override and extend this class
 * just like you would <code>FlxSprite</code>. While <code>FlxEmitter</code>
 * used to work with just any old sprite, it now requires a
 * <code>FlxParticle</code> based class.
*/
class FlxParticle extends FlxSprite
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
<<<<<<< HEAD:src/org/flixel/FlxParticle.hx
	 */
	public var fadingAway:Bool = false;
	
=======
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
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/effects/particles/FlxParticle.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/effects/particles/FlxParticle.hx
>>>>>>> experimental
	/**
	 * If this is set to true, particles will slowly decrease in scale 
	 * based on their lifespan.
	 * WARNING: This severely impacts performance.
	 */
<<<<<<< HEAD:src/org/flixel/FlxParticle.hx
	public var decreasingSize:Bool = false;
	
=======
	public var rangeGreen:Float;
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/effects/particles/FlxParticle.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/effects/particles/FlxParticle.hx
>>>>>>> experimental
	/**
	 * Helper variable for fading and sizeDecreasing effects.
	 */
	public var maxLifespan:Float;
	
	/**
	 * Instantiate a new particle. Like <code>FlxSprite</code>, all meaningful creation
	 * happens during <code>loadGraphic()</code> or <code>makeGraphic()</code> or whatever.
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
		#if !FLX_NO_DEBUG
		FlxBasic._ACTIVECOUNT++;
		#end
		
		if (_flickerTimer > 0)
		{
			_flickerTimer -= FlxG.elapsed;
			
			if(_flickerTimer <= 0)
			{
				_flickerTimer = 0;
				_flicker = false;
			}
		}
		
		last.x = x;
		last.y = y;
		
<<<<<<< HEAD:src/org/flixel/FlxParticle.hx
		if ((path != null) && (pathSpeed != 0) && (path.nodes[_pathNodeIndex] != null))
		{
			updatePathMotion();
		}
		
		//lifespan behavior
=======
		// Lifespan behavior
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/effects/particles/FlxParticle.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/effects/particles/FlxParticle.hx
>>>>>>> experimental
		if (lifespan > 0)
		{
			lifespan -= FlxG.elapsed;
			if (lifespan <= 0)
			{
				kill();
			}
			
			// Fading away
			if (fadingAway)
			{
				alpha -= (FlxG.elapsed / maxLifespan);
			}
			
			// Decreasing size
			if (decreasingSize) 
			{
				scale.x = scale.y -= (FlxG.elapsed / maxLifespan);
			}
<<<<<<< HEAD:src/org/flixel/FlxParticle.hx
		
			//simpler bounce/spin behavior for now
=======
			
			// Simpler bounce/spin behavior for now
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/effects/particles/FlxParticle.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/effects/particles/FlxParticle.hx
>>>>>>> experimental
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
			if (moves)
			{
				updateMotion();
			}
			
			wasTouching = touching;
			touching = FlxObject.NONE;
			
			updateAnimation();
			calcAABB();
		}
	}
	
	/**
	 * Triggered whenever this object is launched by a <code>FlxEmitter</code>.
	 * You can override this to add custom behavior like a sound or AI or something.
	 */
	public function onEmit():Void { }
	
}
