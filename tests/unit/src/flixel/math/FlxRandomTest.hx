package flixel.math;

import flixel.util.FlxColor;
import massive.munit.Assert;
import org.hamcrest.Matchers.*;

class FlxRandomTest extends FlxTest
{
	var random:FlxRandom;
	
	@Before
	function before()
	{
		// Use a constant seed for reproducible test results.
		random = new FlxRandom(1);
	}
	
	@Test // #1172
	function testIntExcludes()
	{
		for (i in 0...20)
		{
			Assert.areEqual(0, random.int(0, 1, [1]));
		}
	}
	
	@Test // #1536
	function testColorNullException()
	{
		random.color(null, null);
		random.color(FlxColor.GRAY, null);
		random.color(null, FlxColor.GRAY);
		
		random.color(null, null, null);
		random.color(FlxColor.GRAY, null, null);
		random.color(null, FlxColor.GRAY, null);
		random.color(FlxColor.RED, FlxColor.GRAY, null);
	}

	@Test
	function testShuffleWithEmptyArray()
	{
		var array:Array<Int> = [];
		random.shuffle(array);
		assertThat(array, is([]));
	}

	@Test
	function testShuffleWithSingleElementArray()
	{
		var array = [42];
		random.shuffle(array);
		assertThat(array, is([42]));
	}

	@Test
	function testShuffleWithThreeElementArray()
	{
		var seen = new Map<String, Bool>();
		// The probability of this failing is (5/6)^20 = 2.6%. But because we use
		// a fixed seed, once it passes, it will always pass, so there is no need
		// for more iterations.
		for (i in 0...20)
		{
			var array = [1, 2, 3];
			random.shuffle(array);
			seen[array.join(",")] = true;
		}
		// We have to turn the Iterator returned by keys() back into an Iterable to
		// make Hamcrest happy.
		var keys = [for (key in seen.keys()) key];
		assertThat(keys, containsInAnyOrder("1,2,3", "1,3,2", "2,1,3", "2,3,1", "3,1,2", "3,2,1"));
	}
}
