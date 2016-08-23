package gameobj;

import flixel.addons.nape.FlxNapeSprite;
import flixel.util.FlxColor;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;

@: final
class Player extends FlxNapeSprite
{
    public function new(X: Float, Y: Float, fillcolor:FlxColor)
    {
        super(X, Y);
        makeGraphic(18, 26, fillcolor);
        //createRectangularBody(16, 25);
        if (body != null)
        {
            destroyPhysObjects();
        }
        centerOffsets(false);
        setBody(new Body(BodyType.DYNAMIC, Vec2.weak(X, Y)));
        var a_box = new Polygon(Polygon.box(16, 25));
        body.shapes.add(a_box);
        body.setShapeMaterials(Constants.playerMaterial);
        body.allowRotation = true;
    }

}
