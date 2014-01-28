package;

import flash.display.BitmapData;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.Lib;
import flash.utils.ByteArray;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxTypedGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxBitmapUtil;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	private var _display:FlxText;
	private var _colorTest:FlxSprite;
	private var _histogram:FlxSprite;
	private var _noise:FlxSprite;
	private var _buttonGroup:FlxTypedGroup<FlxButton>;
	
	private var dummyInt:Int = 0;
	private var dummyFloat:Float = 0;
	private var dummyString:String = "";
	private var dummyBitmapdata:BitmapData;
	private var dummyByteArray:ByteArray;
	private var dummyRect:Rectangle;
	private var dummyText:FlxText;
	private var timer:Int = 0;
	private var _static:Bool = false;
	private var _staticBitmapdata:BitmapData;
	
	inline static private var ONEMIL:Int = 1000000;
	inline static private var TENMIL:Int = 10000000;
	
	inline static private function BUTTON_TEXT():Array<String>
	{
		return [ "Reset Seed", "10m Int", "10m Float", "10m IntRanged", "10m FloatRanged", "10m Coin Flips", "10m Weighted Coin Flips",
					"10m Signs", "1m Weighted Picks", "1m Objects", "1m Weighted Objects", "1m Array Shuffles", "307k Colors",
					"307k ColorX" ];
	}
	
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		
		var area = new FlxSprite( 5, 5 );
		area.makeGraphic( FlxG.width - 200, FlxG.height - 10, 0x88000000 );
		
		_buttonGroup = new FlxTypedGroup<FlxButton>();
		
		var buttonX:Int = Std.int( area.x + area.width + 5 );
		var buttonY:Int = Std.int( area.y );
		
		for ( i in 0...BUTTON_TEXT().length )
		{
			var button = new FlxButton( buttonX, buttonY, BUTTON_TEXT()[i], buttonCallback.bind(BUTTON_TEXT()[i]));
			button.makeGraphic( 185, 20, 0x88DDDDDD );
			_buttonGroup.add( button );
			
			buttonY += 25;
		}
		
		_display = new FlxText( 10, 10, FlxG.width - 210, "Welcome to the FlxRandom demo!\nYour randomly generated seed is: " + FlxRandom.globalSeed );
		
		_colorTest = new FlxSprite( 0, 0 );
		_colorTest.makeGraphic( 1, 1, 0 );
		dummyBitmapdata = new BitmapData( 1, 1, false, 0 );
		dummyText = new FlxText( 0, 0, 20, "000" );
		
		_histogram = new FlxSprite( 10, 320 );
		_histogram.makeGraphic( 1, 1, 0 );
		
		/*
		_noise = new FlxSprite( buttonX, buttonY );
		_noise.makeGraphic( 185, FlxG.height - buttonY - 5, 0xffFF00FF );
		dummyByteArray = new ByteArray();
		dummyRect = new Rectangle( 0, 0, _noise.pixels.width, _noise.pixels.height );
		_staticBitmapdata = new BitmapData( 1, 1, false, 0 );
		_static = true;*/
		
		add( _colorTest );
		add( area );
		add( _display );
		add( _histogram );
		add( _buttonGroup );
		//add( _noise );
		
		super.create();
	}
	/*
	override public function update():Void
	{
		if ( _static )
		{
			dummyByteArray.clear();
			
			for ( i in 0...Std.int( _noise.width * _noise.height ) )
			{
				dummyByteArray.writeInt( FlxRandom.color( 0, 255, 255, true ) );
			}
			
			dummyByteArray.position = 0;
			_staticBitmapdata = new BitmapData( Std.int( _noise.width ), Std.int( _noise.height ), false, 0xffFF00FF );
			_staticBitmapdata.setPixels( _staticBitmapdata.rect, dummyByteArray );
			_noise.pixels = _staticBitmapdata;
		}
		
		super.update();
	}
	*/
	private function buttonCallback( Label:String ):Void
	{
		_display.text = "";
		_colorTest.visible = false;
		_histogram.visible = false;
		
		if ( Label == BUTTON_TEXT()[0] )
		{
			_display.text = "Your new randomly generated seed is: " + FlxRandom.resetGlobalSeed();
		}
		else if ( Label == BUTTON_TEXT()[1] )
		{
			intRandom();
		}
		else if ( Label == BUTTON_TEXT()[2] )
		{
			floatRandom();
		}
		else if ( Label == BUTTON_TEXT()[3] )
		{
			intRangedRandom();
		}
		else if ( Label == BUTTON_TEXT()[4] )
		{
			floatRangedRandom();
		}
		else if ( Label == BUTTON_TEXT()[5] )
		{
			coinFlips();
		}
		else if ( Label == BUTTON_TEXT()[6] )
		{
			coinFlipsWeighted();
		}
		else if ( Label == BUTTON_TEXT()[7] )
		{
			randomSigns();
		}
		else if ( Label == BUTTON_TEXT()[8] )
		{
			weightedPicks();
		}
		else if ( Label == BUTTON_TEXT()[9] )
		{
			getObjects();
		}
		else if ( Label == BUTTON_TEXT()[10] )
		{
			getObjectsWeighted();
		}
		else if ( Label == BUTTON_TEXT()[11] )
		{
			shuffleObj();
		}
		else if ( Label == BUTTON_TEXT()[12] )
		{
			randomColors();
		}
		else if ( Label == BUTTON_TEXT()[13] )
		{
			randomColorsExt();
		}
		//else if ( Label == BUTTON_TEXT()[14] )
		//{
		//	_static = !_static;
		//}
	}
	
	private function intRandom():Void
	{
		_display.text = "Randomly generating 10 million integers, please wait...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) dummyInt = FlxRandom.int();
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms.";
		
		_display.text += "\nRandomly generating 10 million integers without inlining, please wait...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) dummyInt = NonInlineFlxRandom.int();
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms.";
		
		_display.text += "\nRandomly generating 10 million integers the old way, please wait...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) dummyInt = OldFlxRandom.int();
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms.";
		
		_display.text += "\nRandomly generating 10 million integers using Math.random(), please wait...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) dummyInt = Std.int( Math.random() * 2147483647 );
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms.";
	}
	
	private function floatRandom():Void
	{
		_display.text = "Randomly generating 10 million floats, please wait...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) dummyFloat = FlxRandom.float();
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms.";
		
		_display.text += "\nRandomly generating 10 million floats without inlining, please wait...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) dummyFloat = NonInlineFlxRandom.float();
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms.";
		
		_display.text += "\nRandomly generating 10 million floats the old way, please wait...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) dummyFloat = OldFlxRandom.float();
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms.";
		
		_display.text += "\nRandomly generating 10 million floats using Math.random(), please wait...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) dummyFloat = Math.random();
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms.";
	}
	
	private function intRangedRandom():Void
	{
		_display.text = "Randomly generating 10 million integers from 0 to 19, excluding nothing, please wait...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) dummyInt = FlxRandom.intRanged( 0, 19 );
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms.";
		
		_display.text += "\nRandomly generating 10 million integers from 0 to 19, excluding 5, 10, and 15, please wait...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) dummyInt = FlxRandom.intRanged( 0, 19, [5,10,15] );
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms.";
		
		var results:Array<Int> = [ for ( i in 0...20 ) 0 ];
		_display.text += "\nRepeating previous analysis but storing results in an array to track random spread...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) results[ FlxRandom.intRanged( 0, 19, [ 5, 10, 15 ] ) ] ++;
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms. Displaying results...";
		
		createHistogram( [ for ( i in 0...results.length ) Std.string( i ) ], results );
	}
	
	private function createHistogram( Labels:Array<String>, ?Data:Array<Int>, ?DataFloat:Array<Float> ):Void
	{
		if ( Data != null )
		{
			dummyBitmapdata = new BitmapData( Data.length * 15 + 5, 100, true, 0xff222222 );
		}
		else
		{
			dummyBitmapdata = new BitmapData( DataFloat.length * 15 + 5, 100, true, 0xff222222 );
		}
		
		for ( i in 0...Labels.length )
		{
			if ( Data != null )
			{
				dummyRect = new Rectangle( i * 15 + 5, 5, 10, Data[i] / TENMIL * 1000 );
			}
			else
			{
				dummyRect = new Rectangle( i * 15 + 5, 5, 10, DataFloat[i] / TENMIL * 1000 );
			}
			
			dummyBitmapdata.fillRect( dummyRect, FlxRandom.color() );
			dummyText.text = Labels[i];
			dummyText.draw();
			dummyBitmapdata.draw( dummyText.pixels, new Matrix( 1, 0, 0, 1, i * 15 + 3, dummyRect.height + 10 ) );
		}
		
		_histogram.pixels = dummyBitmapdata;
		_histogram.visible = true;
	}
	
	private function floatRangedRandom():Void
	{
		_display.text = "Randomly generating 10 million floats from 0 to 19, excluding nothing, please wait...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) dummyFloat = FlxRandom.floatRanged( 0, 19 );
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms.";
		
		_display.text += "\nRandomly generating 10 million floats from 0 to 19, excluding 5, 10, and 15, please wait...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) dummyFloat = FlxRandom.floatRanged( 0, 19, [ 5, 10, 15 ] );
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms.";
		
		var results:Array<Float> = [ for ( i in 0...21 ) 0 ];
		_display.text += "\nRepeating previous analysis but storing results in an array to track random spread...";
		timer = Lib.getTimer();
		
		for ( i in 0...TENMIL )
		{
			dummyFloat = FlxRandom.floatRanged( 0, 19, [ 5, 10, 15 ] );
			
			if ( dummyFloat < 0 ) {
				results[0]++;
			} else if ( dummyFloat < 1 ) {
				results[1]++;
			} else if ( dummyFloat < 2 ) {
				results[2]++;
			} else if ( dummyFloat < 3 ) {
				results[3]++;
			} else if ( dummyFloat < 4 ) {
				results[4]++;
			} else if ( dummyFloat < 5 ) {
				results[5]++;
			} else if ( dummyFloat < 6 ) {
				results[6]++;
			} else if ( dummyFloat < 7 ) {
				results[7]++;
			} else if ( dummyFloat < 8 ) {
				results[8]++;
			} else if ( dummyFloat < 9 ) {
				results[9]++;
			} else if ( dummyFloat < 10 ) {
				results[10]++;
			} else if ( dummyFloat < 11 ) {
				results[11]++;
			} else if ( dummyFloat < 12 ) {
				results[12]++;
			} else if ( dummyFloat < 13 ) {
				results[13]++;
			} else if ( dummyFloat < 14 ) {
				results[14]++;
			} else if ( dummyFloat < 15 ) {
				results[15]++;
			} else if ( dummyFloat < 16 ) {
				results[16]++;
			} else if ( dummyFloat < 17 ) {
				results[17]++;
			} else if ( dummyFloat < 18 ) {
				results[18]++;
			} else if ( dummyFloat < 19 ) {
				results[19]++;
			} else {
				results[20]++;
			}
		}
		
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms. Displaying results...";
		
		createHistogram( [ for ( i in 0...results.length ) "<" + i ], null, results );
	}
	
	private function coinFlips():Void
	{
		var heads:Int = 0;
		var tails:Int = 0;
		_display.text = "Flipping a coin 10 million times...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) if ( FlxRandom.chanceRoll() ) heads++ else	tails++;
		
		_display.text += "\nDone. Got " + heads + " heads and " + tails + " tails. Time: " + ( Lib.getTimer() - timer ) + "ms.";
		
		if ( heads > tails )
		{
			_display.text += "\nHeads wins!";
		}
		else
		{
			_display.text += "\nTails wins!";
		}
	}
	
	private function coinFlipsWeighted():Void
	{
		var heads:Int = 0;
		var tails:Int = 0;
		var weight:Int = FlxRandom.intRanged( 0, 100 );
		_display.text = "Flipping a coin with a " + weight + "% chance of heads 10 million times...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) if ( FlxRandom.chanceRoll( weight ) ) heads++ else tails++;
		
		_display.text += "\nDone. Got " + heads + " heads and " + tails + " tails. Time: " + ( Lib.getTimer() - timer ) + "ms.";
		
		if ( heads > tails )
		{
			_display.text += "\nHeads wins!";
		}
		else
		{
			_display.text += "\nTails wins!";
		}
		
		if ( weight != 50 )
		{
			_display.text += " That doesn't seem fair.";
		}
	}
	
	private function randomSigns():Void
	{
		_display.text = "Selecting 10 million positive or negative signs...";
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) dummyInt = FlxRandom.sign();
		_display.text += "\nDone. Time: " + ( Lib.getTimer() - timer ) + "ms.";
	}
	
	private function weightedPicks():Void
	{
		var array:Array<Float> = [ for ( i in 0...10 ) FlxRandom.intRanged( 0, 99 ) ];
		var results:Array<Int> = [ for ( i in 0...array.length ) 0 ];
		
		_display.text = "Performing 1 million random picks from the array " + array + ".";
		
		var expectedResults:Array<Float> = [];
		var arrayTotal:Int = 0;
		
		for ( i in array ) arrayTotal += Std.int( i );
		for ( i in 0...array.length ) expectedResults.push( FlxMath.roundDecimal( 100 * array[i] / arrayTotal, 2 ) );
		
		_display.text += "\nExpected results (in percentages):\n" + expectedResults;
		timer = Lib.getTimer();
		
		for ( i in 0...ONEMIL ) results[ FlxRandom.weightedPick( array ) ] ++;
		
		var percentResults:Array<Float> = [ for ( i in 0...10 ) FlxMath.roundDecimal( 100 * results[i] / ONEMIL, 2 ) ];
		
		_display.text += "\nDone. Time: " + ( Lib.getTimer() - timer ) + "ms. Results (in percentages): \n" + percentResults;
	}
	
	private function getObjects():Void
	{
		var array:Array<Int> = [ for ( i in 0...20 ) i ];
		_display.text = "Getting a random object from an array of 20 integers 10 million times...";
		var results:Array<Int> = [ for( i in 0...20 ) 0 ];
		timer = Lib.getTimer();
		for ( i in 0...TENMIL ) results[ FlxRandom.getObject( array ) ]++;
		_display.text += "\nDone. Total time " + ( Lib.getTimer() - timer ) + "ms. Displaying results...";
		createHistogram( [ for ( i in 0...results.length ) ""+i ], results );
	}
	
	private function getObjectsWeighted():Void
	{
		var objectArray:Array<Int> = [ for ( i in 0...10 ) i ];
		var weightArray:Array<Float> = [ for ( i in 0...objectArray.length ) FlxRandom.intRanged( 0, 100 ) ];
		var expected:Array<Float> = [];
		var total:Int = 0;
		
		for ( i in weightArray ) total += Std.int( i );
		for ( i in 0...objectArray.length ) expected.push( FlxMath.roundDecimal( 100 * weightArray[i] / total, 2 ) );
		
		_display.text = "Getting one million objects from an array with weighted selection chance...";
		_display.text += "\nExpected results (in percentages):\n" + expected;
		var results:Array<Int> = [ for ( i in 0...objectArray.length ) 0 ];
		timer = Lib.getTimer();
		
		for ( i in 0...ONEMIL ) results[ FlxRandom.weightedGetObject( objectArray, weightArray ) ] ++;
		
		var percentResults:Array<Float> = [ for ( i in 0...objectArray.length ) FlxMath.roundDecimal( 100 * results[i] / ONEMIL, 2 ) ];
		_display.text += "\nDone. Results:\n" + percentResults + "\nTotal time " + ( Lib.getTimer() - timer ) + "ms. Displaying results...";
		createHistogram( [ for ( i in 0...results.length ) ""+i ], results );
	}
	
	private function shuffleObj():Void
	{
		var array:Array<Int> = [ for ( i in 0...20 ) FlxRandom.intRanged( 0, 100 ) ];
		_display.text = "Shuffling the array " + array + " one million times...";
		timer = Lib.getTimer();
		array = FlxRandom.shuffleArray( array, ONEMIL );
		_display.text += "\nDone. New array is " + array + ", time: " + ( Lib.getTimer() - timer ) + "ms.";
	}
	
	private function randomColors():Void
	{
		var min:Int = FlxRandom.intRanged( 0, 255 );
		var max:Int = FlxRandom.intRanged( 0, 255 );
		
		_display.text = "Covering the screen with 307,200 random pixels with min " + min + " and max " + max + "...";
		dummyBitmapdata = new BitmapData( 640, 480, false, 0 );
		timer = Lib.getTimer();
		
		for ( yPos in 0...480 ) {
			for ( xPos in 0...640 ) {
				dummyBitmapdata.setPixel( xPos, yPos, FlxRandom.color( min, max ) );
			}
		}
		
		_colorTest.pixels = dummyBitmapdata;
		_colorTest.visible = true;
		_display.text += "\nDone, time: " + ( Lib.getTimer() - timer ) + "ms.";
	}
	
	private function randomColorsExt():Void
	{
		var minr:Int = FlxRandom.intRanged( 0, 255 );
		var maxr:Int = FlxRandom.intRanged( 0, 255 );
		var ming:Int = FlxRandom.intRanged( 0, 255 );
		var maxg:Int = FlxRandom.intRanged( 0, 255 );
		var minb:Int = FlxRandom.intRanged( 0, 255 );
		var maxb:Int = FlxRandom.intRanged( 0, 255 );
		
		_display.text = "Covering the screen with 307,200 random pixels using colorExt...";
		dummyBitmapdata = new BitmapData( 640, 480, false, 0 );
		timer = Lib.getTimer();
		
		for ( yPos in 0...480 ) {
			for ( xPos in 0...640 ) {
				dummyBitmapdata.setPixel( xPos, yPos, FlxRandom.colorExt( minr, maxr, ming, maxg, minb, maxb ) );
			}
		}
		
		_colorTest.pixels = dummyBitmapdata;
		_colorTest.visible = true;
		_display.text += "\nDone, time: " + ( Lib.getTimer() - timer ) + "ms.";
	}
}