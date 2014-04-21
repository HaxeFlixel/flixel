package;

import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeState;
import flixel.util.FlxRandom;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
class Box extends FlxNapeSprite {
	public function new(X:Float,Y:Float) {
		super(X, Y);
		makeGraphic(30, 30, FlxRandom.color());
		/*
		var body:Body = new Body(BodyType.DYNAMIC, Vec2.get(X, Y));
		var shape:Polygon = new Polygon(Polygon.box(30, 30), new Material(0, 100,100));
		body.shapes.add(shape);
		addPremadeBody(body);
		*/
		createRectangularBody(30, 30);
		setBodyMaterial(0.5, 0.5, 0.5, 2);
		body.space = FlxNapeState.space;
		physicsEnabled = true;
	}
}