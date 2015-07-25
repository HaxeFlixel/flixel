package flixel.graphics.frames;

import flixel.graphics.frames.FlxFramesCollection;

class FlxFramesCollectionTest
{
	@Test // #1497
	public function testInlineNonFinalReturn()
	{
		var collection = new FlxFramesCollection(null);
		collection.getIndexByName("Test");
	}
}