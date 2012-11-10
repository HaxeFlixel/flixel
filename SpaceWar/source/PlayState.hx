package;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxParticle;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;

class PlayState extends FlxState 
{
	public var gameover:Bool = false;
	
	private var starField:StarField;
	private var _ship:Ship;
	private var _aliens:FlxGroup;
	private var _alienShips:FlxGroup;
	private var _bullets:FlxGroup;
	private var _spawnTimer:Float;
	private var _spawnInterval:Float = 2.5;
	private var _scoreText:FlxText;
	private var _gameOverText:FlxText;
	public var alienBullets:FlxGroup;
	public static var shield:Bool = false;
	private var random:Float;
	private var random2:Int;
	private var shieldTimer:Int;
	
	override public function create():Void 
	{
		FlxG.mouse.hide();
		var i:Int;
		
		_ship = new Ship();
		add(_ship);
		
		_aliens = new FlxGroup();
		add(_aliens);
		
		_alienShips = new FlxGroup();
		add(_alienShips);
		
		_bullets = new FlxGroup();
		add(_bullets);
		
		starField = new StarField(90, 4);
		add(starField);
		
		var numAlienBullets:Int = 32;
		alienBullets = new FlxGroup(numAlienBullets);
		var sprite:FlxSprite;
		for (i in 0...(numAlienBullets)) 
		{
			sprite = new FlxSprite(100, 100);
			sprite.makeGraphic(16, 4);
			sprite.exists = false;
			alienBullets.add(sprite);
		}
		add(alienBullets);
		
		resetSpawnTimer();
		
		FlxG.score = 0;
		_scoreText = new FlxText(10, 8, 200, "0");
		_scoreText.setFormat(null, 32, 0xFFFFFF, "left");
		add(_scoreText);
		
		FlxG.playMusic("DieAnyway");
		
		super.create();
	}
	
	override public function update():Void 
	{	
		var control:String = ControlsSelect.control;
		
		shieldTimer -= Math.floor(FlxG.elapsed);
		
		if (shieldTimer == 0) 
		{
			shield = false;
		}
		
		if (FlxG.keys.justPressed("SPACE") && !gameover && control == "keyboard") 
		{
			spawnBullet(_ship.getBulletSpawnPosition());
		}
		
		if (FlxG.mouse.justPressed() && !gameover && control == "mouse") 
		{
			spawnBullet(_ship.getBulletSpawnPosition());
		}
		
		_spawnTimer -= FlxG.elapsed;
		random = FlxG.random();	
		
		if (_spawnTimer < 0) 
		{			
			if (random < 0.2) 
			{
				spawnAlienShip();
			}
			else 
			{
				spawnAlien();
			}	
			resetSpawnTimer();
		}
		
		if (shield == false) 
		{
			FlxG.overlap(_alienShips, _ship, overlapAlienShipShip);
			FlxG.overlap(_aliens, _ship, overlapAlienShip);
			FlxG.overlap(_ship, alienBullets, overlapShipAlienBullet);
		}
		
		FlxG.overlap(_aliens, _bullets, overlapAlienBullet);
		FlxG.overlap(_alienShips, _bullets, overlapAlienShipBullet);
		
		if (FlxG.keys.ENTER && !_ship.alive /*_ship.kill*/) 
		{
			FlxG.switchState(new PlayState());
		}
		
		super.update();
	}
	
	public function getRandom2():Void 
	{
		random2 = Math.floor(FlxG.random() * 7);
	}
	
	private function spawnBullet(p:FlxPoint):Void 
	{
		var bullet:Bullet = new Bullet(p.x, p.y);
		_bullets.add(bullet);
		FlxG.play("Bullet");
	}
	
	private function spawnAlien():Void 
	{
		var x:Float = FlxG.width;
		var y:Float = Math.random() * (FlxG.height - 100) + 50;
		_aliens.add(new Alien(x, y));
	}
	
	private function spawnAlienShip():Void 
	{
		var x:Float = FlxG.width;
		var y:Float = Math.random() * (FlxG.height - 100) + 50;
		_alienShips.add(new AlienShip(x, y));
	}
	
	private function resetSpawnTimer():Void 
	{
		_spawnTimer = _spawnInterval;
		_spawnInterval *= 0.95;
		if (_spawnInterval < 0.1) 
		{
			_spawnInterval = 0.1;
		}
	}
	
	private function resetShieldTimer():Void 
	{
		shieldTimer = 500;
	}
	
	private function overlapAlienBullet(alien:FlxObject, bullet:FlxObject):Void
	{
		alien.kill();
		bullet.kill();
		FlxG.score += 1;
		_scoreText.text = Std.string(FlxG.score);
		FlxG.play("ExplosionAlien");
		var emitter:FlxEmitter = createEmitter();
		emitter.at(alien);
	}
	
	private function overlapAlienShip(alien:FlxObject, ship:FlxObject):Void 
	{
		ship.kill();
		alien.kill();
		FlxG.play("ExplosionShip");
		var emitter:FlxEmitter = createEmitter();
		emitter.at(ship);
	
		_gameOverText = new FlxText(0, FlxG.height / 2, FlxG.width, "GAME OVER\nPress Enter to Play Again.");
		_gameOverText.setFormat(null, 16, 0xFFFFFF, "center");
		add(_gameOverText);
		gameover = true;		
	}	
	
	private function overlapAlienShipShip(alienShip:FlxObject, ship:FlxObject):Void 
	{
		ship.kill();
		alienShip.kill();
		FlxG.play("ExplosionShip");
		var emitter:FlxEmitter = createEmitter();
		emitter.at(ship);
		
		_gameOverText = new FlxText(0, FlxG.height / 2, FlxG.width, "GAME OVER\nPress Enter to Play Again.");
		_gameOverText.setFormat(null, 16, 0xFFFFFF, "center");
		add(_gameOverText);
		gameover = true;
	}
	
	private function overlapAlienShipBullet(alienShip:FlxObject, bullet:FlxObject):Void 
	{	
		alienShip.kill();
		bullet.kill();
		getRandom2();
		if (random2 == 3) 
		{	
			shield = true;
			resetShieldTimer();
		}
		FlxG.score += 1;
		_scoreText.text = Std.string(FlxG.score);
		FlxG.play("ExplosionAlien");
		var emitter:FlxEmitter = createEmitter();
		emitter.at(alienShip);
	}
	
	private function overlapShipAlienBullet(ship:FlxObject, bullet:FlxObject):Void 
	{
		ship.kill();
		bullet.kill();
		FlxG.play("ExplosionShip");
		var emitter:FlxEmitter = createEmitter();
		emitter.at(ship);
		
		_gameOverText = new FlxText(0, FlxG.height / 2, FlxG.width, "GAME OVER\nPress Enter to Play Again.");
		_gameOverText.setFormat(null, 16, 0xFFFFFF, "center");
		add(_gameOverText);
		gameover = true;
	}
	
	
	private function createEmitter():FlxEmitter 
	{
		var emitter:FlxEmitter = new FlxEmitter();
		emitter.gravity = 0;
		emitter.maxRotation = 0;
		emitter.setXSpeed(-500, 500);
		emitter.setYSpeed(-500, 500);
		var particles:Int = 10;
		for (i in 0...(particles)) 
		{
			var particle:FlxParticle = new FlxParticle();
			#if !neko
			particle.makeGraphic(3, 3, 0xFFFFFFFF);
			#else
			particle.makeGraphic(3, 3, {rgb: 0xFFFFFF, a: 0xFF});
			#end
			particle.exists = false;
			emitter.add(particle);
		}
		emitter.start();
		add(emitter);
		return emitter;
	}
}