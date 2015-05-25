package flixel.graphics.frames;

import flash.display.BitmapData;
import flixel.graphics.frames.FlxAtlasFrames;
import massive.munit.Assert;

class FlxAtlasFramesTest extends FlxTest
{
	@Test
	function testTexturePackerJson()
	{
		var bmd:BitmapData = new BitmapData(1, 1);
		var arrJson = '{"frames":[{"filename":"alien.png","frame":{"x":2,"y":2,"w":46,"h":16},"rotated":false,"trimmed":true,"spriteSourceSize":{"x":1,"y":0,"w":46,"h":16},"sourceSize":{"w":48,"h":16},"pivot":{"x":0.5,"y":0.5}},{"filename":"medium.png","frame":{"x":2,"y":20,"w":32,"h":32},"rotated":false,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":32,"h":32},"sourceSize":{"w":32,"h":32},"pivot":{"x":0.5,"y":0.5}},{"filename":"ship.png","frame":{"x":36,"y":38,"w":12,"h":8},"rotated":true,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":12,"h":8},"sourceSize":{"w":12,"h":8},"pivot":{"x":0.5,"y":0.5}},{"filename":"small.png","frame":{"x":36,"y":20,"w":16,"h":16},"rotated":false,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":16,"h":16},"sourceSize":{"w":16,"h":16},"pivot":{"x":0.5,"y":0.5}}]}';
		var hashJson = '{"frames":{"alien.png":{"frame":{"x":2,"y":2,"w":46,"h":16},"rotated":false,"trimmed":true,"spriteSourceSize":{"x":1,"y":0,"w":46,"h":16},"sourceSize":{"w":48,"h":16},"pivot":{"x":0.5,"y":0.5}},"medium.png":{"frame":{"x":2,"y":20,"w":32,"h":32},"rotated":false,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":32,"h":32},"sourceSize":{"w":32,"h":32},"pivot":{"x":0.5,"y":0.5}},"ship.png":{"frame":{"x":36,"y":38,"w":12,"h":8},"rotated":true,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":12,"h":8},"sourceSize":{"w":12,"h":8},"pivot":{"x":0.5,"y":0.5}},"small.png":{"frame":{"x":36,"y":20,"w":16,"h":16},"rotated":false,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":16,"h":16},"sourceSize":{"w":16,"h":16},"pivot":{"x":0.5,"y":0.5}}}}';
		var atlasArray:FlxAtlasFrames = FlxAtlasFrames.fromTexturePackerJson(bmd, arrJson);
		var atlasHash:FlxAtlasFrames = FlxAtlasFrames.fromTexturePackerJson(bmd, hashJson);
		
		Assert.areEqual(atlasArray.numFrames, atlasHash.numFrames);
		
		var hashArr:FlxFrame;
		for (frameArr in atlasArray.frames)
		{
			hashArr = atlasHash.framesHash.get(frameArr.name);
			Assert.areEqual(frameArr.name, hashArr.name);
			Assert.isTrue(frameArr.sourceSize.equals(hashArr.sourceSize));
		}
	}
}