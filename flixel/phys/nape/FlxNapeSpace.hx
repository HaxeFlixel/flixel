package flixel.phys.nape;
import flixel.phys.IFlxSpace;
import nape.geom.Vec2;
import nape.space.Space;

class FlxNapeSpace implements IFlxSpace
{
	var napeSpace : Space;
	var objects : Array<FlxNapeBody>;
	
	public function new()
	{
		napeSpace = new Space(Vec2.weak(0, 0));
		objects = new Array<FlxNapeBody>();
	}
	
	public function step(elapsed : Float)
	{
		for (obj in objects)
		{
			obj.updateBody();
		}
		napeSpace.step(elapsed);
		for (obj in objects)
		{
			obj.updateParent();
		}
	}
	
	public function add(body : FlxNapeBody)
	{
		if (objects.lastIndexOf(body) == -1)
		{
			objects.push(body);
			napeSpace.bodies.add(body.napeBody);
		}
	}
	
	public function destroy()
	{
		
	}
}