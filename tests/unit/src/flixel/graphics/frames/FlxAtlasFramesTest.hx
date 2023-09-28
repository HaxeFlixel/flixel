package flixel.graphics.frames;

import openfl.display.BitmapData;
import haxe.Json;
import massive.munit.Assert;

class FlxAtlasFramesTest extends FlxTest
{
	var bmd:BitmapData;
	var json:String;
	var xml:String;
	var atlasJson:FlxAtlasFrames;
	var atlasXml:FlxAtlasFrames;

	@Before
	function before()
	{
		bmd = new BitmapData(1, 1);
		json = '{"frames":{"alien.png":{"frame":{"x":2,"y":2,"w":46,"h":16},"rotated":false,"trimmed":true,"spriteSourceSize":{"x":1,"y":0,"w":46,"h":16},"sourceSize":{"w":48,"h":16},"pivot":{"x":0.5,"y":0.5}},"medium.png":{"frame":{"x":2,"y":20,"w":32,"h":32},"rotated":false,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":32,"h":32},"sourceSize":{"w":32,"h":32},"pivot":{"x":0.5,"y":0.5}},"ship.png":{"frame":{"x":36,"y":38,"w":12,"h":8},"rotated":true,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":12,"h":8},"sourceSize":{"w":12,"h":8},"pivot":{"x":0.5,"y":0.5}},"small.png":{"frame":{"x":36,"y":20,"w":16,"h":16},"rotated":false,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":16,"h":16},"sourceSize":{"w":16,"h":16},"pivot":{"x":0.5,"y":0.5}}}}';
		atlasJson = FlxAtlasFrames.fromTexturePackerJson(new BitmapData(1, 1), json);
		xml = '<TextureAtlas>
  <SubTexture name="hey0001" x="471" y="528" width="394" height="416" frameX="-0" frameY="-0" frameWidth="414" frameHeight="418" />
  <SubTexture name="hey0002" x="471" y="528" width="394" height="416" frameX="-0" frameY="-0" frameWidth="414" frameHeight="418" />
  <SubTexture name="hey0003" x="1887" y="514" width="413" height="410" frameX="-0" frameY="-8" frameWidth="414" frameHeight="418" />
  <SubTexture name="hey0004" x="1887" y="514" width="413" height="410" frameX="-0" frameY="-8" frameWidth="414" frameHeight="418" />
</TextureAtlas>';
		atlasXml = FlxAtlasFrames.fromSparrow(new BitmapData(1, 1), xml);
	}

	@Test
	function testTexturePackerJson()
	{
		var arrJson = '{"frames":[{"filename":"alien.png","frame":{"x":2,"y":2,"w":46,"h":16},"rotated":false,"trimmed":true,"spriteSourceSize":{"x":1,"y":0,"w":46,"h":16},"sourceSize":{"w":48,"h":16},"pivot":{"x":0.5,"y":0.5}},{"filename":"medium.png","frame":{"x":2,"y":20,"w":32,"h":32},"rotated":false,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":32,"h":32},"sourceSize":{"w":32,"h":32},"pivot":{"x":0.5,"y":0.5}},{"filename":"ship.png","frame":{"x":36,"y":38,"w":12,"h":8},"rotated":true,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":12,"h":8},"sourceSize":{"w":12,"h":8},"pivot":{"x":0.5,"y":0.5}},{"filename":"small.png","frame":{"x":36,"y":20,"w":16,"h":16},"rotated":false,"trimmed":false,"spriteSourceSize":{"x":0,"y":0,"w":16,"h":16},"sourceSize":{"w":16,"h":16},"pivot":{"x":0.5,"y":0.5}}]}';
		var atlasArray = FlxAtlasFrames.fromTexturePackerJson(bmd, arrJson);

		Assert.areEqual(atlasArray.numFrames, atlasJson.numFrames);
		Assert.areEqual(atlasJson.numFrames, 4);

		for (frameArr in atlasArray.frames)
		{
			var hashArr = atlasJson.getByName(frameArr.name);
			Assert.areEqual(frameArr.name, hashArr.name);
			Assert.isTrue(frameArr.sourceSize.equals(hashArr.sourceSize));
		}
	}

	@Test
	function testTexturePackerJsonObject()
	{
		final parsed = Json.parse(json);
		final atlas2 = FlxAtlasFrames.fromTexturePackerJson(bmd, parsed);

		Assert.areEqual(atlasJson.numFrames, atlas2.numFrames);
		Assert.areEqual(atlas2.numFrames, 4);

		for (frame in atlasJson.frames)
		{
			final frame2 = atlas2.getByName(frame.name);
			Assert.isTrue(frame.sourceSize.equals(frame2.sourceSize));
		}
	}

	@Test
	function testSparrowObject()
	{
		final parsed = Xml.parse(xml);
		final atlas2 = FlxAtlasFrames.fromSparrow(bmd, parsed);

		Assert.areEqual(atlasXml.numFrames, atlas2.numFrames);
		Assert.areEqual(atlas2.numFrames, 4);

		for (frame in atlasXml.frames)
		{
			final frame2 = atlas2.getByName(frame.name);
			Assert.isTrue(frame.sourceSize.equals(frame2.sourceSize));
		}
	}

	@Test
	function testSparrowXml()
	{
		final atlas2 = FlxAtlasFrames.fromSparrow(bmd, xml);

		Assert.areEqual(atlasXml.numFrames, atlas2.numFrames);
		Assert.areEqual(atlas2.numFrames, 4);

		for (frame in atlasXml.frames)
		{
			final frame2 = atlas2.getByName(frame.name);
			Assert.isTrue(frame.sourceSize.equals(frame2.sourceSize));
		}
	}
}
