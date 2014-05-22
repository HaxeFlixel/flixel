package ;
import flash.display.Graphics;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.util.FlxSpriteUtil;

/**
 * @author Masadow
 */
class Particle extends Entity
{
	public static inline var NONE:UInt = 0;
	public static inline var ENEMY:UInt = 1;
	public static inline var BULLET:UInt = 2;
	public static inline var IGNORE_GRAVITY:UInt = 3;
	
	public static inline var LOW_SPEED:Float = 720;
	public static inline var MEDIUM_SPEED:Float = 960;
	public static inline var HIGH_SPEED:Float = 2160;
	
	public static var index:Int = 0;
	public static var activeCount:Int = 0;
	public static var max:Int = 0;
	public static var maxLifespan:Float = 3.25;
	
	public var lifespan:Float;
	public var lineScale:Float = 0.06;
	public var lineColor:FlxColor = FlxColor.WHITE;
	public var speedDecay:Float = 0.93;
	public var initialSpeed:Float;
	public var maxSpeed:Float;
	public var isGlowing:Bool = false;

	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
		max += 1;
		
		angle = 0;
		radius = 0;                        
		kill();
		loadGraphic("images/Glow.png");
		width = height = 20;
		offset.x = offset.y = 10;
		alpha = 1;
	}
	
	override public function update():Void
	{
		super.update();
		if (isGlowing)
		{
			var _lifetime:Float = maxLifespan - lifespan;
			if (_lifetime > 1.25) alpha = 0;
			else alpha = 0.2 * ((1.25 - _lifetime) / 1.25);
		}
		lifespan -= FlxG.elapsed;
		if (lifespan <= 0 || (velocity.x * velocity.x + velocity.y * velocity.y) < 1) kill();
		if (!alive) return;
		
		velocity.x = speedDecay * velocity.x;
		velocity.y = speedDecay * velocity.y;
		
		if (type != IGNORE_GRAVITY)
		{
			for (blackhole in ScreenState.blackholes)
			{
				if (blackhole.alive)
				{
					_point.x = blackhole.position.x - position.x;
					_point.y = blackhole.position.y - position.y;
					
					_point = GameInput.normalize(_point);
					var _distance:Float = GameInput.lengthBeforeNormalize;
					velocity.x += FlxG.elapsed * 600 * (10000 / (_distance * _distance + 10000)) * _point.x;
					velocity.y += FlxG.elapsed * 600 * (10000 / (_distance * _distance + 10000)) * _point.y;
					
					// add tangential acceleration for nearby particles
					if (_distance < 400)
					{
						velocity.x += FlxG.elapsed * 3000 * (100 / (_distance * _distance + 100)) * _point.y;
						velocity.y -= FlxG.elapsed * 3000 * (100 / (_distance * _distance + 100)) * _point.x;
					}
				}
			}
		}
		
		// If colliding with the edges of the screen, bounce off in the other direction
		if (position.x < 0) velocity.x = Math.abs(velocity.x); 
		else if (position.x > FlxG.width) velocity.x = -Math.abs(velocity.x);
		if (position.y < 0) velocity.y = Math.abs(velocity.y); 
		else if (position.y > FlxG.height) velocity.y = -Math.abs(velocity.y);
	}
	
	override public function draw():Void
	{
		if (isGlowing) super.draw(); //used for the PlayerShip's exhaust stream
		var gfx:Graphics = FlxSpriteUtil.flashGfx;
		var _startX:Float = position.x - 0.5 * lineScale * velocity.x;
		var _startY:Float = position.y - 0.5 * lineScale * velocity.y;
		var _endX:Float = position.x + 0.5 * lineScale * velocity.x;
		var _endY:Float = position.y + 0.5 * lineScale * velocity.y;
		
		// As a particle's lifespan increases and/or as it slows down, it slowly fades to black
		var _lifespanRatio:Float = (lifespan * lifespan) / Math.pow(maxLifespan, 1.25);
		var _speedRatio:Float = (velocity.x * velocity.x + velocity.y * velocity.y) / Math.pow(initialSpeed, 1.25);
		if (_speedRatio > _lifespanRatio) _speedRatio = _lifespanRatio;
		if (_speedRatio > 1) _speedRatio = 1;
		
		var _color = new FlxColor();
		_color.interpolate(lineColor, _speedRatio);
		
		gfx.lineStyle(3, _color);
		gfx.moveTo(_startX,_startY);
		gfx.lineTo(_endX,_endY);
	}
	
	override public function kill():Void
	{
		if (alive) activeCount -= 1;
		super.kill();
		visible = false;
	}
	
	override public function reset(X:Float, Y:Float):Void
	{
		super.reset(X, Y);
		isGlowing = false;
		lifespan = maxLifespan;
		if (!alive) activeCount += 1;
		visible = true;
	}
	
	public function setVelocity(Angle:Float, Magnitude:Float):Void
	{
		velocity.x = Magnitude * Math.cos(Angle);
		velocity.y = Magnitude * Math.sin(Angle);
		initialSpeed = Magnitude;
	}
}
