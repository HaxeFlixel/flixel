package flixel.system;

import massive.munit.Assert;

class FlxAssetsTest extends FlxTest
{
	@Test
	function testFileReferencesIgnoreInvisibleFiles()
	{
		var files:Int = Type.getClassFields(InvisibleFile).length;
		Assert.areEqual(0, files);
	}
}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssets/invisibleFile"))
class InvisibleFile {}
