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
	public function new(minDisplayTime:Float = 0, ?allowedUrls:Array<String>)
	{
		super(minDisplayTime, allowedUrls);
	}

	override function create()
	{
		super.create();
	}

	override function destroy()
	{
		super.destroy();
	}

	override public function update(percent:Float):Void
	{
		super.update(percent);
	}
}
