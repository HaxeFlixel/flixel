package flixel.path;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import massive.munit.Assert;

class FlxPathTest extends FlxTest
{
	var object:FlxObject;
	var path:FlxPath;

	@Before
	function before()
	{
		object = new FlxObject();
		FlxG.state.add(object);

		path = new FlxPath();
	}

	@Test
	function testImmovableValueAfterCompletionNotModfied()
	{
		Assert.isFalse(object.immovable);

		startPath();
		finishPath();

		Assert.isFalse(object.immovable);
	}

	@Test
	function testImmovableValueAfterCancelNotModified()
	{
		Assert.isFalse(object.immovable);

		startPath();
		path.cancel();

		Assert.isFalse(object.immovable);
	}

	@Test
	function testCancelNoCallback()
	{
		startPath();
		path.onComplete = function(_)
		{
			Assert.fail("Callback called");
		};
		path.cancel();
		step();
	}

	@Test
	function testAddAtNoCrashOnEmptyPath()
	{
		path.addAt(10, 10, 0);
		Assert.areEqual(1, path.nodes.length);
	}

	@Test
	function testRemoveAtNoCrashOnEmptyPath()
	{
		path.removeAt(0);
		Assert.areEqual(0, path.nodes.length);
	}

	@Test
	function testHeadNoCrashOnEmpty()
	{
		Assert.areEqual(null, path.head());
	}

	@Test
	function testTailNoCrashOnEmpty()
	{
		Assert.areEqual(null, path.tail());
	}

	@Test
	function testNotActiveOnEmptyNodesStart()
	{
		object.path = path.start(null);
		Assert.areEqual(false, object.path.active);
		object.path = path.start([]);
		Assert.areEqual(false, object.path.active);
	}

	@Test
	function testNoRestartOnNullNodesStart()
	{
		startPath();
		Assert.areEqual(true, object.path.active);
		Assert.areEqual(false, object.path.finished);

		object.path.start(null);
		Assert.areEqual(true, object.path.active);
		Assert.areEqual(false, object.path.finished);
	}

	@Test
	function testRemoveAt()
	{
		for (i in 0...4)
		{
			path.add(i, i);
		}
		Assert.areEqual(4, path.nodes.length);

		path.removeAt(5); // Beyond the length
		Assert.areEqual(3, path.nodes.length);
		for (i in 0...3)
		{
			Assert.areEqual(i, path.nodes[i].x);
			Assert.areEqual(i, path.nodes[i].y);
		}

		path.removeAt(2);
		Assert.areEqual(2, path.nodes.length);
		for (i in 0...2)
		{
			Assert.areEqual(i, path.nodes[i].x);
			Assert.areEqual(i, path.nodes[i].y);
		}
	}

	@Test
	function testAddAt()
	{
		for (i in 0...2)
		{
			path.add(i, i);
		}
		Assert.areEqual(2, path.nodes.length);

		path.addAt(2, 2, 2);
		Assert.areEqual(3, path.nodes.length);

		path.addAt(3, 3, 4);
		Assert.areEqual(4, path.nodes.length);
		for (i in 0...4)
		{
			Assert.areEqual(i, path.nodes[i].x);
			Assert.areEqual(i, path.nodes[i].y);
		}
	}

	@Test
	function testStartNodesAsReference()
	{
		var points:Array<FlxPoint> = [new FlxPoint(0, 0), new FlxPoint(1, 1), new FlxPoint(2, 2), new FlxPoint(3, 3)];
		object.path = path.start(points, 100, FORWARD, false, true);
		Assert.areEqual(object.path.nodes.length, points.length);
		for (i in 0...points.length)
		{
			Assert.areEqual(i, path.nodes[i].x);
			Assert.areEqual(i, path.nodes[i].y);
		}

		object.path.removeAt(0);
		Assert.areEqual(object.path.nodes.length, points.length);
		for (i in 0...points.length)
		{
			Assert.areEqual(i + 1, path.nodes[i].x);
			Assert.areEqual(i + 1, path.nodes[i].y);
		}

		object.path = path.start(points, 100, FORWARD, false, false);
		Assert.areEqual(object.path.nodes.length, points.length);
		object.path.removeAt(0);
		Assert.areEqual(object.path.nodes.length + 1, points.length);
	}

	@Test
	function testDefaultStart()
	{
		object.path = new FlxPath([new FlxPoint(10, 10), new FlxPoint(20, 20), new FlxPoint(30, 30)]).start();
		Assert.areEqual(true, object.path.active);
	}

	function finishPath()
	{
		while (!path.finished)
		{
			step();
		}
	}

	function startPath()
	{
		object.path = path.start([FlxPoint.get(), FlxPoint.get(100, 100)]);
	}
}
