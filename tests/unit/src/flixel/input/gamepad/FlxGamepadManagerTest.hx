package flixel.input.gamepad;

#if FLX_JOYSTICK_API
import openfl.events.JoystickEvent;
import massive.munit.Assert;
#end

class FlxGamepadManagerTest extends FlxTest
{
	#if FLX_JOYSTICK_API
	@Test // #1586
	function testDpadStuck()
	{
		hatMove(1, 1);
		hatMove(0, -1);
		hatMove(0, 0);

		var gamepad = FlxG.gamepads.lastActive;
		Assert.isFalse(gamepad.pressed.DPAD_LEFT);
		Assert.isFalse(gamepad.pressed.DPAD_RIGHT);
		Assert.isFalse(gamepad.pressed.DPAD_UP);
		Assert.isFalse(gamepad.pressed.DPAD_DOWN);
	}

	function hatMove(x, y)
	{
		FlxG.stage.dispatchEvent(new JoystickEvent("hatMove", false, false, 0, x, y, 0));
		step();
	}
	#end
}
