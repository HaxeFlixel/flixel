package flixel;

import flixel.FlxG;
import massive.munit.Assert;

@:access(flixel.FlxG)
class FlxGTest extends FlxTest
{
	@Test function VERSIONNull():Void     { Assert.isNotNull(FlxG.VERSION); }
	@Test function gameNull():Void        { Assert.isNotNull(FlxG.game); }
	@Test function stageNull():Void       { Assert.isNotNull(FlxG.stage); }
	@Test function stateNull():Void       { Assert.isNotNull(FlxG.state); }
	@Test function worldBoundsNull():Void { Assert.isNotNull(FlxG.worldBounds); }
	@Test function saveNull():Void        { Assert.isNotNull(FlxG.save); }
	
	/** Inputs **/
	
	#if !FLX_NO_MOUSE
	@Test function mouseNull():Void       { Assert.isNotNull(FlxG.mouse); }
	#end
	#if !FLX_NO_TOUCH
	@Test function touchNull():Void       { Assert.isNotNull(FlxG.touches); }
	#end
	#if (!FLX_NO_MOUSE || !FLX_NO_TOUCH)
	@Test function swipesNull():Void      { Assert.isNotNull(FlxG.swipes); }
	#end
	#if !FLX_NO_KEYBOARD
	@Test function keysNull():Void        { Assert.isNotNull(FlxG.keys); }
	#end
	#if !FLX_NO_GAMEPAD
	@Test function gamepadsNull():Void    { Assert.isNotNull(FlxG.gamepads); }
	#end
	#if android
	@Test function androidNull():Void     { Assert.isNotNull(FlxG.android); }
	#end
	#if html5
	@Test function html5Null():Void       { Assert.isNotNull(FlxG.html5); }
	#end
	
	/** frontends **/
	
	@Test function inputsNull():Void      { Assert.isNotNull(FlxG.inputs); }
	@Test function consoleNull():Void     { Assert.isNotNull(FlxG.console); }
	@Test function logNull():Void         { Assert.isNotNull(FlxG.log); }
	@Test function watchNull():Void       { Assert.isNotNull(FlxG.watch); }
	@Test function debuggerNull():Void    { Assert.isNotNull(FlxG.debugger); }
	@Test function vcrNull():Void         { Assert.isNotNull(FlxG.vcr); }
	@Test function bitmapNull():Void      { Assert.isNotNull(FlxG.bitmap); }
	@Test function camerasNull():Void     { Assert.isNotNull(FlxG.cameras); }
	@Test function pluginsNull():Void     { Assert.isNotNull(FlxG.plugins); }
	#if !FLX_NO_SOUND_SYSTEM
	@Test function soundNull():Void       { Assert.isNotNull(FlxG.sound); }
	#end
	
	@Test function _scaleModeNull():Void   { Assert.isNotNull(FlxG._scaleMode); }
	
	@Test function initialWidth():Void
	{
		Assert.areEqual(FlxG.width, 640);
	}
	
	@Test function initialHeight():Void
	{
		Assert.areEqual(FlxG.height, 480);
	}
}