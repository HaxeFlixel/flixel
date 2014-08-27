package states;

import flash.display.BitmapData;
import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import nape.geom.Vec2;
import openfl.Assets;

/**
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 * @link https://github.com/ProG4mr
 */
class Explosions extends FlxNapeState
{
	private var shooter:Shooter;
	public var buildingSprites:Array<FlxNapeSprite>;
	
	override public function create():Void 
	{	
		super.create();
		
		// Sets gravity.
		FlxNapeState.space.gravity.setxy(0, 500);
		
		//createWalls( -2000, 0, 1640, FlxG.height);
		createWalls();
		createBuildings();
		//shooter = new Shooter();
		//add(shooter);
	}
	
	private function createBuildings() 
	{
		buildingSprites = new Array<FlxNapeSprite>();
		createBuilding(Assets.getBitmapData("assets/building1.png"), 40, 380);
	}
	
	private function createBuilding(bitmapData:BitmapData, x:Int, y:Int) 
	{
		var spr:FlxNapeSprite;
		for (i in 0...bitmapData.width)
		{
			for (j in 0...bitmapData.height) 
			{
				var color = bitmapData.getPixel32(i, j);
				if ((color >>> 24) > 0) 
				{
					spr = new FlxNapeSprite(x + i * 10, y + j * 10);
					spr.makeGraphic(10, 10, color);
					spr.createRectangularBody();
					spr.setBodyMaterial(0.3);
					add(spr);
					buildingSprites.push(spr);
				}
			}
		}
	}
	
	override public function update(elapsed:Float):Void 
	{	
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.G)
			napeDebugEnabled = false;
		if (FlxG.keys.justPressed.R)
			FlxG.resetState();
		
		if (FlxG.keys.justPressed.LEFT)
			FlxPhysicsDemo.prevState();
		if (FlxG.keys.justPressed.RIGHT)
			FlxPhysicsDemo.nextState();
			
		if (FlxG.mouse.justPressed) 
		{
			FlxTimer.start(0.3, startBulletTime);
			createExplosion();
		}
	}
	
	private function startBulletTime(Timer:FlxTimer) 
	{
		FlxG.timeScale = 0.2;
		FlxTween.tween(FlxG, { timeScale: 1.0 }, 1, { ease: FlxEase.quadIn, delay: 1 });
	}
	
	private function createExplosion() 
	{
		var explosion:Explosion = new Explosion(FlxG.mouse.x, FlxG.mouse.y, "assets/ExplosionWave.png", this); 
		add(explosion);
		
		var explosionFire:FlxSprite = new FlxSprite(FlxG.mouse.x, FlxG.mouse.y);
		explosionFire.loadGraphic("assets/ExplosionFire.png", true, false, 83, 83);
		var frames:Array<Int> = new Array<Int>();
		for (i in 0...43) frames.push(i);
		//explosionFire.addAnimation("normal", frames, 30, true);
		add(explosionFire);
		//explosionFire.play("normal");
		
		explosion.explosionFire = explosionFire; // For deleting purposes.
	}
	
	public function removeExplosion(explosion:Explosion)
	{
		remove(explosion);
		remove(explosion.explosionFire);
		explosion.explosionFire.destroy();
		explosion.destroy();
	}
}

class Explosion extends FlxSprite
{
	static public inline var EXP_FORCE:Int = 1500;
	var parent:Explosions;
	var buildingSprites:Array<FlxNapeSprite>;
	public var explosionFire:FlxSprite;
	var trueX:Float;
	var trueY:Float;
	
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:Dynamic, Parent:Explosions)
	{
		super(X, Y, SimpleGraphic);
		trueX = x;
		trueY = y;
		this.x -= width / 2;
		this.y -= height / 2;
		this.scale.x = 0.01;
		this.scale.y = 0.01;
		parent = Parent;
		buildingSprites = parent.buildingSprites.copy();
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		this.scale.x *= 1 + elapsed * 10;
		this.scale.y *= 1 + elapsed * 10;
		
		if (this.width * scale.x >= 300) 
		{
			alpha -= 2 * elapsed;
		}
		
		if (alpha <= 0)
		{
			parent.removeExplosion(this);
		}
		
		applyGravity();
	}
	
	private function applyGravity():Void 
	{
		for (i in buildingSprites)
		{
			var distance = FlxMath.getDistance(FlxPoint.get(i.x , i.y), FlxPoint.get(trueX, trueY));
			if (distance < this.width * scale.x / 2) 
			{
				var impulse = EXP_FORCE / (distance * distance);
				i.body.applyImpulse(new Vec2((i.x - trueX) * impulse, (i.y - trueY) * impulse));
				buildingSprites.remove(i);
				//FlxG.log(" x " + (i.x - x) * impulse + " y " + (i.y - y) * impulse);
			}
		}
	}
}