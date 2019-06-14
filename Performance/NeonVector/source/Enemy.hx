package;

import flash.Lib;
import flixel.FlxG;
import flixel.math.FlxAngle;
import flixel.util.FlxColor;

/**
 * ...
 * @author Masadow
 */
class Enemy extends Entity
{
	public static inline var SEEKER:UInt = 0;
	public static inline var WANDERER:UInt = 1;
	public static inline var BLACK_HOLE:UInt = 2;

	// var enemyPixels:Array<BitmapData>;
	var enemyPixels:Array<String>;
	var pointValue:Int = 10;

	var _saveWidth:Int;
	var _saveHeight:Int;

	public function new(X:Float = 0, Y:Float = 0, Type:UInt = 0)
	{
		super(FlxG.width * FlxG.random.float(), FlxG.height * FlxG.random.float());

		// enemyPixels = new Array<BitmapData>();
		enemyPixels = new Array<String>();

		// enemyPixels.push(loadRotatedGraphic("images/Seeker.png", 360, -1, true, true).pixels);
		// enemyPixels.push(loadRotatedGraphic("images/Wanderer.png", 360, -1, true, true).pixels);
		// enemyPixels.push(loadRotatedGraphic("images/BlackHole.png", 360, -1, true, true).pixels);
		enemyPixels.push("images/Seeker.png");
		enemyPixels.push("images/Wanderer.png");
		enemyPixels.push("images/BlackHole.png");

		// _saveWidth = cast width;
		// _saveHeight = cast height;
		// cachedGraphics.bitmap = enemyPixels[SEEKER];
		// pixels = enemyPixels[SEEKER];
		// region.width = cast width = frameWidth = _saveWidth;
		// region.height = cast height = frameHeight = _saveHeight;

		loadRotatedGraphic(enemyPixels[SEEKER], 360, -1, true, true);

		type = SEEKER;

		radius = 20;
		hitboxRadius = 18;
		maxVelocity.x = maxVelocity.y = 300;

		alive = false;
		exists = false;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!alive)
			return;

		if (alpha >= 1)
		{
			applyBehaviors();
		}
		else
		{
			alpha += elapsed;
		}

		if (type == BLACK_HOLE)
		{
			var _angle:Float = (0.720 * Lib.getTimer()) % 360;
			#if !js
			ScreenState.grid.applyImplosiveForce(position, 0.5 * Math.sin(FlxAngle.asRadians(_angle)) * 150 + 300, 200);
			#end
			if (cooldownTimer.finished)
			{
				cooldownTimer.reset(0.02 + 0.08 * FlxG.random.float());
				var _color:FlxColor = 0xff00ff; // light purple
				var _speed:Float = 360 + FlxG.random.float() * 90;
				var _offsetX:Float = 16 * Math.sin(FlxAngle.asRadians(_angle));
				var _offsetY:Float = -16 * Math.cos(FlxAngle.asRadians(_angle));
				ScreenState.makeParticle(Particle.ENEMY, position.x + _offsetX, position.y + _offsetY, _angle, _speed, _color);
			}
		}

