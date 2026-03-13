package flixel.system.debug.watch;

import flixel.util.FlxStringUtil;

class TrackerProfile
{
	public var objectClass:Class<Dynamic>;
	public var variables:Array<String>;
	public var extensions:Array<Class<Dynamic>>;

	public function new(ObjectClass:Class<Dynamic>, ?Variables:Array<String>, ?Extensions:Array<Class<Dynamic>>)
	{
		objectClass = ObjectClass;
		variables = Variables;
		extensions = Extensions;
	}

	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("variables", variables),
			LabelValuePair.weak("extensions", extensions)
		]);
	}
}
