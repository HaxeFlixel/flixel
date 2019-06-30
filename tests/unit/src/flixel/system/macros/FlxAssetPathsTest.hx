package flixel.system.macros;

import massive.munit.Assert;

class FlxAssetPathsTest extends FlxTest
{
	@Test
	function testIgnoreInvisibleFiles()
	{
		var files:Int = Type.getClassFields(InvisibleFile).length;
		Assert.areEqual(0, files);
	}

	@Test // #2107
	function testExtensionFilterWithMultiDotFile()
	{
		var files:Int = Type.getClassFields(ExtensionFilterWithMultiDotFile).length;
		Assert.areEqual(1, files);
	}
}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/invisibleFile"))
class InvisibleFile {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/fileWithMultipleDots", false, ["txt"]))
class ExtensionFilterWithMultiDotFile {}
