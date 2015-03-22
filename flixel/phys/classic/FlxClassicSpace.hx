package flixel.phys.classic;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.phys.IFlxBody;
import flixel.phys.IFlxSpace;
import flixel.math.FlxRect;

class FlxClassicSpace implements IFlxSpace {
	
	private var objects : Array<FlxClassicBody>;
	
	public var iterationCount : Int;
	
	public function new(iterationCount : Int = 8)
	{
		objects = new Array<FlxClassicBody>();
		this.iterationCount = iterationCount;
	}
	
	public function add(body : IFlxBody) : Void
	{
		var _body = cast(body, FlxClassicBody);
		if (objects.indexOf(_body) == -1)
		{
			objects.push(_body);
		}
	}
	
	public function remove(body : IFlxBody) : Void
	{
		var _body = cast(body, FlxClassicBody);
		objects.remove(_body);
	}
	
	public function step(elapsed : Float) : Void
	{
		for (obj in objects)
		{
			obj.updateBody(elapsed);
		}
		FlxCollide.collide(objects, iterationCount);
		for (obj in objects)
		{
			obj.parent.x = obj.x;
			obj.parent.y = obj.y;
		}
	}
	
	public function destroy()
	{
		
	}
	
}