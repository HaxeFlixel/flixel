package;

import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxState;

/**
 * ...
 * @author Zaphod
 */
class PlayState extends FlxState
{
	
	public var playerShip:PlayerShip;
	public var bullets:FlxGroup;
	public var asteroids:FlxGroup;
	public var timer:Float;
	
	override public function create():Void 
	{
		FlxG.mouse.hide();
		
		var i:Int;
		var sprite:FlxSprite;
		
		for (i in 0...100)
		{
			sprite = new FlxSprite(FlxG.random() * FlxG.width, FlxG.random() * FlxG.height);
			#if !neko
			sprite.makeGraphic(2, 2, 0xffffffff);
			#else
			sprite.makeGraphic(2, 2, {rgb: 0xffffff, a: 0xff});
			#end
			sprite.updateTileSheet();
			sprite.active = false;
			add(sprite);
		}
		
		asteroids = new FlxGroup();
		add(asteroids);
		spawnAsteroid();
		spawnAsteroid();
		spawnAsteroid();
		
		playerShip = new PlayerShip();
		add(playerShip);
		
		var numBullets:Int = 32;
		bullets = new FlxGroup(numBullets);
		for (i in 0...(numBullets))
		{
			sprite = new WrapSprite( -100, -100);
			sprite.makeGraphic(8, 2);
			sprite.updateTileSheet();
			sprite.width = 10;
			sprite.height = 10;
			sprite.offset.x = -1;
			sprite.offset.y = -4;
			sprite.exists = false;
			bullets.add(sprite);
		}
		add(bullets);
	}
	
	override public function update():Void 
	{
		timer -= FlxG.elapsed;
		if (timer <= 0)
		{
			spawnAsteroid();
		}
		
		super.update();
		
		FlxG.overlap(bullets, asteroids, stuffHitStuff);
		FlxG.overlap(asteroids, playerShip, stuffHitStuff);
		FlxG.collide(asteroids);
		
		if (!playerShip.exists)
		{
			FlxG.resetState();
		}
	}
	
	private function stuffHitStuff(Object1:FlxObject, Object2:FlxObject):Void
	{
		Object1.kill();
		Object2.kill();
	}
	
	private function spawnAsteroid():Void
	{
		var asteroid:Asteroid = cast(asteroids.recycle(Asteroid), Asteroid);
		asteroid.create();
		timer = 1 + FlxG.random() * 4;
	}
	
}