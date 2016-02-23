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
		seed = Std.random(0x7FFFFFFF);
		frameCount = Std.random(10000) + 1;
		fgr = seed + "\n";
		var key:Int;
		var x:Int;
		var y:Int;
		for (i in 0...frameCount) {
			key = Std.random(26) + 65; // some magic numbers here...I suppose this could be replaced with something more sophisticated involving Reflect and flixel.input.keyboard.FlxKeyList...
			x = Std.random(FlxG.width);
			y = Std.random(FlxG.height);
			fgr += i + "k" + key + ":1m" + x + "," + y + ",2,0\n"; // each frame has a simultaneous key-already-down and mouse-just-down
		}
	}
	
	@Test
	function testReplayCreateSpecifyingSeed()
	{
		var replay = new FlxReplay();
		replay.create( seed );
		Assert.areEqual( seed, replay.seed );
	}

	@Test
	function testReplayLoadSeed()
	{
		var replay = new FlxReplay();
		replay.load( fgr );
		Assert.areEqual( seed, replay.seed );
	}

	@Test
	function testReplayLoadFrameCount()
	{
		var replay = new FlxReplay();
		replay.load( fgr );
		Assert.areEqual( frameCount, replay.frameCount );
	}
	
	@Test // #1739
	function testReplayRecordSimultaneousKeydownAndMouseDown()
	{
		var replayPlayer = new FlxReplay();
		var replayRecorder = new FlxReplay();
		replayRecorder.create(seed);
		replayPlayer.load( fgr );
		while (!replayPlayer.finished) {
			replayPlayer.playNextFrame();
			replayRecorder.recordFrame();
		}
		var resavedFGR:String = replayRecorder.save();
		Assert.areEqual( fgr, resavedFGR );
	}
}