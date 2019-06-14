package logic;

import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.math.FlxPoint;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.dynamics.ArbiterType;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.Material;
import nape.shape.Polygon;

class PhysUtil
{
	public static function onTop(thing:Body, ?surface:Body, error:Float = 0.80):Bool
	{
		for (contact in thing.arbiters)
		{
			if ((surface == null || contact.body1 == thing || contact.body2 == thing) && contact.type == ArbiterType.COLLISION)
			{
				var normal:Float = contact.collisionArbiter.normal.angle;
				if (contact.body1 == thing)
					normal = normal - Math.PI;
				if (Math.abs(normal + Math.PI / 2) < error)
					return true;
			}
		}
		return false;
	}

	public static function setOneWay(tilemap:FlxNapeTilemap, index:Int, vertices:Array<Vec2>, ?mat:Material)
	{
		tilemap.body.space = null;
		var polygon:Polygon;
		var coords:Array<FlxPoint> = tilemap.getTileCoords(index, false);
		for (point in coords)
		{
			polygon = new Polygon(vertices, mat);
			polygon.translate(Vec2.get(point.x, point.y));
			polygon.cbTypes.add(Constants.oneWayType);
			tilemap.body.shapes.add(polygon);
		}
		tilemap.body.space = FlxNapeSpace.space;
	}

	public static function setOneWayLong(tilemap:FlxNapeTilemap, startPos:FlxPoint, length:Int, ?mat:Material)
	{
		tilemap.body.space = null;
		var vertices = [
			Vec2.get(0, -0.1),
			Vec2.get(Constants.TILE_SIZE * length, -0.1),
			Vec2.get(Constants.TILE_SIZE * length, Constants.TILE_SIZE),
			Vec2.get(0, Constants.TILE_SIZE)
		];

		var polygon = new Polygon(vertices, mat);
		polygon.translate(Vec2.get(startPos.x, startPos.y));
		polygon.cbTypes.add(Constants.oneWayType);
		tilemap.body.shapes.add(polygon);
		tilemap.body.space = FlxNapeSpace.space;
	}

	public static function oneWayHandler(cb:PreCallback):PreFlag
	{
		var colArb = cb.arbiter.collisionArbiter;
		if ((colArb.normal.y >= 0) != cb.swapped)
			return PreFlag.IGNORE;
		else
			return PreFlag.ACCEPT;
	}
}
