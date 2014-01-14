package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.loaders.TexturePackerData;

class MenuState extends FlxState
{
	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff131c1b;
		FlxG.mouse.show();
		
		// TexturePackerData is a helper class to store links to atlas image and atlas data files
		var tex1 = new TexturePackerData(	"assets/test-trim-rotation.json", 
											"assets/test-trim-rotation.png");
		// Create some sprite
		var x1:FlxSprite = new FlxSprite(20, 20);
		// and loading atlas in it finally
		x1.loadImageFromTexture(	tex1, 
									true, 
									true, 
									"100px-1,202,0,200-Scythescraper.png");
		
		x1.angularVelocity = 50;
		x1.facing = FlxObject.LEFT;
		add(x1);
		
		// Let's create some more atlases (just for testing of rotation and trim support)
		var tex2 = new TexturePackerData("assets/test-rotation.json", "assets/test-rotation.png");
		var tex3 = new TexturePackerData("assets/test-trim.json", "assets/test-trim.png");
		var tex4 = new TexturePackerData("assets/test.json", "assets/test.png");
		var tex5 = new TexturePackerData("assets/anim-trim.json", "assets/anim-trim.png");
		
		// You can provide first frame to show (see last parameter in loadImageFromTexture() method)
		// Plus you can generate reversed sprites which is useful for animating character in games
		var x1:FlxSprite = new FlxSprite(20, 20);
		x1.loadImageFromTexture(tex3, true, false, "100px-1,202,0,200-Scythescraper.png");
		x1.resetSizeFromFrame();
		x1.setOriginToCenter();
		x1.angularVelocity = 50;
		add(x1);
		
		// You can load rotated image from atlas. It is very useful for flash target where drawing rotated graphics is very expensive
		var x2:FlxSprite = new FlxSprite(20, 200);
		x2.loadRotatedImageFromTexture(tex2, "100px-1,202,0,200-Scythescraper.png", 72, true, true);
		x2.color = 0xff0000;
		x2.angularVelocity = 50;
		add(x2);
		
		// You can set sprite's frame by using image name in atlas
		var x3:FlxSprite = new FlxSprite(200, 20);
		x3.loadImageFromTexture(tex3, true);
		x3.animation.frameName = "super_element_50px_0.png";
		x3.resetSizeFromFrame();
		x3.setOriginToCenter();
		x3.facing = FlxObject.LEFT;
		add(x3);
		
		// Animation samples:
		// There are new three methods for adding animation in sprite with TexturePackerData 
		// The old one is still working also
		
		// 1. The first one requires array with names of images from the atlas:
		var x5:FlxSprite = new FlxSprite(300, 20);
		x5.loadImageFromTexture(tex5);
		// Array with frame names in animation
		var names:Array<String> = new Array<String>();
		for (i in 0...20)
		{
			names.push("tiles-" + i + ".png");
		}
		
		x5.animation.addByNames("Animation", names, 8);
		x5.animation.play("Animation");
		add(x5);
		
		// 2. The second one requires three additional parameters: image name prefix, array of frame indicies and image name postfix
		var x6:FlxSprite = new FlxSprite(300, 200);
		x6.loadImageFromTexture(tex5);
		// Array with frame indicies in animation
		var indicies:Array<Int> = new Array<Int>();
		for (i in 0...20)
		{
			indicies.push(i);
		}
		
		x6.animation.addByIndicies("Animation", "tiles-", indicies, ".png", 8);
		x6.animation.play("Animation", false, 1);
		add(x6);
		
		// And the third one requires only image name prefix and it will sort and add all frames with it to animation
		var x7:FlxSprite = new FlxSprite(120, 200);
		x7.loadImageFromTexture(tex5);
		x7.animation.addByPrefix("ani", "tiles-", 8);
		x7.animation.play("ani");
		x7.angle = 45;
		add(x7);
		
		// Remove atlas bitmaps from memory (useful for targets with hardware acceleration: cpp only atm).
		FlxG.bitmap.dumpCache();
	}
}
