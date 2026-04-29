package flixel.system.debug.console;

/**
 * The default debug console manager used by `FlxG.console` and the Console debug window
 * when the hscript library is not available
 * 
 * @since 6.2.0
 */
class EmptyConsoleHandler implements IFlxConsoleHandler
{
	public function new() {}
	
	public function evaluate(input:String):Any
	{
		throw 'Cannot evaluate $input';
	}
	
	public function register(alias:String, value:Any):Void {}
	
	public function remove(alias:String):Void {}
	
	public function getFields(object:Any):Array<String>
	{
		return [];
	}
	
	public function getGlobals():Array<String>
	{
		return [];
	}
	
	public function findAlias(obj:Any):Null<String>
	{
		return null;
	}
	
	public function toString()
	{
		return "[EmptyConsoleHandler]";
	}
}