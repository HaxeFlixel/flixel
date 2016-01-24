package;

import flixel.addons.display.FlxPieDial;
import flixel.addons.display.FlxPieDial.FlxPieDialShape;
import flixel.tweens.FlxTween;
import flixel.FlxState;
import flixel.util.FlxColor;

/**
 * ...
 * @author larsiusprime
 */
class DemoState extends FlxState
{

	public override function create():Void
	{
		super.create();
		
		var xx:Float = 10;
		var yy:Float = 10;
		
		//Circular pie dials
		
		var CIRCLE = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.CIRCLE);
		CIRCLE.amount = 0.25;
		add(CIRCLE);
		
		xx += 100;
		
		var CIRCLE2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.CIRCLE);
		CIRCLE2.amount = 0.50;
		add(CIRCLE2);
		
		xx += 100;
		
		var CIRCLE3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.CIRCLE);
		CIRCLE3.amount = 0.75;
		add(CIRCLE3);
		
		xx += 100;
		
		var CIRCLE4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.CIRCLE);
		CIRCLE4.amount = 1.0;
		add(CIRCLE4);
		
		xx += 100;
		
		var backCIRCLE = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.CIRCLE, false);
		backCIRCLE.amount = 0.25;
		add(backCIRCLE);
		
		xx += 100;
		
		var backCIRCLE2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.CIRCLE, false);
		backCIRCLE2.amount = 0.50;
		add(backCIRCLE2);
		
		xx += 100;
		
		var backCIRCLE3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.CIRCLE, false);
		backCIRCLE3.amount = 0.75;
		add(backCIRCLE3);
		
		xx += 100;
		
		var backCIRCLE4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.CIRCLE, false);
		backCIRCLE4.amount = 1.0;
		add(backCIRCLE4);
		
		xx  =  25;
		yy += 100;
		
		//SQUARE-ular pie dials
		
		var SQUARE = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.SQUARE);
		SQUARE.amount = 0.25;
		add(SQUARE);
		
		xx += 100;
		
		var SQUARE2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.SQUARE);
		SQUARE2.amount = 0.50;
		add(SQUARE2);
		
		xx += 100;
		
		var SQUARE3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.SQUARE);
		SQUARE3.amount = 0.75;
		add(SQUARE3);
		
		xx += 100;
		
		var SQUARE4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.SQUARE);
		SQUARE4.amount = 1.00;
		add(SQUARE4);
		
		xx += 100;
		
		var backSQUARE = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.SQUARE, false);
		backSQUARE.amount = 0.25;
		add(backSQUARE);
		
		xx += 100;
		
		var backSQUARE2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.SQUARE, false);
		backSQUARE2.amount = 0.50;
		add(backSQUARE2);
		
		xx += 100;
		
		var backSQUARE3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.SQUARE, false);
		backSQUARE3.amount = 0.75;
		add(backSQUARE3);
		
		xx += 100;
		
		var backSQUARE4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.SQUARE, false);
		backSQUARE4.amount = 1.00;
		add(backSQUARE4);
		
		xx  =  25;
		yy += 100;
		
		//Donut-ular pie dials
		
		var donut = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.CIRCLE, true, 12);
		donut.amount = 0.25;
		add(donut);
		
		xx += 100;
		
		var donut2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.CIRCLE, true, 12);
		donut2.amount = 0.50;
		add(donut2);
		
		xx += 100;
		
		var donut3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.CIRCLE, true, 12);
		donut3.amount = 0.75;
		add(donut3);
		
		xx += 100;
		
		var donut4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.CIRCLE, true, 12);
		donut4.amount = 1.0;
		add(donut4);
		
		xx += 100;
		
		var backdonut = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.CIRCLE, false, 12);
		backdonut.amount = 0.25;
		add(backdonut);
		
		xx += 100;
		
		var backdonut2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.CIRCLE, false, 12);
		backdonut2.amount = 0.50;
		add(backdonut2);
		
		xx += 100;
		
		var backdonut3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.CIRCLE, false, 12);
		backdonut3.amount = 0.75;
		add(backdonut3);
		
		xx += 100;
		
		var backdonut4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.CIRCLE, false, 12);
		backdonut4.amount = 1.0;
		add(backdonut4);
		
		xx  =  50;
		yy += 100;
		
		//SQUARE donut-ular pie dials:
		
		var SQUAREdonut = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.SQUARE, true, 12);
		SQUAREdonut.amount = 0.25;
		add(SQUAREdonut);
		
		xx += 100;
		
		var SQUAREdonut2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.SQUARE, true, 12);
		SQUAREdonut2.amount = 0.50;
		add(SQUAREdonut2);
		
		xx += 100;
		
		var SQUAREdonut3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.SQUARE, true, 12);
		SQUAREdonut3.amount = 0.75;
		add(SQUAREdonut3);
		
		xx += 100;
		
		var SQUAREdonut4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.SQUARE, true, 12);
		SQUAREdonut4.amount = 1.0;
		add(SQUAREdonut4);
		
		xx += 100;
		
		var backSQUAREdonut = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.SQUARE, false, 12);
		backSQUAREdonut.amount = 0.25;
		add(backSQUAREdonut);
		
		xx += 100;
		
		var backSQUAREdonut2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.SQUARE, false, 12);
		backSQUAREdonut2.amount = 0.50;
		add(backSQUAREdonut2);
		
		xx += 100;
		
		var backSQUAREdonut3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.SQUARE, false, 12);
		backSQUAREdonut3.amount = 0.75;
		add(backSQUAREdonut3);
		
		xx += 100;
		
		var backSQUAREdonut4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.SQUARE, false, 12);
		backSQUAREdonut4.amount = 1.0;
		add(backSQUAREdonut4);
		
		xx  =  50;
		yy += 100;
		
		//Tweened pie dial
		
		var pieDial = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 36, FlxPieDialShape.SQUARE, false, 10);
		pieDial.amount = 0.0;
		add(pieDial);
		
		FlxTween.tween(pieDial, { amount:1.0 }, 2.0).wait(1).then(FlxTween.tween(pieDial, { amount:0.0 }, 2.0)).wait(0).then(FlxTween.tween(pieDial, { amount:1.0 }, 2.0));
	}
}