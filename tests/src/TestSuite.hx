import massive.munit.TestSuite;

import flixel.animation.FlxAnimationControllerTest;
import flixel.FlxCameraTest;
import flixel.FlxGTest;
import flixel.FlxSpriteTest;
import flixel.FlxStateTest;
import flixel.group.FlxGroupTest;
import flixel.tweens.FlxTweenTest;
import flixel.util.FlxSignalTest;
import FlxTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(flixel.animation.FlxAnimationControllerTest);
		add(flixel.FlxCameraTest);
		add(flixel.FlxGTest);
		add(flixel.FlxSpriteTest);
		add(flixel.FlxStateTest);
		add(flixel.group.FlxGroupTest);
		add(flixel.tweens.FlxTweenTest);
		add(flixel.util.FlxSignalTest);
		add(FlxTest);
	}
}
