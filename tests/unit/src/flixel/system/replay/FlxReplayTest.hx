package flixel.system.replay;

import flixel.input.keyboard.FlxKey;
import massive.munit.Assert;

class FlxReplayTest extends FlxTest
{
	var seed:Int;
	var fgr:String;
	var frameCount:Int;

	@Before
	function before()
	{
		seed = 123456789;
		frameCount = 300;
		fgr = seed + "\n";
		var key:Int;
		var x:Int;
		var y:Int;
		var possibleKeys:Array<Int> = [for (key in FlxKey.toStringMap.keys()) key];
		for (key in [-1, -2, 192, 220]) // exclude not-really-keys, and debugger activators (so as not to affect other tests by having the debugger open)
			possibleKeys.remove(key);
		for (i in 0...frameCount)
		{
			key = possibleKeys[i % possibleKeys.length];
			x = i % FlxG.width;
			y = FlxG.height - (i % FlxG.height);
			fgr += i + "k" + key + ":1m" + x + "," + y + ",2,0\n"; // each frame has a simultaneous key-already-down and mouse-just-down
		}
		fgr += (frameCount++) + "km0,0,2,0\n"; // put everything back how it was for the next test
	}
	
	@Test
	function testReplayCreateSpecifyingSeed()
	{
		var replay = new FlxReplay();
		replay.create(seed);
		Assert.areEqual(seed, replay.seed);
	}

	@Test
	function testReplayLoadSeed()
	{
		var replay = new FlxReplay();
		replay.load(fgr);
		Assert.areEqual(seed, replay.seed);
	}

	@Test
	function testReplayLoadFrameCount()
	{
		var replay = new FlxReplay();
		replay.load(fgr);
		Assert.areEqual(frameCount, replay.frameCount);
	}
	
	@Test // #1739
	function testReplayRecordSimultaneousKeydownAndMouseDown()
	{
		var replayPlayer = new FlxReplay();
		var replayRecorder = new FlxReplay();
		replayRecorder.create(seed);
		replayPlayer.load(fgr);
		while (!replayPlayer.finished)
		{
			replayPlayer.playNextFrame();
			replayRecorder.recordFrame();
			step();
		}
		var resavedFGR:String = replayRecorder.save();
		Assert.areEqual(fgr, resavedFGR);
	}
}