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
	
	@Test
	function testFileReferencesDuplicateFileName()
	{
		Assert.isNotNull(DuplicateFileName.file__txt);
		Assert.isNotNull(DuplicateFileName.file__txt_2);
	}
}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssets/invisibleFile"))
class InvisibleFile {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssets/duplicateFileName", true))
class DuplicateFileName {}
