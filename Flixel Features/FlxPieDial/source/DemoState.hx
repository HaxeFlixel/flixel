package;

import flixel.addons.display.FlxPieDial;
import flixel.addons.display.FlxPieDial.FlxPieDialShape;
import flixel.tweens.FlxTween;
import flixel.FlxState;
import flixel.util.FlxColor;

class DemoState extends FlxState
{
	public override function create():Void
	{
		super.create();
		
		var i:Int = 0;
		var x:Float = 10;
		var y:Float = 10;
		var shape:FlxPieDialShape = CIRCLE;
		var clockwise:Bool = false;
		var innerRadius:Int = 0;
		
		var createDial = function()
		{
			var colors = [FlxColor.RED, FlxColor.BLUE, FlxColor.LIME, FlxColor.WHITE];
			var amounts = [0.25, 0.50, 0.75, 1.00];
			
			var dial = new FlxPieDial(x, y, 25, colors[i], 72, shape, clockwise, innerRadius);
			dial.amount = amounts[i]; 
			add(dial);
			x += 100;
			
			i++;
			if (i > 3)
				i = 0;
			return dial;
		}
		
		var createFour = function()
		{
			for (_ in 0...4)
				createDial();
		}
		
		var nextLine = function()
		{
			x = 10;
			y += 100;
		}
		
		//Circular pie dials
		shape = CIRCLE;
		clockwise = true;
		createFour();
		
		clockwise = false;
		createFour();
		
		nextLine();
		
		//Square-ular pie dials
		shape = SQUARE;
		clockwise = true;
		createFour();
		
		clockwise = false;
		createFour();
		
		nextLine();
		
		//Donut-ular pie dials
		shape = CIRCLE;
		clockwise = true;
		innerRadius = 12;
		createFour();
		
		clockwise = false;
		createFour();
		
		nextLine();
		
		//Square donut-ular pie dials
		shape = SQUARE;
		clockwise = true;
		createFour();
		
		clockwise = false;
		createFour();
		
		nextLine();
		
		//Tweened pie dial
		var pieDial = new FlxPieDial(25, y, 25, FlxColor.LIME, 36, FlxPieDialShape.SQUARE, false, 10);
		pieDial.amount = 0.0;
		add(pieDial);
		
		FlxTween.tween(pieDial, { amount: 1.0 }, 2.0, { type: FlxTween.PINGPONG });
	}
}