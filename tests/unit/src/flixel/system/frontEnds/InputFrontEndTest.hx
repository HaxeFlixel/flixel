package flixel.system.frontEnds;

import flixel.system.frontEnds.InputFrontEnd;
import flixel.FlxG;
import flixel.input.IFlxInputManager;
import massive.munit.Assert;

class InputFrontEndTest
{
	var inputs:InputFrontEnd;
	
	@Before
	function before():Void
	{
		@:privateAccess
		inputs = new InputFrontEnd();
	}
	
	@Test
	@:haxe.warning("-WDeprecated")
	function testAdd()
	{
		final input1 = new CustomInputManager();
		inputs.add(input1);
		FlxAssert.arrayContains(inputs.list, input1);
		
		final input2 = new CustomInputManager();
		inputs.add(input2);
		FlxAssert.arrayNotContains(inputs.list, input2);
	}
	
	@Test
	function testAddUniqueType()
	{
		final input1 = new CustomInputManager();
		inputs.addUniqueType(input1);
		FlxAssert.arrayContains(inputs.list, input1);
		
		final input2 = new CustomInputManager();
		inputs.addUniqueType(input2);
		FlxAssert.arrayNotContains(inputs.list, input2);
	}
	
	@Test
	function testAddInput()
	{
		final input1 = new CustomInputManager();
		inputs.addInput(input1);
		FlxAssert.arrayContains(inputs.list, input1);
		
		final oldLength = inputs.list.length;
		// add again
		inputs.addInput(input1);
		Assert.areEqual(inputs.list.length, oldLength);
		
		final input2 = new CustomInputManager();
		inputs.addInput(input2);
		FlxAssert.arrayContains(inputs.list, input2);
	}
}

class CustomInputManager implements IFlxInputManager
{
	public function new () {}
	public function destroy() {}
	public function reset():Void {}
	function update():Void {}
	function onFocus():Void {}
	function onFocusLost():Void {}
}
