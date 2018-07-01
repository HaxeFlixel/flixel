package;

import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import nape.geom.Vec2;
#if mobile
import flixel.math.FlxMath;
#end

class PlayState extends FlxState
{
	static inline var GRAVITY_FACTOR:Int = 5000; 
	
	var xText:FlxText;
	var yText:FlxText;
	var zText:FlxText;
	
	override public function create():Void
	{
		FlxNapeSpace.init();
		
		FlxNapeSpace.createWalls();
		FlxNapeSpace.space.gravity = Vec2.get(0, GRAVITY_FACTOR);
		
		for (i in 0...50)
		{
			var box = new Box(FlxG.random.int(0, FlxG.width - 30), FlxG.random.int(0, FlxG.height - 30));
			box.body.space = FlxNapeSpace.space;
			add(box);
		}
		
		xText = new FlxText(0, 20, FlxG.width, "x", 30);
		xText.alignment = CENTER;
		yText = new FlxText(0, xText.frameHeight + 30, FlxG.width, "y", 30);
		yText.alignment = CENTER;
		zText = new FlxText(0, xText.frameHeight + yText.frameHeight + 40, FlxG.width, "z", 30);
		zText.alignment = CENTER;
		
		add(xText);
		add(yText);
		add(zText);
		
		#if !mobile
		xText.text = "FlxG.accelerometer is only available on mobile targets!";
		yText.text = zText.text = "";
		#end
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		#if mobile
		if (FlxG.accelerometer.isSupported)
		{
			//Display the accelerometer values rounded to the first decimal number
			xText.text = "x: " + FlxMath.roundDecimal(FlxG.accelerometer.x, 1);
			yText.text = "y: " + FlxMath.roundDecimal(FlxG.accelerometer.y, 1);
			zText.text = "z: " + FlxMath.roundDecimal(FlxG.accelerometer.z, 1);
			
			//Inverting the x axis to align the device and the screen coordinates
			FlxNapeSpace.space.gravity.setxy(FlxG.accelerometer.x * GRAVITY_FACTOR, FlxG.accelerometer.y * GRAVITY_FACTOR);
		}
		#end
	}	
}

class Box extends FlxNapeSprite
{
	public function new(X:Float, Y:Float)
	{
		super(X, Y);
		makeGraphic(30, 30, FlxG.random.color());
		createRectangularBody(30, 30);
		setBodyMaterial(0.5, 0.5, 0.5, 2);
		body.space = FlxNapeSpace.space;
		physicsEnabled = true;
	}
}