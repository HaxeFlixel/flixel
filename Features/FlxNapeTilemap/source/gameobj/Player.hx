package gameobj;

import flixel.addons.nape.FlxNapeSprite;
import flixel.util.FlxColor;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;

class Player extends FlxNapeSprite
{
    public function new(x:Float, y:Float, fillColor:FlxColor)
    {
        super(x, y);
        makeGraphic(18, 26, fillColor);

        if (body != null)
            destroyPhysObjects();

        centerOffsets(false);
        setBody(new Body(BodyType.DYNAMIC, Vec2.weak(x, y)));

        var box = new Polygon(Polygon.box(16, 25));
        body.shapes.add(box);
        body.setShapeMaterials(Constants.playerMaterial);
        body.allowRotation = true;
    }
}
