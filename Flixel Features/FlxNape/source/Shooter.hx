package ;
import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeState;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxAngle;
import flixel.util.FlxPoint;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.constraint.DistanceJoint;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;

/**
 * Fires small projectiles to where the user clicks.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 * @link https://github.com/ProG4mr
 */
class Shooter extends FlxTypedGroup<FlxNapeSprite>
{
	public static var CB_BULLET:CbType = new CbType();
	var mouseJoint:DistanceJoint;
	var impulse = 3000;
	
	public var disableShooting:Bool;
	
	public function new() 
	{
		super(11);
		
		// Background sprite is used to detect mouseClicks on empty space.
		// When such click is detected shooter launches a projectile.
		// If a selectable sprite is clicked, it creates a mouseJoint to that sprite.
		var background:FlxSprite = new FlxSprite();
		background.makeGraphic(640, 480, 0xFF000000);
		background.alpha = 1;
		FlxG.state.members.insert(0, background);
		FlxG.state.length++;
		FlxMouseEventManager.add(background, launchProjectile);
		var color = 0x333333;
		
		for (i in 0...maxSize)
		{
			var spr = new FlxNapeSprite(0, 0);
			spr.makeGraphic(2, 2, 0x0);
			
			spr.antialiasing = true;
			spr.body.allowRotation = false;
			spr.createCircularBody(8);
			spr.setBodyMaterial(0, .2, .4, 20);
			spr.body.cbTypes.add(CB_BULLET);
			spr.body.isBullet = true;
			spr.body.setShapeFilters(new InteractionFilter(256, ~256));
			spr.kill();
			add(spr);
		}
		
		FlxNapeState.space.listeners.add(new InteractionListener(
			CbEvent.BEGIN, 
			InteractionType.COLLISION, 
			Shooter.CB_BULLET,
			CbType.ANY_BODY,
			onBulletColides));
	}
	
	function launchProjectile(spr:FlxSprite) 
	{
		
		if (disableShooting) 
			return;
		
		var spr = recycle(FlxNapeSprite);
		var trail = new Trail(Std.int(spr.x), Std.int(spr.y), spr);
		
		spr.body.position.y = 30;
		spr.body.position.x = 30 + Std.random(640 - 30);
		var angle = FlxAngle.getAngle(FlxPoint.get(FlxG.mouse.x, FlxG.mouse.y), 
									  FlxPoint.get(spr.body.position.x, spr.body.position.y));
		angle += 90;
		spr.body.velocity.setxy(impulse * Math.cos(angle * 3.14 / 180),
								impulse * Math.sin(angle * 3.14 / 180));
		
		spr.body.angularVel = 30;				
	}

	public function onBulletColides(clbk:InteractionCallback) 
	{
		var spr = getFirstAlive();
		if (spr != null)
			spr.kill();
	}
	
	public inline function registerPhysSprite(spr:FlxNapeSprite)
	{
		FlxMouseEventManager.add(spr, createMouseJoint);
	}
	
	function createMouseJoint(spr:FlxSprite) 
	{
		
		var body:Body = cast(spr, FlxNapeSprite).body;
		
		mouseJoint = new DistanceJoint(FlxNapeState.space.world, body, new Vec2(FlxG.mouse.x, FlxG.mouse.y),
								body.worldPointToLocal(new Vec2(FlxG.mouse.x, FlxG.mouse.y)), 0, 0);
		
		mouseJoint.space = FlxNapeState.space;
	}	
	
	override public function update():Void 
	{
		super.update();
		
		if (mouseJoint != null) 
		{
			mouseJoint.anchor1 = new Vec2(FlxG.mouse.x, FlxG.mouse.y);
			
			if (FlxG.mouse.justReleased)
			{
				mouseJoint.space = null;
			}
		}
	}
	
	public function setSpeed(maxSpeed:Int) 
	{
		impulse = maxSpeed;
	}
	
	public function setDensity(density:Float) 
	{
		for (spr in members)
		{
			var fps:FlxNapeSprite = cast(spr, FlxNapeSprite);
			fps.body.shapes.at(0).material.density = density;
		}
	}
}

class Trail extends FlxEmitter
{
	var attach:FlxNapeSprite;
	var killTimmer:Float;
	var isDying:Bool;
	
	function new(X:Int, Y:Int, Attach:FlxNapeSprite)
	{
		killTimmer = 0;
		super(0, 0);
		
		makeParticles("assets/shooter.png", 20, 0, false, 0, false);
		attach = Attach;
		
		FlxG.state.add(this);
		xVelocity.set(0, 0);
		yVelocity.set(0, 0);
		rotation.set(0, 0);
		
		setScale(1, 1, 0, 0);
		setAlpha(1, 1, 0, 0);
		
		start(false, .25, .25, 0, 0);
		emitting = false;
	}
	
	override public function update():Void
	{
		super.update();
		
		if (isDying) 
		{
			killTimmer += FlxG.elapsed;
			if (killTimmer > 1)
			{
				kill();
				FlxG.state.remove(this);
			}
			return;
		}
		
		if (attach.alive == false)
		{
			x = attach.x;
			y = attach.y;
			emitParticle();
			isDying = true;
		} 
		else 
		{
			x = attach.x;
			y = attach.y;
			emitParticle();
		}
	}
}
