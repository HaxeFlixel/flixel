package;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.Lib;
import flash.utils.ByteArray;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup;

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
	private var _pendingFunction:Void->Void;
	
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
	private var _updateNext:Bool = false;
	
	private static inline var ONEMIL:Int = 1000000;
	private static inline var TENMIL:Int = 10000000;
	
	inline private static function BUTTON_TEXT():Array<String>
	{
		return ["Reset Global Seed", "Get Current Seed", "Generate Integers",
				"Generate Floats", "Normal Distribution Floats", "Weighted Coin Flips", "Generate Signs",
				"Weighted Pick", "Get Array Object", "Weighted Get Array Object",
				"Shuffle Array", "Generate Colors", "Test Accuracy"];
	}
	
	override public function create():Void
	{
		FlxG.camera.bgColor = FlxG.random.color(0, 32);
		
		var area = new FlxSprite(5, 5);
		area.makeGraphic(FlxG.width - 200, FlxG.height - 10, 0x88000000);
		
		_buttonGroup = new FlxTypedGroup<FlxButton>();
		
		var buttonX:Int = Std.int(area.x + area.width + 5);
		var buttonY:Int = Std.int(area.y);
		
		for (i in 0...BUTTON_TEXT().length)
		{
			var button = new FlxButton(buttonX, buttonY, BUTTON_TEXT()[i], buttonCallback.bind(BUTTON_TEXT()[i]));
			button.makeGraphic(185, 20, 0x88DDDDDD);
			_buttonGroup.add(button);
			
			buttonY += 25;
		}
		
		_display = new FlxText(10, 10, FlxG.width - 210, "Welcome to the FlxRandom demo!\nYour randomly generated seed is: " + FlxG.random.initialSeed + "\nFeel free to run some of the tests on the right.\nPlease note that some of these can take quite some time.");
		
		_colorTest = new FlxSprite(0, 0);
		_colorTest.makeGraphic(FlxG.width, FlxG.height, 0);
		_colorTest.visible = false;
		dummyBitmapdata = new BitmapData(1, 1, false, 0);
		dummyText = new FlxText(0, 0, 20, "000");
		
		_histogram = new FlxSprite(10, 320);
		_histogram.makeGraphic(1, 1, 0);
		
		add(_colorTest);
		add(area);
		add(_display);
		add(_histogram);
		add(_buttonGroup);
		
		super.create();
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (_updateNext && _pendingFunction != null)
		{
			_pendingFunction();
			_pendingFunction = null;
			_updateNext = false;
		}
		
		if (_pendingFunction != null)
		{
			_updateNext = true;
		}
	}
	
	private function buttonCallback(Label:String):Void
	{
		_display.text = "";
		_colorTest.visible = Label == BUTTON_TEXT()[10];
		_histogram.visible = false;
		
		switch (BUTTON_TEXT().indexOf(Label))
		{
			case 0:
				_display.text = "The new global base seed is: " + FlxG.random.resetInitialSeed();
			case 1:
				_display.text = "The current seed is " + FlxG.random.currentSeed;
			case 2:
				_pendingFunction = intRandom;
			case 3:
				_pendingFunction = floatRandom;
			case 4:
				_pendingFunction = floatNormal;
			case 5:
				_pendingFunction = coinFlipsWeighted;
			case 6:
				_pendingFunction = randomSigns;
			case 7:
				_pendingFunction = weightedPicks;
			case 8:
				_pendingFunction = getObjects;
			case 9:
				_pendingFunction = getObjectsWeighted;
			case 10:
				_pendingFunction = shuffleObj;
			case 11:
				_pendingFunction = randomColors;
			case 12:
				_pendingFunction = verification;
		}
		
		if (_pendingFunction != null)
		{
			_display.text = "Calculating, please wait...";
		}
	}
	
	private function intRandom():Void
	{
		_display.text = "Randomly generated 10 million integers using each of the following methods.";
		
		timer = Lib.getTimer();
		for (i in 0...TENMIL) dummyInt = FlxG.random.int(0, 1024);
		_display.text += "\nTime: " + (Lib.getTimer() - timer) + "ms using the newest method.";
		
		timer = Lib.getTimer();
		for (i in 0...TENMIL) dummyInt = OldFlxRandom.intRanged(0, 1024);
		_display.text += "\nTime: " + (Lib.getTimer() - timer) + "ms using the old, non-deterministic FlxG.random.";
		
		timer = Lib.getTimer();
		for (i in 0...TENMIL) dummyInt = FlxRandom_3_3_4.intRanged(0, 1024);
		_display.text += "\nTime: " + (Lib.getTimer() - timer) + "ms using FlxRandom from 3.3.4.";
		
		timer = Lib.getTimer();
		for (i in 0...TENMIL) dummyInt = NonInlineFlxRandom.intRanged(0, 1024);
		_display.text += "\nTime: " + (Lib.getTimer() - timer) + "ms using FlxRandom from 3.3.4 without inlining.";
		
		timer = Lib.getTimer();
		for (i in 0...TENMIL) dummyInt = Std.int(Math.random() * 1024);
		_display.text += "\nTime: " + (Lib.getTimer() - timer) + "ms using Math.random().";
	}
	
	private function floatNormal():Void
	{
		_display.text = "Randomly generated 10 million floats in a normal distribution";
		
		timer = Lib.getTimer();
		for (i in 0...TENMIL) dummyFloat = FlxG.random.floatNormal();
		_display.text += "\nTime: " + (Lib.getTimer() - timer) + "ms.";
		
		var array:Array<Float> = [];
		
		var range:Int = 35;
		
		for (i in 0...range)
		{
			array.push(-1);
		}
		
		var mean:Float = range / 2;
		var stdev:Float = range / 8;
		
		_display.text += "\n\nNow generating 10 million more for display,\nusing (range)=0-"+(range-1)+", (mean)=" + mean + ", and (standard deviation size)= " + stdev;
		
		timer = Lib.getTimer();
		
		var max:Int = 0;
		
		for (i in 0...TENMIL)
		{
			dummyFloat = FlxG.random.floatNormal(mean,stdev);
			
			var index:Int = Std.int(dummyFloat);
			
			if (index < 0)
			{
				index = 0;
			}
			if (index > array.length - 1)
			{
				index = array.length - 1;
			}
			array[index]++;
			if (array[index] > max)
			{
				max = Std.int(array[index]);
			}
		}
		
		for (i in 0...array.length)
		{
			array[i] /= max;
		}
		
		_display.text += "\nDistribution looks like:\n";
		
		var stars:Float = range;
		
		var str:String = "";
		for (i in 0...array.length)
		{
			str += "\n"+i+"\t";
			var starCount:Float = Std.int(stars * array[i]);
			for (j in 0...Std.int(starCount))
			{
				str += "*";
			}
		}
		
		_display.text += str + "\n";
		
		_display.text += "\nTime: " + (Lib.getTimer() - timer) + "ms.";
	}
	
	private function floatRandom():Void
	{
		_display.text = "Randomly generated 10 million floats using each of the following methods.";
		
		timer = Lib.getTimer();
		for (i in 0...TENMIL) dummyFloat = FlxG.random.float();
		_display.text += "\nTime: " + (Lib.getTimer() - timer) + "ms using the newest method.";
		
		timer = Lib.getTimer();
		for (i in 0...TENMIL) dummyFloat = OldFlxRandom.floatRanged();
		_display.text += "\nTime: " + (Lib.getTimer() - timer) + "ms using the old, non-deterministic FlxG.random.";
		
		timer = Lib.getTimer();
		for (i in 0...TENMIL) dummyFloat = FlxRandom_3_3_4.floatRanged();
		_display.text += "\nTime: " + (Lib.getTimer() - timer) + "ms using FlxRandom from 3.3.4.";
		
		timer = Lib.getTimer();
		for (i in 0...TENMIL) dummyFloat = NonInlineFlxRandom.floatRanged();
		_display.text += "\nTime: " + (Lib.getTimer() - timer) + "ms using FlxRandom from 3.3.4 without inlining.";
		
		timer = Lib.getTimer();
		for (i in 0...TENMIL) dummyFloat = Math.random();
		_display.text += "\nTime: " + (Lib.getTimer() - timer) + "ms using Math.random().";
	}
	
	private function coinFlipsWeighted():Void
	{
		var heads:Int = 0;
		var tails:Int = 0;
		var weight:Int = FlxG.random.int(0, 100);
		
		timer = Lib.getTimer();
		for (i in 0...TENMIL) if (FlxG.random.bool(weight)) heads++ else tails++;
		
		_display.text = "Flipped a coin with a " + weight + "% chance of heads 10 million times. Got " + heads + " heads and " + tails + " tails. Time: " + (Lib.getTimer() - timer) + "ms.";
		
		if (heads > tails)
		{
			_display.text += "\nHeads wins!";
		}
		else
		{
			_display.text += "\nTails wins!";
		}
		
		if (weight != 50)
		{
			_display.text += " That doesn't seem fair.";
		}
	}
	
	private function randomSigns():Void
	{
		timer = Lib.getTimer();
		for (i in 0...TENMIL) dummyInt = FlxG.random.sign();
		_display.text = "Selected 10 million positive or negative signs. Time: " + (Lib.getTimer() - timer) + "ms.";
	}
	
	private function weightedPicks():Void
	{
		var array:Array<Float> = [for (i in 0...10) FlxG.random.int(0, 99)];
		var results:Array<Int> = [for (i in 0...array.length) 0];
		
		_display.text = "Performed 1 million random picks from this array:\n" + array;
		
		var expectedResults:Array<Float> = [];
		var arrayTotal:Int = 0;
		
		for (i in array) arrayTotal += Std.int(i);
		for (i in 0...array.length) expectedResults.push(FlxMath.roundDecimal(100 * array[i] / arrayTotal, 2));
		
		_display.text += "\nExpected results (in percentages):\n" + expectedResults;
		
		timer = Lib.getTimer();
		for (i in 0...ONEMIL) results[FlxG.random.weightedPick(array)] ++;
		
		var percentResults:Array<Float> = [for (i in 0...10) FlxMath.roundDecimal(100 * results[i] / ONEMIL, 2)];
		
		_display.text += "\nTime: " + (Lib.getTimer() - timer) + "ms. Actual results (in percentages):\n" + percentResults;
	}
	
	private function getObjects():Void
	{
		var array:Array<Int> = [for (i in 0...20) i];
		var results:Array<Int> = [for (i in 0...20) 0
		];
		timer = Lib.getTimer();
		for (i in 0...ONEMIL) results[FlxG.random.getObject(array)]++;
		
		_display.text = "Got a random object from an array of 20 integers 1 million times. Time " + (Lib.getTimer() - timer) + "ms. Displaying results as a histogram.";
		
		createHistogram([for (i in 0...results.length) ""+i], results);
	}
	
	private function getObjectsWeighted():Void
	{
		var objectArray:Array<Int> = [for (i in 0...10) i];
		var weightArray:Array<Float> = [for (i in 0...objectArray.length) FlxG.random.int(0, 100)];
		var expected:Array<Float> = [];
		var total:Int = 0;
		
		for (i in weightArray) total += Std.int(i);
		for (i in 0...objectArray.length) expected.push(FlxMath.roundDecimal(100 * weightArray[i] / total, 2));
		
		_display.text = "Performed one million weighted object picks from this array:\n" + objectArray;
		_display.text += "\nExpected results (in percentages):\n" + expected;
		var results:Array<Int> = [for (i in 0...objectArray.length) 0];
		timer = Lib.getTimer();
		
		for (i in 0...ONEMIL) results[FlxG.random.getObject(objectArray, weightArray)] ++;
		
		var percentResults:Array<Float> = [for (i in 0...objectArray.length) FlxMath.roundDecimal(100 * results[i] / ONEMIL, 2)];
		
		_display.text += "\nDone. Results:\n" + percentResults + "\nTotal time " + (Lib.getTimer() - timer) + "ms. Displaying results...";
		
		createHistogram([for (i in 0...results.length) ""+i], results);
	}
	
	private function shuffleObj():Void
	{
		var array:Array<Int> = [for (i in 0...20) FlxG.random.int(0, 100)];
		timer = Lib.getTimer();
		
		_display.text = "Shuffled the array " + array + " one million times.";
		array = FlxG.random.shuffleArray(array, ONEMIL);
		_display.text += "\nNew array is " + array + ", time: " + (Lib.getTimer() - timer) + "ms.";
	}
	
	private function randomColors():Void
	{
		dummyBitmapdata = new BitmapData(FlxG.width, FlxG.height, false, 0);
		timer = Lib.getTimer();
		
		for (yPos in 0...480) {
			for (xPos in 0...640) {
				dummyBitmapdata.setPixel(xPos, yPos, FlxG.random.color().to24Bit());
			}
		}
		
		_display.text = "Covered the screen with 307,200 random pixels using color(). Time: " + (Lib.getTimer() - timer) + "ms.";
		
		_colorTest.loadGraphic(dummyBitmapdata);
		_colorTest.visible = true;
	}
	
	private function createHistogram(Labels:Array<String>, ?Data:Array<Int>, ?DataFloat:Array<Float>):Void
	{
		if (Data != null)
		{
			dummyBitmapdata = new BitmapData(Data.length * 15 + 5, 100, true, 0xff222222);
		}
		else
		{
			dummyBitmapdata = new BitmapData(DataFloat.length * 15 + 5, 100, true, 0xff222222);
		}
		
		for (i in 0...Labels.length)
		{
			if (Data != null)
			{
				dummyRect = new Rectangle(i * 15 + 5, 5, 10, Data[i] / TENMIL * 1000);
			}
			else
			{
				dummyRect = new Rectangle(i * 15 + 5, 5, 10, DataFloat[i] / TENMIL * 1000);
			}
			
			dummyBitmapdata.fillRect(dummyRect, FlxG.random.color());
			dummyText.text = Labels[i];
			dummyText.draw();
			dummyBitmapdata.draw(dummyText.pixels, new Matrix(1, 0, 0, 1, i * 15 + 3, dummyRect.height + 10));
		}
		
		_histogram.pixels = dummyBitmapdata;
		_histogram.visible = true;
	}
	
	/**
	 * See here: https://github.com/HaxeFlixel/flixel/pull/1148
	 */
	private function verification():Void
	{
		var status:Bool = true;
		var int:Int = 0;
		FlxG.random.initialSeed = 20000000;
		_display.text = "Initial seed set to " + FlxG.random.initialSeed;
		int = FlxG.random.int();
		status = status && int == INT_1;
		_display.text += "\nInt 1: " + int;
		int = FlxG.random.int();
		status = status && int == INT_2;
		_display.text += "\nInt 2: " + int;
		int = FlxG.random.int();
		status = status && int == INT_3;
		_display.text += "\nInt 3: " + int;
		int = FlxG.random.int();
		status = status && int == INT_4;
		_display.text += "\nInt 4: " + int;
		int = FlxG.random.int();
		status = status && int == INT_5;
		_display.text += "\nInt 5: " + int;
		for (i in 5...99) FlxG.random.int();
		int = FlxG.random.int();
		status = status && int == INT_100;
		_display.text += "\nInt 100: " + int;
		for (i in 100...999) FlxG.random.int();
		int = FlxG.random.int();
		status = status && int == INT_1000;
		_display.text += "\nInt 1000: " + int;
		for (i in 1000...99999) FlxG.random.int();
		int = FlxG.random.int();
		status = status && int == INT_100000;
		_display.text += "\nInt 100000: " + int;
		
		if (status)
		{
			_display.text += "\nTest successful, all results as expected.";
			#if debug
			trace("Success");
			#end
		}
		else
		{
			_display.text += "\nTest failed. Someone open an issue on github!";
			#if debug
			trace("Failure");
			#end
		}
	}
	
	private static inline var INT_1:Int = 1199842497;
	private static inline var INT_2:Int = 2110696744;
	private static inline var INT_3:Int = 228381356;
	private static inline var INT_4:Int = 1162875425;
	private static inline var INT_5:Int = 84591242;
	private static inline var INT_100:Int = 2086347125;
	private static inline var INT_1000:Int = 1729281946;
	private static inline var INT_100000:Int = 1064120637;
}