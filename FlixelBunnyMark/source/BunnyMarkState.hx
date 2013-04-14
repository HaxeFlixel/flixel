package;

import flash.ui.Mouse;
import nme.Assets;
import nme.display.Bitmap;
import nme.Lib;
import org.flixel.system.input.FlxAnalog;
import org.flixel.FlxButton;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxTileblock;
import org.flixel.plugin.pxText.FlxBitmapTextField;
import org.flixel.plugin.pxText.PxBitmapFont;
import org.flixel.plugin.pxText.PxButton;
import org.flixel.plugin.pxText.PxTextAlign;
import org.flixel.system.layer.Atlas;

/**
 * ...
 * @author Zaphod
 */
class BunnyMarkState extends FlxState
{
	private var numBunnies:Int;
	private var incBunnies:Int;

	public static var minX:Int;
	public static var minY:Int;
	public static var maxX:Int;
	public static var maxY:Int;

	private var gravity:Float;

	private var bunnies:FlxGroup;
	private var bunny:FlxSprite;
	private var pirate:FlxSprite;

	private var bg:FlxTileblock;
	private var bgSize:Int;

	private var addBunniesBtn:FlxButton;

	#if flash
	private var bunnyCounter:FlxText;
	private var fpsCounter:FlxText;
	#else
	private var bunnyCounter:FlxBitmapTextField;
	private var fpsCounter:FlxBitmapTextField;
	#end

	private var times:Array<Float>;

	public function new()
	{
		gravity = 5;
		incBunnies = 100;
		#if flash
		numBunnies = 100;
		#else
		numBunnies = 500;
		#end

		bgSize = 32;

		minX = minY = 0;
		maxX = FlxG.width;
		maxY = FlxG.height;

		super();
	}

	override public function create():Void
	{
		#if flash
		FlxG.framerate = 30;
		FlxG.flashFramerate = 30;
		#else
		FlxG.framerate = 60;
		FlxG.flashFramerate = 60;
		#end

		var bgWidth:Int = Math.ceil(FlxG.width / bgSize) * bgSize;
		var bgHeight:Int = Math.ceil(FlxG.height / bgSize) * bgSize;

		bg = new FlxTileblock(0, 0, bgWidth, bgHeight);
		bg.loadTiles("assets/grass.png");
		bg.cameras = [FlxG.camera];
		add(bg);

		bunnies = new FlxGroup();
		addBunnies(numBunnies);
		add(bunnies);

		pirate = new FlxSprite();
		pirate.loadGraphic("assets/pirate.png");
		pirate.cameras = [FlxG.camera];
		add(pirate);

		addBunniesBtn = new FlxButton(2000, 2000, "Add Bunnies", onAddBunnies);
		add(addBunniesBtn);
		var btnCam:FlxCamera = new FlxCamera(10, (FlxG.height - 50), Math.floor(addBunniesBtn.width), Math.floor(addBunniesBtn.height), 2);
		btnCam.follow(addBunniesBtn, FlxCamera.STYLE_NO_DEAD_ZONE);
		addBunniesBtn.cameras = [btnCam];
		addBunniesBtn.label.cameras = [btnCam];
		FlxG.addCamera(btnCam);

		#if flash
		bunnyCounter = new FlxText(0, 10, FlxG.width, "Bunnies: " + numBunnies);
		bunnyCounter.setFormat(null, 22, 0x000000, "center");

		fpsCounter = new FlxText(0, bunnyCounter.y + bunnyCounter.height + 10, FlxG.width, "FPS: " + 30);
		fpsCounter.setFormat(null, 22, 0x000000, "center");
		#else
		var font:PxBitmapFont = new PxBitmapFont();
		font.loadPixelizer(Assets.getBitmapData("assets/data/fontData11pt.png"), " !\"#$%&'()*+,-./" + "0123456789:;<=>?" + "@ABCDEFGHIJKLMNO" + "PQRSTUVWXYZ[]^_" + "abcdefghijklmno" + "pqrstuvwxyz{|}~\\`");
		bunnyCounter = new FlxBitmapTextField(font);
		bunnyCounter.y = 10;
		bunnyCounter.setWidth(FlxG.width);
		bunnyCounter.alignment = PxTextAlign.CENTER;
		bunnyCounter.fontScale = 2;
		bunnyCounter.text = "Bunnies: " + numBunnies;

		fpsCounter = new FlxBitmapTextField(font);
		fpsCounter.setWidth(FlxG.width);
		fpsCounter.y = bunnyCounter.y + bunnyCounter.height + 10;
		fpsCounter.alignment = PxTextAlign.CENTER;
		fpsCounter.fontScale = 2;
		fpsCounter.text = "FPS: " + 30;
		fpsCounter.multiLine = true;
		#end

		bunnyCounter.cameras = [FlxG.camera];
		fpsCounter.cameras = [FlxG.camera];

		add(bunnyCounter);
		add(fpsCounter);

		times = [];

		Mouse.hide();
		#if !mobile
		FlxG.mouse.show();
		#end

		#if (cpp || neko)
		var myAtlas:Atlas = createAtlas("myAtlas", 1024, 512);
		bg.atlas = myAtlas;
		bunnies.atlas = myAtlas;
		pirate.atlas = myAtlas;
		bunnyCounter.atlas = myAtlas;
		fpsCounter.atlas = myAtlas;
		addBunniesBtn.atlas = myAtlas;
		#end
	}

	private function addBunnies(numToAdd:Int):Void
	{
		for (i in 0...(numToAdd))
		{
			bunny = new Bunny(gravity);
			bunnies.add(bunny);
		}
	}

	private function onAddBunnies():Void
	{
		if (numBunnies >= 1500)
		{
			incBunnies = 250;
		}
		var more = numBunnies + incBunnies;

		addBunnies(incBunnies);

		numBunnies = more;
		bunnyCounter.text = "Bunnies: " + numBunnies;
	}

	override public function update():Void
	{
		super.update();

		var t = Lib.getTimer();
		pirate.x = Std.int((FlxG.width - pirate.width) * (0.5 + 0.5 * Math.sin(t / 3000)));
		pirate.y = Std.int(FlxG.height - 1.3 * pirate.height + 70 - 30 * Math.sin(t / 100));

		var now:Float = t / 1000;
		times.push(now);
		while(times[0] < now - 1)
		{
			times.shift();
		}

		fpsCounter.text = FlxG.width + "x" + FlxG.height + "\nFPS: " + times.length + "/" + Lib.current.stage.frameRate;
	}

}
