package;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.ui.FlxBar;

class AnalogWidget extends FlxSpriteGroup
{
	public var xPos:Float = 0;
	public var xNeg:Float = 0;
	public var yPos:Float = 0;
	public var yNeg:Float = 0;
	public var l:Float = 0;
	public var r:Float = 0;

	var xAxisPos:FlxBar;
	var yAxisPos:FlxBar;
	var xAxisNeg:FlxBar;
	var yAxisNeg:FlxBar;
	var lBar:FlxBar;
	var rBar:FlxBar;
	
	public function new() 
	{
		super();
		
		xAxisPos = new FlxBar(0, 0, FlxBarFillDirection.LEFT_TO_RIGHT, 64, 16, this, "xPos", 0.0, 1.0, true);
		xAxisNeg = new FlxBar(0, 0, FlxBarFillDirection.RIGHT_TO_LEFT, 64, 16, this, "xNeg", 0.0, 1.0, true);
		yAxisPos = new FlxBar(0, 0, FlxBarFillDirection.TOP_TO_BOTTOM, 16, 64, this, "yPos", 0.0, 1.0, true);
		yAxisNeg = new FlxBar(0, 0, FlxBarFillDirection.BOTTOM_TO_TOP, 16, 64, this, "yNeg", 0.0, 1.0, true);
		lBar = new FlxBar(0, 0, FlxBarFillDirection.BOTTOM_TO_TOP, 16, 144, this, "l", 0.0, 1.0, true);
		rBar = new FlxBar(0, 0, FlxBarFillDirection.BOTTOM_TO_TOP, 16, 144, this, "r", 0.0, 1.0, true);
		
		xAxisPos.x =  (xAxisPos.height) / 2;
		xAxisPos.y = -(xAxisPos.height) / 2;
		
		xAxisNeg.x = -(xAxisNeg.width) - (xAxisPos.height / 2);
		xAxisNeg.y = -(xAxisNeg.height) / 2;
		
		yAxisPos.x = -(yAxisPos.width) / 2;
		yAxisPos.y =  (yAxisNeg.width / 2);
		
		yAxisNeg.x = -(yAxisNeg.width) / 2;
		yAxisNeg.y = -(yAxisPos.height) - (yAxisPos.width / 2);
		
		lBar.x = xAxisNeg.x - lBar.width - 8;
		rBar.x = xAxisPos.x + xAxisPos.width + 8;
		lBar.y = rBar.y = yAxisNeg.y;
		
		add(xAxisPos);
		add(xAxisNeg);
		add(yAxisPos);
		add(yAxisNeg);
		add(lBar);
		add(rBar);
		
		var xoff = FlxG.width - width/2 - 5;
		var yoff = FlxG.height - height/2 - 5;
		
		x = xoff;
		y = yoff;
	}

	public function setValues(X:Float, Y:Float):Void
	{
		xPos = 0;
		xNeg = 0;
		yPos = 0;
		yNeg = 0;
		
		if (X > 0) xPos = X;
		else xNeg = -X;
		
		if (Y > 0) yPos = Y;
		else yNeg = -Y;
	}
}