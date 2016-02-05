package;

import flash.filters.BitmapFilterQuality;
import flash.filters.BlurFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.util.FlxSpriteUtil;

/**
 * @author Masadow
 */
class ScreenState extends FlxState
{

	private var _fx:FlxSprite;
	#if !js
	private var blur:BlurFilter;
	#end
	private var _rect:Rectangle;
	private var _point:Point;
	private var lastTimeStamp:Int = 0;
	private var currentTimeStamp:Int = 0;
	
	private var fpsBuffer:Array<Int>;
	private var fpsIndex:Int;
	
	public static var grid:Grid;
	public static var blackholes:FlxTypedGroup<Enemy>;
	private static var particles:FlxTypedGroup<Particle>;
	private static var entities:FlxGroup;
	private static var cursor:FlxSprite;
	private static var displayText:FlxText;
	private static var inverseSpawnChance:Float = 60;
	private static var _spawnPosition:FlxPoint;
	
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		FlxG.fixedTimestep = false;
		
		GameInput.create();
		GameSound.create();
		
		fpsBuffer = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		fpsIndex = 0;
		
		// Neither the grid nor the particles group are added to the FlxState here. Instead, their update() and draw() routines will
		// be called in a custom order.
		var _gridRect:Rectangle = new Rectangle(0, 0, FlxG.width, FlxG.height);
		#if !js
		grid = new Grid(_gridRect, Std.int(FlxG.width / 20), Std.int(FlxG.height / 20), 8);
		#end
		
		particles = new FlxTypedGroup<Particle>();
		for (i in 0...2500) particles.add(new Particle());
		
		entities = new FlxGroup();
		entities.add(new PlayerShip());
		for (i in 0...100) entities.add(new Bullet());
		for (i in 0...200) entities.add(new Enemy());
		add(entities);
		
		blackholes = new FlxTypedGroup<Enemy>();
		for (i in 0...2) blackholes.add(new Enemy());
		add(blackholes);
		
		cursor = new FlxSprite(FlxG.mouse.x, FlxG.mouse.x);
		cursor.loadGraphic("images/Pointer.png");
		add(cursor);
		
		displayText = new FlxText(0, 0, FlxG.width, "");
		displayText.setFormat(null, 16, 0xffffff, RIGHT);
		add(displayText);
		
		//These are used to implement the glow effect.
		_fx = new FlxSprite();
		_fx.makeGraphic(FlxG.width, FlxG.height, 0, true);
		_fx.antialiasing = true;
		#if !js
		_fx.blend = SCREEN;
		#end
		_rect = new Rectangle(0, 0, FlxG.width, FlxG.height);
		_point = new Point();
		#if !js
		blur = new BlurFilter(8, 8, BitmapFilterQuality.LOW);
		#end
		
