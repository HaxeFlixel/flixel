package flixel.system.macros;

import haxe.PosInfos;
import massive.munit.Assert;

class FlxAssetPathsTest extends FlxTest
{
	@Test
	function testListField()
	{
		final numFiles:Int = Simple.allFiles.length;
		final numFields:Int = Type.getClassFields(Simple).length;
		Assert.areEqual(numFiles, numFields - 1);
		Assert.areEqual(3, numFiles);
	}
	
	@Test
	function testNoListField()
	{
		final numFields:Int = Type.getClassFields(NoListField).length;
		Assert.areEqual(3, numFields);
	}
	
	@Test
	function testIgnoreInvisibleFiles()
	{
		assertPathArrays(
			[],
			InvisibleFile.allFiles
		);
	}
	
	@Test 
	function testIncludeString()
	{
		assertPathArrays(
			[IncludeString.text__txt, IncludeString.fileWithMultipleDots__png__txt],
			IncludeString.allFiles
		);
	}
	
	@Test 
	function testExcludeString()
	{
		assertPathArrays(
			[ExcludeString.text__txt, ExcludeString.fileWithMultipleDots__png__txt],
			ExcludeString.allFiles
		);
	}
	
	@Test 
	function testIncludeExcludeString()
	{
		assertPathArrays(
			[IncludeExcludeString.text__txt],
			IncludeExcludeString.allFiles
		);
	}
	
	@Test 
	function testIncludeEReg()
	{
		assertPathArrays(
			[IncludeEReg.text__txt, IncludeEReg.fileWithMultipleDots__png__txt],
			IncludeEReg.allFiles
		);
	}
	@Test 
	function testExcludeEReg()
	{
		assertPathArrays(
			[ExcludeEReg.text__txt, ExcludeEReg.fileWithMultipleDots__png__txt],
			ExcludeEReg.allFiles
		);
	}
	
	@Test 
	function testIncludeExcludeEReg()
	{
		assertPathArrays(
			[IncludeExcludeEReg.text__txt],
			IncludeExcludeEReg.allFiles
		);
	}
	
	@Test 
	function testRename()
	{
		assertPathArrays(
			[Rename.text, Rename.fileWithMultipleDots, Rename.info],
			Rename.allFiles
		);
	}
	
	@Test
	function testListFieldRename()
	{
		final numFiles:Int = RenamedListField.list.length;
		final numFields:Int = Type.getClassFields(RenamedListField).length;
		Assert.areEqual(numFiles, numFields - 1);
	}
	
	@Test // https://github.com/HaxeFlixel/flixel/issues/2810
	function testDuplicates()
	{
		final numFiles:Int = Duplicates.allFiles.length;
		Assert.areEqual(2, numFiles);
		
		final numFields:Int = Type.getClassFields(Duplicates).length;
		Assert.areEqual(1, numFields - 1);
		
		Assert.isTrue(Duplicates.allFiles.contains(Duplicates.info__txt));
	}
	
	/**
	 * Similar to `FlxAssert.arraysEqual` but allows different orders and outputs more nicely
	 */
	function assertPathArrays(expected:Array<String>, actual:Array<String>, ?info:PosInfos)
	{
		var fail = false;
		if (expected.length != actual.length)
			fail = true;
		else
		{
			for (path in expected)
			{
				if (!actual.contains(path))
				{
					fail = true;
					break;
				}
			}
		}
		
		if (fail)
		{
			Assert.fail('Expected $expected but was $actual', info);
		}
	}
}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/simple"))
class Simple {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/simple", false, null, null, null, "list"))
class RenamedListField {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/simple", false, null, null, null, ""))
class NoListField {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/invisibleFile"))
class InvisibleFile {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/simple", false, "*.txt"))
class IncludeString {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/simple", false, null, "*.md"))
class ExcludeString {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/simple", false, "*.txt", "*png*"))
class IncludeExcludeString {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/simple", false, ~/.txt$/))
class IncludeEReg {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/simple", false, null, ~/.md$/))
class ExcludeEReg {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/simple", false, ~/.txt$/, ~/png/))
class IncludeExcludeEReg {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/simple", false, null, null, function (file)
{
	return file.split("/").pop()
		.split(".")[0]
		.split(" ").join("_");
}))
class Rename {}


@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/duplicates", true))
class Duplicates {}
