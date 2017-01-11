package flixel.graphics.frames;

import flash.display.BitmapData;
import haxe.Json;
import massive.munit.Assert;

class FlxAtlasFramesTest extends FlxTest
{
	var bmd:BitmapData;
	var hashJson:String;
	var atlasHash:FlxAtlasFrames;
	
	@Before
	function before()
	{
		bmd = new BitmapData(1, 1);
		hashJson = '{"frames":{"alien.png":{"frame":{"x":2,"y":2,"w":46,"h":16},"rotated":false,"trimmed":true,"spriteSourceSize":{"x":1,"y":0,"w":46,"h":16},"sourceSize":{"w":48,"h":16},"pivot":{"x":0.5,"y":0.5}},"medium.png":{"frame":{"x":2,"y":20,"w":32,"h":32},"rotated":false,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":32,"h":32},"sourceSize":{"w":32,"h":32},"pivot":{"x":0.5,"y":0.5}},"ship.png":{"frame":{"x":36,"y":38,"w":12,"h":8},"rotated":true,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":12,"h":8},"sourceSize":{"w":12,"h":8},"pivot":{"x":0.5,"y":0.5}},"small.png":{"frame":{"x":36,"y":20,"w":16,"h":16},"rotated":false,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":16,"h":16},"sourceSize":{"w":16,"h":16},"pivot":{"x":0.5,"y":0.5}}}}';
		atlasHash = FlxAtlasFrames.fromTexturePackerJson(bmd, hashJson);
	}
	
	@Test
	function testTexturePackerJson()
	{
		var arrJson = '{"frames":[{"filename":"alien.png","frame":{"x":2,"y":2,"w":46,"h":16},"rotated":false,"trimmed":true,"spriteSourceSize":{"x":1,"y":0,"w":46,"h":16},"sourceSize":{"w":48,"h":16},"pivot":{"x":0.5,"y":0.5}},{"filename":"medium.png","frame":{"x":2,"y":20,"w":32,"h":32},"rotated":false,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":32,"h":32},"sourceSize":{"w":32,"h":32},"pivot":{"x":0.5,"y":0.5}},{"filename":"ship.png","frame":{"x":36,"y":38,"w":12,"h":8},"rotated":true,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":12,"h":8},"sourceSize":{"w":12,"h":8},"pivot":{"x":0.5,"y":0.5}},{"filename":"small.png","frame":{"x":36,"y":20,"w":16,"h":16},"rotated":false,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":16,"h":16},"sourceSize":{"w":16,"h":16},"pivot":{"x":0.5,"y":0.5}}]}';
		var atlasArray = FlxAtlasFrames.fromTexturePackerJson(bmd, arrJson);
		
		Assert.areEqual(atlasArray.numFrames, atlasHash.numFrames);
		
		for (frameArr in atlasArray.frames)
		{
			var hashArr = atlasHash.framesHash.get(frameArr.name);
			Assert.areEqual(frameArr.name, hashArr.name);
			Assert.isTrue(frameArr.sourceSize.equals(hashArr.sourceSize));
		}
	}
	
	@Test
	function testTexturePackerJsonObject()
	{
		var parsed = Json.parse(hashJson);
		var atlasHash2 = FlxAtlasFrames.fromTexturePackerJson(bmd, parsed);
		
		Assert.areEqual(atlasHash.numFrames, atlasHash2.numFrames);
		
		for (frame in atlasHash.frames)
		{
			var frame2 = atlasHash2.framesHash.get(frame.name);
			Assert.isTrue(frame.sourceSize.equals(frame2.sourceSize));
		}
	}
}