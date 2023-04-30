package flixel.system.debug.console;

class ConsoleUtilTest extends FlxTest
{
	@Test
	function testGetStaticFields()
	{
		testGetFields(GetStaticFieldsTest);
	}

	@Test
	function testGetInstanceFields()
	{
		testGetFields(new GetInstanceFieldsTest());
	}

	function testGetFields(objectOrClass:Dynamic)
	{
		FlxAssert.arraysEqual([for (i in 0...6) "test" + (i + 1)], ConsoleUtil.getFields(objectOrClass));
	}
}

class GetStaticFieldsTest
{
	static var test1(get, never):Int;

	static function get_test1()
		return 0;

	static var test2(default, null):Int;

	static var test3(default, never):Int;

	static var test4(get, set):Int;

	static function get_test4()
		return 0;

	static function set_test4(i)
		return i;

	static var test5(never, set):Int;

	static function set_test5(i)
		return i;

	static function test6() {}
}

class GetInstanceFieldsTest
{
	var test1(get, never):Int;

	function get_test1()
		return 0;

	var test2(default, null):Int;

	var test3(default, never):Int;

	var test4(get, set):Int;

	function get_test4()
		return 0;

	function set_test4(i)
		return i;

	var test5(never, set):Int;

	function set_test5(i)
		return i;

	function test6() {}

	public function new() {}
}
