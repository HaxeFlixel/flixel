package flixel.system;

class FlxPreloaderTest 
{
	@Test // #1803
	function testOverridePreloader()
	{
		new OverriddenPreloader();
	}
}

class OverriddenPreloader extends FlxPreloader
{
	#if (openfl < "4.0.0")
	public function new(minDisplayTime:Float = 0, ?allowedUrls:Array<String>)
	{
		super(minDisplayTime, allowedUrls);
	}
	
	override private function create()
	{
		super.create();
	}
	
	override private function destroy()
	{
		super.destroy();
	}
	
	override public function update(percent:Float):Void
	{
		super.update(percent);
	}
	#end
}