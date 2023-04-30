package flixel.system.replay;

import flixel.input.keyboard.FlxKey;
import flixel.ui.FlxButton;
import flixel.input.FlxInput.FlxInputState;
import flixel.FlxState;
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
		/* Exclude:
		 * 1. not-really-keys
		 * 2. debugger activators (so as not to affect other tests by having the debugger open)
		 */
		for (key in [ANY, NONE, BACKSLASH, GRAVEACCENT])
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
		while (true)
		{
			replayPlayer.playNextFrame();
			if (replayPlayer.finished)
				break;
			replayRecorder.recordFrame();
		}
		var resavedFGR:String = replayRecorder.save();
		Assert.areEqual(fgr, resavedFGR);
	}

	@Test // #1729
	function testButtonTrigger()
	{
		var frames = [
			createFrameRecord(0, RELEASED),
			createFrameRecord(1, JUST_PRESSED),
			createFrameRecord(2, PRESSED),
			createFrameRecord(3, JUST_RELEASED)
		];
		var recording = frames.map(function(r) return r.save()).join("\n");
		var state = new ReplayState();
		FlxG.vcr.loadReplay(recording, state);

		step(10);

		Assert.isTrue(state.called);
	}

	function createFrameRecord(i:Int, mouseState:FlxInputState):FrameRecord
	{
		return new FrameRecord().create(i, null, new MouseRecord(0, 0, mouseState, 0));
	}
}

class ReplayState extends FlxState
{
	public var called:Bool = false;

	override public function create()
	{
		var button = new FlxButton();
		button.width = FlxG.width;
		button.height = FlxG.height;
		button.onUp.callback = function() called = true;
		add(button);
	}
}
