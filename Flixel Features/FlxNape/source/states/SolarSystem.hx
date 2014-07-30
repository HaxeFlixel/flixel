package states;
import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeState;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.geom.Vec2;
import nape.phys.BodyType;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;

/**
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class SolarSystem extends FlxNapeState
{
	private var shooter:Shooter;
	private var planets:Array<FlxNapeSprite>;
	private static var halfWidth:Int = Std.int(FlxG.width / 2);
	private static var halfHeight:Int = Std.int(FlxG.height / 2);
	private static var gravity:Int = Std.int(5e4);
	private var sun:FlxNapeSprite;
	
	override public function create():Void 
	{	
		super.create();
		
		FlxNapeState.space.worldAngularDrag = 0;
		FlxNapeState.space.worldLinearDrag = 0;
		FlxNapeState.space.gravity = new Vec2(0, 0);
		
		createWalls();
		
		createSolarSystem();
		
		shooter = new Shooter();
		add(shooter);
	}
	
	private function createSolarSystem() 
	{
		planets = new Array<FlxNapeSprite>();
		
		var planet:FlxNapeSprite;
		
		planet = new FlxNapeSprite(halfWidth, halfHeight + 70);
		planet.setBodyMaterial(1, 0, 0, 10, 0);
		planet.createCircularBody(5);
		planets.push(planet);
		planet.body.applyImpulse(new Vec2(220 * planet.body.mass, 0));
		add(planet);
		
		planet = new FlxNapeSprite(halfWidth, halfHeight + 100);
		planet.setBodyMaterial(1, 0, 0, 10, 0);
		planet.createCircularBody(10);
		planets.push(planet);
		planet.body.applyImpulse(new Vec2(220 * planet.body.mass, 0));
		add(planet);
		
		planet = new FlxNapeSprite(halfWidth, halfHeight + 150);
		planet.setBodyMaterial(1, 0, 0, 10, 0);
		planet.createCircularBody(15);
		planets.push(planet);
		planet.body.applyImpulse(new Vec2(220 * planet.body.mass, 0));
		add(planet);
		
		planet = new FlxNapeSprite(halfWidth, halfHeight + 200);
		planet.setBodyMaterial(1, 0, 0, 10, 0);
		planet.createCircularBody(9);
		planets.push(planet);
		planet.body.applyImpulse(new Vec2(220 * planet.body.mass, 0));
		add(planet);
		
		sun = new FlxNapeSprite(halfWidth, halfHeight);
		sun.createCircularBody(20);
		sun.setBodyMaterial(0, 0, 0, 100);
		sun.body.type = BodyType.STATIC;
		add(sun);
	}
	
	override public function update():Void 
	{	
		super.update();
		
		if (FlxG.keys.justPressed.G)
			napeDebugEnabled = false;
		if (FlxG.keys.justPressed.R)
			FlxG.resetState();
			
		for (planet in planets)
		{
			var angle = planet.toPoint().angleBetween(FlxPoint.get(halfWidth, halfHeight)) - 90;
			var distance = FlxMath.getDistance(FlxPoint.get(planet.x, planet.y), FlxPoint.get(halfWidth, halfHeight));
			
			var impulse = gravity * planet.body.mass / (distance * distance);
			var force:Vec2 = new Vec2((planet.x - halfWidth) * -impulse, (planet.y - halfHeight) * -impulse);
			force.muleq(FlxG.elapsed);
			planet.body.applyImpulse(force);
			
		}
		
		if (FlxG.keys.justPressed.W)
			planets[0].body.applyImpulse(new Vec2(0, -10));
			
		if (FlxG.keys.justPressed.A)
			planets[0].body.applyImpulse(new Vec2( -10, 0));
			
		if (FlxG.keys.justPressed.S)
			planets[0].body.applyImpulse(new Vec2(0, 10));
			
		if (FlxG.keys.justPressed.D)
			planets[0].body.applyImpulse(new Vec2(10, 0));
			
		
		if (FlxG.keys.justPressed.LEFT)
			FlxPhysicsDemo.prevState();
		if (FlxG.keys.justPressed.RIGHT)
			FlxPhysicsDemo.nextState();
		
		
	}
	
	
	
}