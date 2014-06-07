package helper;

import flash.errors.Error;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import massive.munit.Assert;

class TestUtil
{
	public static function testDestroy(destroyable:IFlxDestroyable)
	{
		try
		{
			destroyable.destroy();
			destroyable.destroy();
		}
		catch (e:Error)
		{
			Assert.fail(e.message);
		}
	}
}