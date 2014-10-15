package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxBarFrames;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.graphics.frames.FlxClippedFrames;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.tile.FlxTileblock;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import flixel.util.FlxColor;
import openfl.Assets;
import openfl.filters.BlurFilter;
import openfl.filters.GlowFilter;

class PlayState extends FlxState
{
	override public function create():Void
	{
		FlxG.camera.bgColor = FlxColor.WHITE;
		
		// Lets see how thing changed with graphics loading:
		
		// FlxTileFrames are usefull for sprites (with spritesheets) and tilemaps
		// There are several static methods for creating tiles, but most generic is fromRectangle(), which takes:
		// - image to use as a source (could be string path to asset, BitmapData or FlxGraphic object)
		// - tile size
		// - region - rectangulat area of image to use for tiles. Default value is null, which means that whole image will be used
		// - tileSpacing - spaces between tile images on source image. Default value is null, which means no spaces.
		var tileFrames:FlxTileFrames = FlxTileFrames.fromRectangle("assets/area02_level_tiles2.png", new FlxPoint(16, 16));
		
		// let's load these frames into tilemap:
		var tilemap:FlxTilemap = new FlxTilemap();
		tilemap.loadMapFromCSV("assets/mapCSV_Group1_Map1.csv", tileFrames);
		add(tilemap);
		
		// you can load tile frames in sprites with frames setter:
		var player:FlxSprite = new FlxSprite(0, 0);
		var playerFrames:FlxTileFrames = FlxTileFrames.fromRectangle("assets/lizardhead3.png", new FlxPoint(16, 20));
		player.frames = playerFrames;
		player.animation.add("walking", [0, 1, 2, 3], 12, true);
		// plus you can play animation backward now: there is third argument in play() method for it
		player.animation.play("walking", true, true);
		add(player);
		
		// FlxAtlasFrames collection is here if you want to use texture atlases in your projects.
		// It has several static methods for different atlas formats (Json, libGDX, Sparrow, etc.).
		// Here is example of how to load json texture atlas:
		var atlasFrames:FlxAtlasFrames = FlxAtlasFrames.fromTexturePackerJson("assets/test-trim-rotation.png", "assets/test-trim-rotation.json");
		// Let's load these frames into test sprite
		var atlasTest:FlxSprite = new FlxSprite(10, 200);
		atlasTest.frames = atlasFrames;
		add(atlasTest);
		atlasTest.color = FlxColor.MAGENTA;
		
		// You can generate tile frames from atlas frame:
		var testTiles:FlxTileFrames = FlxTileFrames.fromFrame(atlasFrames.getByName("100px-1,202,0,200-Scythescraper.png"), new FlxPoint(10, 10));
		
		// let's load result into sprites and place these sprites in grid
		var tileSprite:FlxSprite;
		var i:Int  = 0;
		for (y in 0...testTiles.numRows)
		{
			for (x in 0...testTiles.numCols)
			{
				tileSprite = new FlxSprite(x * testTiles.tileSize.x + 200, y * testTiles.tileSize.x + 0.5);
				tileSprite.frames = testTiles;
				tileSprite.animation.frameIndex = i++;
				tileSprite.pixelPerfectRender = false;
				add(tileSprite);
				tileSprite.immovable = true;
			}
		}
		
		// there is a special frames collection for progress bars (just in case if you need it), but mostly you'll be using FlxBars for it and these frames collections will be generated automatically
		var barFramesAxe:FlxBarFrames = FlxBarFrames.fromFrame(atlasFrames.getByName("100px-1,202,0,200-Scythescraper.png"), 
			FlxBarFillDirection.VERTICAL_INSIDE_OUT);
		
		var axeBar:FlxSprite = new FlxSprite(10, 300);
		axeBar.frames = barFramesAxe;
		axeBar.antialiasing = true;
		
		var animationFrames:Array<Int> = [];
		for (i in 0...100)
		{
			animationFrames.push(i);
		}
		
		axeBar.animation.add("bar", animationFrames);
		axeBar.animation.play("bar");
		add(axeBar);
		
		// Let's try bitmap text and bitmap font, which is another one type of frames collection
		var bitmapText:FlxBitmapText = new FlxBitmapText();
		
		var font:FlxBitmapFont = FlxBitmapFont.fromAngelCode("assets/NavTitle.png", Xml.parse(Assets.getText("assets/NavTitle.fnt")));
		bitmapText.font = font;
		
		bitmapText.autoSize = true;
		bitmapText.multiLine = true;
		bitmapText.wrapByWord = true;
		bitmapText.text = "Math \n for game developers";
		bitmapText.y = 40;
		bitmapText.alignment = "center";
		add(bitmapText);
		
		// Experimental filters feature - filter frames collection
		var charSprite2:FlxSprite = new FlxSprite();
		charSprite2.x = 300;
		charSprite2.y = 50;
		
		var filterFrames:FlxFilterFrames = FlxFilterFrames.fromFrames(atlasFrames, 10, 10);
		filterFrames.addFilter(new BlurFilter());
		
		charSprite2.frames = filterFrames;
		charSprite2.animation.frameName = ("100px-1,202,0,200-Scythescraper.png");
		add(charSprite2);
		
		FlxG.debugger.drawDebug = true;
	}
}