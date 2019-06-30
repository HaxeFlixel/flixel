package flixel.system.debug.watch;

import massive.munit.Assert;
import openfl.text.TextFormat;
import Type.ValueType;

class EditableTextFieldTest extends FlxTest
{
	#if neko
	@Test // #1911
	function testKeepType()
	{
		testType(ValueType.TInt, "1");
		testType(ValueType.TFloat, "0.56");
		testType(ValueType.TBool, "true");
		testType(ValueType.TBool, "false");
	}

	function testType(type:ValueType, text:String)
	{
		var value:Dynamic = null;
		var textfield = new EditableTextField(true, new TextFormat(), function(v) value = v, type);
		textfield.text = text;
		textfield.submit();
		Assert.areEqual(Type.typeof(value), type);
	}
	#end
}