		// gradually build up speed
		// velocity.x *= 0.8;
		// velocity.y *= 0.8;
		postUpdate();
	}

	public function postUpdate():Void
	{
		if (type != BLACK_HOLE)
			hitEdgeOfScreen = clampToScreen();
	}

	override public function hurt(Damage:Float):Void
	{
		super.hurt(Damage);

		if (type == BLACK_HOLE)
		{
			var hue:Float = (0.180 * Lib.getTimer()) % 360;
			var _color = FlxColor.fromHSB(hue, 0.25, 1);
			ScreenState.makeExplosion(Particle.IGNORE_GRAVITY, position.x, position.y, 100, Particle.MEDIUM_SPEED, _color);
		}
	}

	override public function kill():Void
	{
		if (!alive)
			return;
		PlayerShip.addPoints(pointValue);
		PlayerShip.increaseMultiplier();
		super.kill();
		GameSound.randomSound(GameSound.sfxExplosion, 0.5);

		var _color:FlxColor = switch (FlxG.random.int(0, 6))
		{
			case 0: 0xff3333;
			case 1: 0x33ff33;
			case 2: 0x3333ff;
			case 3: 0xffffaa;
			case 4: 0xff33ff;
			case 5: 0x00ffff;
			case _: 0xffffff;
		}
		ScreenState.makeExplosion(Particle.ENEMY, position.x, position.y, 90, Particle.MEDIUM_SPEED, _color, FlxColor.WHITE);
	}

	override public function set_type(Value:UInt):UInt
	{
		var _previousType:UInt = type;
		type = Value;

		// Change the pixel BitmapData if the type changed
		if (_previousType != type)
		{
			// cachedGraphics.bitmap = enemyPixels[type];
			// pixels = enemyPixels[type];
			// region.tileWidth = cast width = frameWidth = _saveWidth;
			// region.tileHeight = cast height = frameHeight = _saveHeight;
			loadRotatedGraphic(enemyPixels[type], 360, -1, true, true);
			dirty = true;
		}

		switch (type)
		{
			case SEEKER:
				alpha = 0;
				health = 1;
				radius = 20;
				hitboxRadius = 18;
			case WANDERER:
				alpha = 0;
				health = 1;
				radius = 20;
				hitboxRadius = 18;
			case BLACK_HOLE:
				alpha = 1;
				health = 10;
				radius = 250;
				hitboxRadius = 18;
		}
		width = height = 2 * Math.max(radius, hitboxRadius);
		centerOffsets();
		return Value;
	}

	override public function collidesWith(elapsed:Float, Object:Entity, DistanceSquared:Float):Void
	{
		var CombinedHitBoxRadius:Float = hitboxRadius + Object.hitboxRadius;
		var IsHitBoxCollision:Bool = (CombinedHitBoxRadius * CombinedHitBoxRadius) >= DistanceSquared;
		var AngleFromCenters:Float = FlxAngle.asRadians(position.angleBetween(Object.position));
		if (Std.is(Object, Bullet))
		{
			if (IsHitBoxCollision)
			{
				Object.kill();
				hurt(1);
			}
			else
			{
				if (type == BLACK_HOLE)
				{
					Object.velocity.x -= elapsed * 1100 * Math.cos(AngleFromCenters);
					Object.velocity.y -= elapsed * 1100 * Math.sin(AngleFromCenters);
				}
			}
		}
		else if (Std.is(Object, Enemy))
		{
			var enemy:Enemy = cast Object;
			var IsBlackHole:Bool = (type == BLACK_HOLE);
			if (IsBlackHole && enemy.type == BLACK_HOLE)
				return;

			if (IsHitBoxCollision)
			{
				if (IsBlackHole)
					Object.kill();
			}
			else
			{
				if (IsBlackHole)
				{
					var GravityStrength:Float = elapsed * 15 * Entity.interpolate(60, 0, Math.sqrt(DistanceSquared) / radius);
					Object.velocity.x += GravityStrength * Math.cos(AngleFromCenters);
					Object.velocity.y += GravityStrength * Math.sin(AngleFromCenters);
				}
				else
				{
					var XDistance:Float = position.x - Object.position.x;
					var YDistance:Float = position.y - Object.position.y;
					velocity.x += elapsed * 18000 * XDistance / (DistanceSquared + 1);
					velocity.y += elapsed * 18000 * YDistance / (DistanceSquared + 1);
				}
			}
		}
		else if (Std.is(Object, PlayerShip))
		{
			if (IsHitBoxCollision)
				Object.kill();
		}
	}

	override public function reset(X:Float, Y:Float):Void
	{
		cooldownTimer.cancel();
		alpha = 0;
		acceleration.x = acceleration.y = 0;
		angularVelocity = 0;
		super.reset(X - 0.5 * width, Y - 0.5 * height);
	}

	function applyBehaviors():Void
	{
		if (type == SEEKER)
			followPlayer();
		else if (type == WANDERER)
			moveRandomly();
		else if (type == BLACK_HOLE)
			applyGravity();
	}

	function followPlayer(Acceleration:Float = 5):Void
	{
		if (PlayerShip.instance.alive)
		{
			acceleration.x = Acceleration * (PlayerShip.instance.position.x - position.x);
			acceleration.y = Acceleration * (PlayerShip.instance.position.y - position.y);
			angle = Entity.angleInDegrees(acceleration);
		}
		else
			moveRandomly();
	}

	function moveRandomly(Acceleration:Float = 320):Void
	{
		var Angle:Float;
		if (hitEdgeOfScreen)
		{
			// cooldownTimer.abort();
			// cooldownTimer = FlxTimer.start(1);
			cooldownTimer.reset(1);
			Angle = 2 * Math.PI * FlxG.random.float();
			velocity.x = 0;
			velocity.y = 0;
			acceleration.x = Acceleration * Math.cos(Angle);
			acceleration.y = Acceleration * Math.sin(Angle);
			angularVelocity = 200;
		}

		if (!cooldownTimer.finished || hitEdgeOfScreen)
			return;
		// cooldownTimer.abort();
		// cooldownTimer = FlxTimer.start(1);
		cooldownTimer.reset(1);
		Angle = 2 * Math.PI * FlxG.random.float();
		acceleration.x = Acceleration * Math.cos(Angle);
		acceleration.y = Acceleration * Math.sin(Angle);
		angularVelocity = 200;
	}

	function applyGravity(Acceleration:Float = 320):Void
	{
		angularVelocity = 200;
	}
}