		if (FlxG.renderTile)
			FlxG.camera.canvas.addChild(FlxSpriteUtil.flashGfxSprite);
	}
	
	override public function update(elapsed:Float):Void
	{        
		GameInput.update(elapsed);
		super.update(elapsed);
		#if !js
		grid.update(elapsed);
		#end
		particles.update(elapsed);
		
		cursor.x = FlxG.mouse.x;
		cursor.y = FlxG.mouse.y;
		
		if (FlxG.random.float() < 1 / inverseSpawnChance) makeEnemy(Enemy.SEEKER);
		if (FlxG.random.float() < 1 / inverseSpawnChance) makeEnemy(Enemy.WANDERER);
		if (blackholes.countLiving() < 2) if (FlxG.random.float() < 1 / (inverseSpawnChance * 10)) makeBlackhole();
		if (inverseSpawnChance > 20) inverseSpawnChance -= 0.005;
		
		FlxG.overlap(entities, entities, handleCollision.bind(elapsed));
		FlxG.overlap(blackholes, entities, handleCollision.bind(elapsed));
		
		// Calculate average framerate over the past 10 frames.
		if (fpsIndex + 1 >= fpsBuffer.length) fpsIndex = 0;
		else fpsIndex++;
		fpsBuffer[fpsIndex] = Lib.getTimer() - lastTimeStamp;
		var _timeTotalInMilliseconds:Int = 0;
		for (i in 0...fpsBuffer.length)
			_timeTotalInMilliseconds += fpsBuffer[i];
		lastTimeStamp = Lib.getTimer();
		
		if (PlayerShip.isGameOver) 
		{
			displayText.alignment = CENTER;
			displayText.offset.y = 16 - 0.5 * FlxG.height;
			displayText.text = "Game Over\n" + "Your Score: " + PlayerShip.score + "\n" + "High Score: " + PlayerShip.highScore;
		}
		else 
		{
			displayText.alignment = RIGHT;
			displayText.offset.y = 0;
			displayText.text = "Lives: " + PlayerShip.lives + "\t\tScore: " + PlayerShip.score + "\t\tMultiplier: " 
					+ PlayerShip.multiplier;
			displayText.text += "\n" + Std.int((500 * fpsBuffer.length) / _timeTotalInMilliseconds) + " fps";
		}
	}
	
	override public function draw():Void
	{
		#if !js
		grid.draw();
		#end
		particles.draw();

		#if flash
		FlxG.camera.screen.pixels.draw(FlxSpriteUtil.flashGfxSprite);
		#end

		super.draw();

		//Apply glow effect, may cause significant framerate decrease
		#if flash
		_fx.stamp(FlxG.camera.screen);
		FlxG.camera.screen.pixels.applyFilter(FlxG.camera.screen.pixels, _rect, _point, blur);
		_fx.draw();
		#else
		/*_fx.stamp(FlxG.camera);
		FlxG.camera.canvas.stage.
		FlxG.camera.screen.pixels.applyFilter(FlxG.camera.screen.pixels, _rect, _point, blur);
		_fx.draw();*/
		#end
	}
	
	public function handleCollision(elapsed:Float, Object1:FlxObject, Object2:FlxObject):Void
	{
		var entity1:Entity = cast Object1;
		var entity2:Entity = cast Object2;
		if (entity1 == null || entity2 == null)
			return;
		
		var combinedRadius:Float = entity1.radius + entity2.radius;
		var distanceSquared = entity1.position.distanceTo(entity2.position);
		if (distanceSquared > combinedRadius * combinedRadius)
			return; // no collision
		
		entity1.collidesWith(elapsed, entity2, distanceSquared);
		entity2.collidesWith(elapsed, entity1, distanceSquared);
	}
	
	public static function reset():Void
	{
		inverseSpawnChance = 60;
	}
	
	public static function makeBullet(PositionX:Float, PositionY:Float, Angle:Float, Speed:Float):Bool
	{
		var _bullet:Bullet = cast(entities.getFirstAvailable(Bullet), Bullet);
		if (_bullet != null)
		{
			cast(_bullet, Bullet).reset(PositionX, PositionY);
			_bullet.angle = Angle;
			_bullet.velocity.x = Speed * Math.cos((Angle / 180) * Math.PI);
			_bullet.velocity.y = Speed * Math.sin((Angle / 180) * Math.PI);
			return true;
		}
		else return false;
	}
	
	public static function makeEnemy(Type:UInt):Bool
	{
		var _enemy:Enemy = cast(entities.getFirstAvailable(Enemy), Enemy);
		if (_enemy != null) 
		{
			var MinimumDistanceFromPlayer:Float = 150;
			_enemy.type = Type;
			_enemy.position = getSpawnPosition(_enemy.position, MinimumDistanceFromPlayer);
			_enemy.reset(_enemy.position.x, _enemy.position.y);
			GameSound.randomSound(GameSound.sfxSpawn);
			return true;
		}
		else return false;
	}
	
	public static function makeBlackhole():Bool
	{
		var _enemy:Enemy = cast(blackholes.getFirstAvailable(Enemy), Enemy);
		if (_enemy != null) 
		{
			var MinimumDistanceFromPlayer:Float = 20;
			_enemy.type = Enemy.BLACK_HOLE;
			_enemy.position = getSpawnPosition(_enemy.position, MinimumDistanceFromPlayer);
			_enemy.reset(_enemy.position.x, _enemy.position.y);
			return true;
		}
		else return false;
	}
	
	public static function makeParticle(Type:UInt, PositionX:Float, PositionY:Float, Angle:Float, Speed:Float, Color:FlxColor = FlxColor.WHITE, Glowing:Bool = false):Bool
	{
		Particle.index += 1;
		if (Particle.index >= Particle.max) Particle.index = 0;
		var _overwritten:Bool = false;
		var _particle:Particle = particles.members[Particle.index];
		if (_particle.exists) _overwritten = true;

		_particle.reset(PositionX, PositionY);
		_particle.type = Type;
		_particle.lineColor = Color;
		_particle.setVelocity((Angle * Math.PI) / 180, Speed);
		_particle.maxSpeed = Speed;
		_particle.isGlowing = Glowing;
		return _overwritten;
	}
	
	public static function makeExplosion(Type:UInt, PositionX:Float, PositionY:Float, FloatOfParticles:UInt, Speed:Float, Color:FlxColor = 0xff00ff, BlendColor:FlxColor = -1):Void
	{
		var _mixColors:Bool = true;
		var _mixedColor:FlxColor = 0;
		if (BlendColor != 0) 
		{
			BlendColor = _mixedColor = Color;
			_mixColors = false;
		}
		for (i in 0...FloatOfParticles)
		{
			if (_mixColors)
			{
				_mixedColor = FlxColor.interpolate(_mixedColor, BlendColor, FlxG.random.float());
			}
			makeParticle(Type, PositionX, PositionY, 360 * FlxG.random.float(), Speed * (1 - 0.5 * FlxG.random.float()), _mixedColor);
		}
	}
	
	public static function getSpawnPosition(Source:FlxPoint, MinimumDistanceFromPlayer:Float):FlxPoint
	{
		var _x:Int;
		var _y:Int;
		var _xDelta:Float;
		var _yDelta:Float;
		
		do
		{
			_x = Std.int(FlxG.random.float() * FlxG.width);
			_y = Std.int(FlxG.random.float() * FlxG.height);
			_xDelta = PlayerShip.instance.position.x - _x;
			_yDelta = PlayerShip.instance.position.y - _y;
		} while (_xDelta * _xDelta + _yDelta * _yDelta < MinimumDistanceFromPlayer * MinimumDistanceFromPlayer);
		
		Source.x = _x;
		Source.y = _y;
		
		return Source;
	}
}
