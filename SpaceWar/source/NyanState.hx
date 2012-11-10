package;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxParticle;
import org.flixel.FlxPoint;
import org.flixel.FlxState;
import org.flixel.FlxText;

class NyanState extends FlxState 
{
	public var gameover:Bool = false;
	
	private var starfield:StarField;
	private var _ship: Ship;
	private var _cats:FlxGroup;
	private var _bullets:FlxGroup;
	private var _spawnTimer:Float;
	private var _spawnInterval:Float = 2.5;
	private var _scoreText:FlxText;
	private var _gameOverText:FlxText;
	
	override public function create():Void 
	{
		FlxG.mouse.hide();
		
		_ship = new Ship();
		add(_ship);
		
		_cats = new FlxGroup();
		add(_cats);
		
		_bullets = new FlxGroup();
		add(_bullets);
		
		starfield = new StarField(90, 4);
		add(starfield);
		
		resetSpawnTimer();
		
		FlxG.score = 0;
		_scoreText = new FlxText(10, 8, 200, "0");
		_scoreText.setFormat(null, 32, 0xFFFFFF, "left");
		add(_scoreText);
		
		FlxG.playMusic("NyanCat");
		
		super.create();
	}
	
	override public function update():Void 
	{	
		var control:String = ControlsSelect.control;
		
		if (FlxG.keys.justPressed("SPACE") && !gameover && control == "keyboard") 
		{
			spawnBullet(_ship.getBulletSpawnPosition());
		}
		
		if (FlxG.mouse.justPressed() && !gameover && control == "mouse") 
		{
			spawnBullet(_ship.getBulletSpawnPosition());
		}
		
		_spawnTimer -= FlxG.elapsed;
		
		if (_spawnTimer < 0) 
		{
			spawnCat();
			resetSpawnTimer();
		}
		
		FlxG.overlap(_cats, _bullets, overlapCatBullet);
		FlxG.overlap(_cats, _ship, overlapCatShip);
		
		if (FlxG.keys.ENTER && !_ship.alive /*_ship.destroy*/) 
		{
			_ship.destroy();
			
			FlxG.switchState(new NyanState());
		}
		
		super.update();
	}
	
	private function spawnBullet(p:FlxPoint):Void 
	{
		var bullet:Bullet = new Bullet(p.x, p.y);
		_bullets.add(bullet);
		FlxG.play("Bullet");
	}
	
	private function spawnCat():Void 
	{
		var x:Float = FlxG.width;
		var y:Float = Math.random() * (FlxG.height - 100) + 50;
		_cats.add(new Cat(x, y));
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
	
	private function overlapCatBullet(cat:FlxObject, bullet:FlxObject):Void 
	{
		cat.kill();
		bullet.kill();
		FlxG.score += 1;
		_scoreText.text = Std.string(FlxG.score);
		FlxG.play("ExplosionAlien");
		var emitter:FlxEmitter = createEmitter();
		emitter.at(cat);
	}
	
	private function overlapCatShip(cat:FlxObject, ship:FlxObject):Void 
	{
		ship.kill();
		cat.kill();
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
			particle.makeGraphic(3, 3, 0xFFF66FFF);
			#else
			particle.makeGraphic(3, 3, {rgb: 0xF66FFF, a: 0xFF});
			#end
			particle.exists = false;
			emitter.add(particle);
		}
		emitter.start();
		add(emitter);
		return emitter;
	}
}