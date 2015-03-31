package flixel.effects.particles;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.helpers.FlxRange;

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
	 * How long this particle lives before it disappears. Set to 0 to never kill() the particle automatically.
	 * NOTE: this is a maximum, not a minimum; the object could get recycled before its lifespan is up.
	 */
	public var lifespan:Float = 0;
	/**
	 * How long this particle has lived so far.
	 */
	public var age(default, null):Float = 0;
	/**
	 * What percentage progress this particle has made of its total life. Essentially just (age / lifespan) on a scale from 0 to 1.
	 */
	public var percent(default, null):Float = 0;
	/**
	 * Whether or not the hitbox should be updated each frame when scaling.
	 */
	public var autoUpdateHitbox:Bool = false;
	/**
	 * The range of values for velocity over this particle's lifespan.
	 */
	public var velocityRange:FlxRange<FlxPoint>;
	/**
	 * The range of values for angularVelocity over this particle's lifespan.
	 */
	public var angularVelocityRange:FlxRange<Float>;
	/**
	 * The range of values for scale over this particle's lifespan.
	 */
	public var scaleRange:FlxRange<FlxPoint>;
	/**
	 * The range of values for alpha over this particle's lifespan.
	 */
	public var alphaRange:FlxRange<Float>;
	/**
	 * The range of values for color over this particle's lifespan.
	 */
	public var colorRange:FlxRange<FlxColor>;
	/**
	 * The range of values for drag over this particle's lifespan.
	 */
	public var dragRange:FlxRange<FlxPoint>;
	/**
	 * The range of values for acceleration over this particle's lifespan.
	 */
	public var accelerationRange:FlxRange<FlxPoint>;
	/**
	 * The range of values for elasticity over this particle's lifespan.
	 */
	public var elasticityRange:FlxRange<Float>;
	/**
	 * The amount of change from the previous frame.
	 */
	private var _delta:Float = 0;
	
	/**
	 * Instantiate a new particle. Like FlxSprite, all meaningful creation
	 * happens during loadGraphic() or makeGraphic() or whatever.
	 */
	@:keep
	public function new()
	{
		super();
		
		velocityRange = new FlxRange<FlxPoint>(FlxPoint.get(), FlxPoint.get());
		angularVelocityRange = new FlxRange<Float>(0);
		scaleRange = new FlxRange<FlxPoint>(FlxPoint.get(1,1), FlxPoint.get(1,1));
		alphaRange = new FlxRange<Float>(1, 1);
		colorRange = new FlxRange<FlxColor>(FlxColor.WHITE);
		dragRange = new FlxRange<FlxPoint>(FlxPoint.get(), FlxPoint.get());
		accelerationRange = new FlxRange<FlxPoint>(FlxPoint.get(), FlxPoint.get());
		elasticityRange = new FlxRange<Float>(0);
		
		exists = false;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		velocityRange.start = FlxDestroyUtil.put(velocityRange.start);
		velocityRange.end = FlxDestroyUtil.put(velocityRange.end);
		scaleRange.start = FlxDestroyUtil.put(scaleRange.start);
		scaleRange.end = FlxDestroyUtil.put(scaleRange.end);
		dragRange.start = FlxDestroyUtil.put(dragRange.start);
		dragRange.end = FlxDestroyUtil.put(dragRange.end);
		accelerationRange.start = FlxDestroyUtil.put(accelerationRange.start);
		accelerationRange.end = FlxDestroyUtil.put(accelerationRange.end);
		
		velocityRange = null;
		angularVelocityRange = null;
		scaleRange = null;
		alphaRange = null;
		colorRange = null;
		dragRange = null;
		accelerationRange = null;
		elasticityRange = null;
		
		super.destroy();
	}
	
	/**
	 * The particle's main update logic. Basically updates properties if alive, based on ranged properties.
	 */
	override public function update(elapsed:Float):Void
	{
		if (age < lifespan)
		{
			age += elapsed;
		}
		
		if (age >= lifespan && lifespan != 0)
		{
			kill();
		}
		else
		{
			_delta = elapsed / lifespan;
			percent = age / lifespan;
			
			if (velocityRange.active)
			{
				velocity.x += (velocityRange.end.x - velocityRange.start.x) * _delta;
				velocity.y += (velocityRange.end.y - velocityRange.start.y) * _delta;
			}
			
			if (angularVelocityRange.active)
			{
				angularVelocity += (angularVelocityRange.end - angularVelocityRange.start) * _delta;
			}
			
			if (scaleRange.active)
			{
				scale.x += (scaleRange.end.x - scaleRange.start.x) * _delta;
				scale.y += (scaleRange.end.y - scaleRange.start.y) * _delta;
				if (autoUpdateHitbox) updateHitbox();
			}
			
			if (alphaRange.active)
			{
				alpha += (alphaRange.end - alphaRange.start) * _delta;
			}
			
			if (colorRange.active)
			{
				color = FlxColor.interpolate(colorRange.start, colorRange.end, percent);
			}
			
			if (dragRange.active)
			{
				drag.x += (dragRange.end.x - dragRange.start.x) * _delta;
				drag.y += (dragRange.end.y - dragRange.start.y) * _delta;
			}
			
			if (accelerationRange.active)
			{
				acceleration.x += (accelerationRange.end.x - accelerationRange.start.x) * _delta;
				acceleration.y += (accelerationRange.end.y - accelerationRange.start.y) * _delta;
			}
			
			if (elasticityRange.active)
			{
				elasticity += (elasticityRange.end - elasticityRange.start) * _delta;
			}
		}
		
		super.update(elapsed);
	}
	
	override public function reset(X:Float, Y:Float):Void 
	{
		super.reset(X, Y);
		age = 0;
		visible = true;
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
	public var age(default, null):Float;
	public var percent(default, null):Float;
	public var autoUpdateHitbox:Bool;
	public var velocityRange:FlxRange<FlxPoint>;
	public var angularVelocityRange:FlxRange<Float>;
	public var scaleRange:FlxRange<FlxPoint>;
	public var alphaRange:FlxRange<Float>;
	public var colorRange:FlxRange<FlxColor>;
	public var dragRange:FlxRange<FlxPoint>;
	public var accelerationRange:FlxRange<FlxPoint>;
	public var elasticityRange:FlxRange<Float>;
	
	public function onEmit():Void;
}