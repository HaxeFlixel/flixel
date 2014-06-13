package flixel.effects.particles;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.helpers.Range;

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
	public var lifespan(default, null):Float = 0;
	/**
	 * How long this particle has lived so far.
	 */
	public var age(default, null):Float = 0;
	/**
	 * What percentage progress this particle has made of its total life. Essentially just (age / lifespan) on a scale from 0 to 1.
	 */
	public var percent(default, null):Float = 0;
	/**
	 * Whether or not angularVelocity should be updated each frame.
	 */
	public var useAngularVelocity:Bool = false;
	/**
	 * Whether or not scale should be updated each frame.
	 */
	public var useScale:Bool = false;
	/**
	 * Whether or not alpha should be updated each frame.
	 */
	public var useAlpha:Bool = false;
	/**
	 * Whether or not color should be updated each frame.
	 */
	public var useColor:Bool = false;
	/**
	 * Whether or not drag should be updated each frame.
	 */
	public var useDrag:Bool = false;
	/**
	 * Whether or not acceleration should be updated each frame.
	 */
	public var useAcceleration:Bool = false;
	/**
	 * Whether or not elasticity should be updated each frame.
	 */
	public var useElasticity:Bool = false;
	/**
	 * The range of values for velocity over this particle's lifespan.
	 */
	public var velocityRange:Range<Float>;
	/**
	 * The range of values for angularVelocity over this particle's lifespan.
	 */
	public var angularVelocityRange:Range<Float>;
	/**
	 * The range of values for scale over this particle's lifespan.
	 */
	public var scaleRange:Range<FlxPoint>;
	/**
	 * The range of values for alpha over this particle's lifespan.
	 */
	public var alphaRange:Range<Float>;
	/**
	 * The range of values for color over this particle's lifespan.
	 */
	public var colorRange:Range<FlxColor>;
	/**
	 * The range of values for drag over this particle's lifespan.
	 */
	public var dragRange:Range<FlxPoint>;
	/**
	 * The range of values for acceleration over this particle's lifespan.
	 */
	public var accelerationRange:Range<FlxPoint>;
	/**
	 * The range of values for elasticity over this particle's lifespan.
	 */
	public var elasticityRange:Range<Float>;
	
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
		if (age < lifespan)
		{
			age += FlxG.elapsed;
			
			if (age >= lifespan)
			{
				kill();
			}
			
			percent = age / lifespan;
			
			if (useAngularVelocity)
			{
				angularVelocity.x = angularVelocityRange.start.x + angularVelocityRange.range.x * percent;
				angularVelocity.y = angularVelocityRange.start.y + angularVelocityRange.range.y * percent;
			}
			
			if (useScale)
			{
				scale.x = scaleRange.start.x + scaleRange.range.x * percent;
				scale.y = scaleRange.start.y + scaleRange.range.y * percent;
			}
			
			if (useAlpha)
			{
				alpha = alphaRange.start + alphaRange.range * percent;
			}
			
			if (useColor)
			{
				color = FlxColor.interpolate(colorRange.start, colorRange.end, percent);
			}
			
			if (useDrag)
			{
				drag.x = dragRange.start.x + dragRange.range.x * percent;
				drag.y = dragRange.start.y + dragRange.range.y * percent;
			}
			
			if (useAcceleration)
			{
				acceleration.x = accelerationRange.start.x + accelerationRange.range.x * percent;
				acceleration.y = accelerationRange.start.y + accelerationRange.range.y * percent;
			}
			
			if (useElasticity)
			{
				elasticity = elasticityRange.start + elasticityRange.range * percent;
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
	public var age:Float;
	public var percent:Float;
	public var useAngularVelocity:Bool;
	public var useScale:Bool;
	public var useAlpha:Bool;
	public var useColor:Bool;
	public var useDrag:Bool;
	public var useAcceleration:Bool;
	public var useElasticity:Bool;
	public var velocityRange:Range<Float>;
	public var angularVelocityRange:Range<Float>;
	public var scaleRange:Range<FlxPoint>;
	public var alphaRange:Range<Float>;
	public var colorRange:Range<FlxColor>;
	public var dragRange:Range<FlxPoint>;
	public var accelerationRange:Range<FlxPoint>;
	public var elasticityRange:Range<Float>;
	
	public function onEmit():Void;
}