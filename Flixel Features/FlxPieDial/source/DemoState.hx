package ;
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
		
		var circle = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.Circle);
		circle.amount = 0.25;
		add(circle);
		
		xx += 100;
		
		var circle2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.Circle);
		circle2.amount = 0.50;
		add(circle2);
		
		xx += 100;
		
		var circle3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.Circle);
		circle3.amount = 0.75;
		add(circle3);
		
		xx += 100;
		
		var circle4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.Circle);
		circle4.amount = 1.0;
		add(circle4);
		
		xx += 100;
		
		var backCircle = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.Circle, false);
		backCircle.amount = 0.25;
		add(backCircle);
		
		xx += 100;
		
		var backCircle2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.Circle, false);
		backCircle2.amount = 0.50;
		add(backCircle2);
		
		xx += 100;
		
		var backCircle3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.Circle, false);
		backCircle3.amount = 0.75;
		add(backCircle3);
		
		xx += 100;
		
		var backCircle4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.Circle, false);
		backCircle4.amount = 1.0;
		add(backCircle4);
		
		xx  =  25;
		yy += 100;
		
		//Square-ular pie dials
		
		var square = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.Square);
		square.amount = 0.25;
		add(square);
		
		xx += 100;
		
		var square2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.Square);
		square2.amount = 0.50;
		add(square2);
		
		xx += 100;
		
		var square3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.Square);
		square3.amount = 0.75;
		add(square3);
		
		xx += 100;
		
		var square4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.Square);
		square4.amount = 1.00;
		add(square4);
		
		xx += 100;
		
		var backsquare = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.Square, false);
		backsquare.amount = 0.25;
		add(backsquare);
		
		xx += 100;
		
		var backsquare2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.Square, false);
		backsquare2.amount = 0.50;
		add(backsquare2);
		
		xx += 100;
		
		var backsquare3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.Square, false);
		backsquare3.amount = 0.75;
		add(backsquare3);
		
		xx += 100;
		
		var backsquare4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.Square, false);
		backsquare4.amount = 1.00;
		add(backsquare4);
		
		xx  =  25;
		yy += 100;
		
		//Donut-ular pie dials
		
		var donut = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.Circle, true, 12);
		donut.amount = 0.25;
		add(donut);
		
		xx += 100;
		
		var donut2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.Circle, true, 12);
		donut2.amount = 0.50;
		add(donut2);
		
		xx += 100;
		
		var donut3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.Circle, true, 12);
		donut3.amount = 0.75;
		add(donut3);
		
		xx += 100;
		
		var donut4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.Circle, true, 12);
		donut4.amount = 1.0;
		add(donut4);
		
		xx += 100;
		
		var backdonut = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.Circle, false, 12);
		backdonut.amount = 0.25;
		add(backdonut);
		
		xx += 100;
		
		var backdonut2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.Circle, false, 12);
		backdonut2.amount = 0.50;
		add(backdonut2);
		
		xx += 100;
		
		var backdonut3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.Circle, false, 12);
		backdonut3.amount = 0.75;
		add(backdonut3);
		
		xx += 100;
		
		var backdonut4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.Circle, false, 12);
		backdonut4.amount = 1.0;
		add(backdonut4);
		
		xx  =  50;
		yy += 100;
		
		//Square donut-ular pie dials:
		
		var squaredonut = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.Square, true, 12);
		squaredonut.amount = 0.25;
		add(squaredonut);
		
		xx += 100;
		
		var squaredonut2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.Square, true, 12);
		squaredonut2.amount = 0.50;
		add(squaredonut2);
		
		xx += 100;
		
		var squaredonut3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.Square, true, 12);
		squaredonut3.amount = 0.75;
		add(squaredonut3);
		
		xx += 100;
		
		var squaredonut4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.Square, true, 12);
		squaredonut4.amount = 1.0;
		add(squaredonut4);
		
		xx += 100;
		
		var backsquaredonut = new FlxPieDial(xx, yy, 25, FlxColor.RED, 72, FlxPieDialShape.Square, false, 12);
		backsquaredonut.amount = 0.25;
		add(backsquaredonut);
		
		xx += 100;
		
		var backsquaredonut2 = new FlxPieDial(xx, yy, 25, FlxColor.BLUE, 72, FlxPieDialShape.Square, false, 12);
		backsquaredonut2.amount = 0.50;
		add(backsquaredonut2);
		
		xx += 100;
		
		var backsquaredonut3 = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 72, FlxPieDialShape.Square, false, 12);
		backsquaredonut3.amount = 0.75;
		add(backsquaredonut3);
		
		xx += 100;
		
		var backsquaredonut4 = new FlxPieDial(xx, yy, 25, FlxColor.WHITE, 72, FlxPieDialShape.Square, false, 12);
		backsquaredonut4.amount = 1.0;
		add(backsquaredonut4);
		
		xx  =  50;
		yy += 100;
		
		//Tweened pie dial
		
		var pieDial = new FlxPieDial(xx, yy, 25, FlxColor.LIME, 36, FlxPieDialShape.Square, false, 10);
		pieDial.amount = 0.0;
		add(pieDial);
		
		FlxTween.tween(pieDial, { amount:1.0 }, 2.0).wait(1).then(FlxTween.tween(pieDial, { amount:0.0 }, 2.0)).wait(0).then(FlxTween.tween(pieDial, { amount:1.0 }, 2.0));
	}
}