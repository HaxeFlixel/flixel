package states;

import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeSpace;
import nape.geom.Vec2;
import nape.phys.BodyType;
import flixel.FlxG;
import flixel.math.FlxPoint;

/**
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class SolarSystem extends BaseState
{
	var shooter:Shooter;
	var planets:Array<FlxNapeSprite>;

	static var halfWidth:Int;
	static var halfHeight:Int;
	static var gravity:Int = Std.int(5e4);

	var sun:FlxNapeSprite;

	override public function create():Void
	{
		super.create();

		halfWidth = Std.int(FlxG.width / 2);
		halfHeight = Std.int(FlxG.height / 2);

		FlxNapeSpace.init();

		FlxNapeSpace.space.worldAngularDrag = 0;
		FlxNapeSpace.space.worldLinearDrag = 0;
		FlxNapeSpace.space.gravity = new Vec2(0, 0);

		FlxNapeSpace.createWalls();

		createSolarSystem();

		shooter = new Shooter();
		add(shooter);
	}

	function createSolarSystem()
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

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		for (planet in planets)
		{
			var distance = planet.getPosition().distanceTo(FlxPoint.get(halfWidth, halfHeight));

			var impulse = gravity * planet.body.mass / (distance * distance);
			var force:Vec2 = new Vec2((planet.x - halfWidth) * -impulse, (planet.y - halfHeight) * -impulse);
			force.muleq(elapsed);
			planet.body.applyImpulse(force);
		}

		if (FlxG.keys.justPressed.W)
			planets[0].body.applyImpulse(new Vec2(0, -10));

		if (FlxG.keys.justPressed.A)
			planets[0].body.applyImpulse(new Vec2(-10, 0));

		if (FlxG.keys.justPressed.S)
			planets[0].body.applyImpulse(new Vec2(0, 10));

		if (FlxG.keys.justPressed.D)
			planets[0].body.applyImpulse(new Vec2(10, 0));
	}
}
