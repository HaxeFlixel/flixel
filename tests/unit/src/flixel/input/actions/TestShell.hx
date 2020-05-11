package flixel.input.actions;

import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.PosInfos;
import massive.munit.Assert;

class TestShell implements IFlxDestroyable
{
	public var name:String;
	public var results:Array<TestShellResult>;
	public var prefix:String = "";

	public function new(Name:String)
	{
		name = Name;
		results = [];
	}

	public function destroy()
	{
		FlxArrayUtil.clearArray(results);
	}

	public function get(id:String):TestShellResult
	{
		for (result in results)
		{
			if (result.id == id)
				return result;
		}
		return {
			id: "unknown id(" + id + ")",
			testedTrue: false,
			testedFalse: false,
			testedNull: false,
			testedNotNull: false,
			strValue: "unknown id, not tested!"
		};
	}

	public function testBool(b:Bool, id:String)
	{
		test(id, b, !b, false, false, Std.string(b));
	}

	public function testIsNull(d:Dynamic, id:String)
	{
		test(id, false, false, d == null, d != null, d == null ? "null" : Std.string(d));
	}

	public function testIsNotNull(d:Dynamic, id:String)
	{
		test(id, false, false, d == null, d != null, d == null ? "null" : Std.string(d));
	}

	function test(id:String, tTrue:Bool = false, tFalse:Bool = false, tNull:Bool = false, tNNull:Bool = false, strValue:String = "untested")
	{
		results.push({
			id: name + prefix + id,
			testedTrue: tTrue,
			testedFalse: tFalse,
			testedNull: tNull,
			testedNotNull: tNNull,
			strValue: strValue
		});
	}

	public function assertTrue(id:String, ?info:PosInfos)
	{
		var value = get(id).testedTrue;
		var strValue = get(id).strValue;
		Assert.assertionCount++;
		if (!value)
			Assert.fail("Expected TRUE but (" + id + ") was [" + strValue + "]", info);
	}

	public function assertFalse(id:String, ?info:PosInfos)
	{
		var value = get(id).testedFalse;
		var strValue = get(id).strValue;
		Assert.assertionCount++;
		if (!value)
			Assert.fail("Expected FALSE but (" + id + ") was [" + strValue + "]", info);
	}

	public function assertNull(id:String, ?info:PosInfos)
	{
		var value = get(id).testedNull;
		var strValue = get(id).strValue;
		Assert.assertionCount++;
		if (!value)
			Assert.fail("Expected NULL but (" + id + ") was [" + strValue + "]", info);
	}

	public function assertNotNull(id:String, ?info:PosInfos)
	{
		var value = get(id).testedNotNull;
		var strValue = get(id).strValue;
		Assert.assertionCount++;
		if (!value)
			Assert.fail("Expected NOT NULL but (" + id + ") was [" + strValue + "]", info);
	}
}

typedef TestShellResult =
{
	id:String,
	testedTrue:Bool,
	testedFalse:Bool,
	testedNull:Bool,
	testedNotNull:Bool,
	strValue:String
}
