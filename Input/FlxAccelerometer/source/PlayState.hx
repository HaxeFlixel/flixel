package;

import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import nape.geom.Vec2;

class PlayState extends FlxNapeState
{
	private static inline var GRAVITY_FACTOR:Int = 5000; 
	
	private var xText:FlxText;
	private var yText:FlxText;
	private var zText:FlxText;
	
	override public function create():Void
	{
		super.create();
		
		createWalls();
		FlxNapeState.space.gravity = Vec2.get(0, GRAVITY_FACTOR);
		
		for (i in 0...50) 
		{
			var box = new Box(FlxG.random.int(0, FlxG.width - 30), FlxG.random.int(0, FlxG.height - 30));
			box.body.space = FlxNapeState.space;
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
	}
	
	override public function update():Void
	{
		super.update();
		
		#if mobile
		if (FlxG.accelerometer.isSupported) 
		{
			//Display the accelerometer values rounded to the first decimal number
			xText.text = "x: " + FlxMath.roundDecimal(FlxG.accelerometer.x, 1);
			yText.text = "y: " + FlxMath.roundDecimal(FlxG.accelerometer.y, 1);
			zText.text = "z: " + FlxMath.roundDecimal(FlxG.accelerometer.z, 1);
			
			//Inverting the x axis to align the device and the screen coordinates
			FlxNapeState.space.gravity.setxy(-FlxG.accelerometer.x * GRAVITY_FACTOR, FlxG.accelerometer.y * GRAVITY_FACTOR);
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
		body.space = FlxNapeState.space;
		physicsEnabled = true;
	}
}