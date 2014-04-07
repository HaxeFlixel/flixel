import massive.munit.TestSuite;

import flixel.FlxCameraTest;
import flixel.FlxGTest;
import flixel.FlxSpriteTest;
import flixel.FlxStateTest;
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
		
		add(FlxCameraTest);
		add(FlxGTest);
		add(FlxSpriteTest);
		add(FlxStateTest);
		add(FlxSignalTest);
		add(FlxTest);
	}
}
