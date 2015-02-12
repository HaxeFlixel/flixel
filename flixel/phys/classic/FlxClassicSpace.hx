package flixel.phys.classic;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.phys.IFlxBody;
import flixel.phys.IFlxSpace;
import flixel.math.FlxRect;

class FlxClassicSpace implements IFlxSpace {
	
	private var objects : Array<FlxClassicBody>;
	private var _hasToBeRemoved : FlxGroup;
	
	public function new()
	{
		objects = new Array<FlxClassicBody>();
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
		FlxCollide.collide(objects);
		for (obj in objects)
		{
			obj.parent.x = obj.position.x;
			obj.parent.y = obj.position.y;
		}
	}
	
	public function destroy()
	{
		
	}
	
}