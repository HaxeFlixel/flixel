package flixel.system.macros;

import haxe.PosInfos;
import massive.munit.Assert;

class FlxAssetPathsTest extends FlxTest
{
	@Test
	function testAllFiles()
	{
		final numFiles:Int = Simple.allFiles.length;
		final numFields:Int = Type.getClassFields(Simple).length;
		Assert.areEqual(numFiles, numFields - 1);
	}
	
	@Test
	function testIgnoreInvisibleFiles()
	{
		assertPathArrays(
			[],
			InvisibleFile.allFiles,
			InvisibleFile
		);
	}
	
	@Test 
	function testIncludeString()
	{
		assertPathArrays(
			[IncludeString.text__txt, IncludeString.fileWithMultipleDots__png__txt],
			IncludeString.allFiles,
			IncludeString
		);
	}
	
	@Test 
	function testExcludeString()
	{
		assertPathArrays(
			[ExcludeString.text__txt, ExcludeString.fileWithMultipleDots__png__txt],
			ExcludeString.allFiles,
			ExcludeString
		);
	}
	
	@Test 
	function testIncludeExcludeString()
	{
		assertPathArrays(
			[IncludeExcludeString.text__txt],
			IncludeExcludeString.allFiles,
			IncludeExcludeString
		);
	}
	
	@Test 
	function testIncludeEReg()
	{
		assertPathArrays(
			[IncludeEReg.text__txt, IncludeEReg.fileWithMultipleDots__png__txt],
			IncludeEReg.allFiles,
			IncludeEReg
		);
	}
	@Test 
	function testExcludeEReg()
	{
		assertPathArrays(
			[ExcludeEReg.text__txt, ExcludeEReg.fileWithMultipleDots__png__txt],
			ExcludeEReg.allFiles,
			ExcludeEReg
		);
	}
	
	@Test 
	function testIncludeExcludeEReg()
	{
		assertPathArrays(
			[IncludeExcludeEReg.text__txt],
			IncludeExcludeEReg.allFiles,
			IncludeExcludeEReg
		);
	}
	
	@Test 
	function testRename()
	{
		assertPathArrays(
			// [],
			[Rename.text, Rename.fileWithMultipleDots, Rename.info],
			Rename.allFiles,
			Rename
		);
	}
	
	@Test
	function testAllFilesRename()
	{
		final numFiles:Int = RenamedAllFiles.list.length;
		final numFields:Int = Type.getClassFields(RenamedAllFiles).length;
		Assert.areEqual(numFiles, numFields - 1);
	}
	
	/**
	 * Similar to `FlxAssert.arraysEqual` but allows different orders and outputs more nicely
	 */
	function assertPathArrays(expected:Array<String>, actual:Array<String>, type:Class<Any>, ?info:PosInfos)
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
			final typeFields = Type.getClassFields(type);
			Assert.fail('Expected $expected but was $actual.\n class fields: $typeFields', info);
		}
	}
}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/simple"))
class Simple {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/FlxAssetPaths/simple", false, null, null, null, "list"))
class RenamedAllFiles {}

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
