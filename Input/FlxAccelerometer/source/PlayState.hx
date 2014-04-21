package;

import flixel.addons.nape.FlxNapeState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxRandom;
import nape.geom.Vec2;
import flixel.input.FlxAccelerometer;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxNapeState
{
	private var xText:FlxText;
	private var yText:FlxText;
	private var zText:FlxText;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		createWalls();
		FlxNapeState.space.gravity = Vec2.get(0, 5000);
		
		for (i in 0...20) {
			var box:Box = new Box(FlxRandom.intRanged(0, FlxG.width - 30), FlxRandom.intRanged(0, FlxG.height - 30));
			box.body.space = FlxNapeState.space;
			add(box);
		}
		
		xText = new FlxText(0, 20, FlxG.width, "x", 30);
		xText.alignment = "center";
		yText = new FlxText(0, xText.frameHeight + 30, FlxG.width, "y", 30);
		yText.alignment = "center";
		zText = new FlxText(0, xText.frameHeight + yText.frameHeight + 40, FlxG.width, "z", 30);
		zText.alignment = "center";
		
		add(xText);
		add(yText);
		add(zText);
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		if (FlxG.accelerometer.isSupported) 
		{
			//Display the accelerometer values rounded to the first decimal number
			xText.text = "x: " + Std.string(Math.round(FlxG.accelerometer.x * 10) / 10);
			yText.text = "y: " + Std.string(Math.round(FlxG.accelerometer.y * 10) / 10);
			zText.text = "z: " + Std.string(Math.round(FlxG.accelerometer.z * 10) / 10);
			
			//Inverting the x axis to align the device and the screen coordinates
			FlxNapeState.space.gravity.setxy(-FlxG.accelerometer.x * 5000, FlxG.accelerometer.y * 5000);
		}
	}	
}