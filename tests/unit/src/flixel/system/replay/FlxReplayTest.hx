package flixel.system.replay;

import massive.munit.Assert;

class FlxReplayTest
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
		var possibleKeys = [8, 9, 13, 16, 17, 18, 20, 27, 32, 33, 34, 35, 36, 37, 38, 39, 40, 45, 46, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 109, 110, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 186, 187, 188, 189, 190, 191, 219, 221, 222, 301];
		for (i in 0...frameCount)
		{
			key = possibleKeys[i % possibleKeys.length];
			x = i % FlxG.width;
			y = FlxG.height - (i % FlxG.height);
			fgr += i + "k" + key + ":1m" + x + "," + y + ",2,0\n"; // each frame has a simultaneous key-already-down and mouse-just-down
		}
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
		}
		var resavedFGR:String = replayRecorder.save();
		Assert.areEqual(fgr, resavedFGR);
	}
}