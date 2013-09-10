package flixel.system.debug;

import flixel.util.FlxColor;
import flash.text.TextFieldAutoSize;
import flixel.system.ui.FlxSystemButton;
import flash.display.BitmapData;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.system.FlxAssets;
import flixel.FlxG;
import flixel.util.FlxStringUtil;
import openfl.Assets;

/**
 * This class contains the record, stop, play, and step 1 frame buttons seen on the top edge of the debugger overlay.
 */
class VCR
{
	/**
	* Texfield that displays the runtime display data for a game replay
	**/
	public var runtimeDisplay:TextField;
	
	public var runtime:Int = 0;

	public var playbackToggleBtn:FlxSystemButton;
	public var stepBtn:FlxSystemButton;
	public var restartBtn:FlxSystemButton;
	public var recordBtn:FlxSystemButton;
	public var openBtn:FlxSystemButton;

	/**
	 * Creates the "VCR" control panel for debugger pausing, stepping, and recording.
	 */
	public function new()
	{
		playbackToggleBtn = new FlxSystemButton(FlxAssets.getBitmapData(FlxAssets.IMG_PAUSE), FlxG.vcr.pause);
		stepBtn = new FlxSystemButton(FlxAssets.getBitmapData(FlxAssets.IMG_STEP), onStep);
		restartBtn = new FlxSystemButton(FlxAssets.getBitmapData(FlxAssets.IMG_RESTART), FlxG.resetState);

		#if FLX_RECORD
		recordBtn = new FlxSystemButton(FlxAssets.getBitmapData(FlxAssets.IMG_RECORD_OFF), FlxG.vcr.startRecording);
		openBtn = new FlxSystemButton(FlxAssets.getBitmapData(FlxAssets.IMG_OPEN), FlxG.vcr.onOpen);

		runtimeDisplay = new TextField();
		runtimeDisplay.height = 10;
		runtimeDisplay.selectable = false;
		runtimeDisplay.multiline = false;
		runtimeDisplay.embedFonts = true;
		var format = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, FlxColor.WHITE);
		runtimeDisplay.defaultTextFormat = format;
		runtimeDisplay.autoSize = TextFieldAutoSize.LEFT;
		updateRuntime(0);
		#end
	}

	#if FLX_RECORD
	/**
	 * Usually called by FlxGame when a requested recording has begun.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public function recording():Void
	{
		recordBtn.changeIcon(FlxAssets.getBitmapData(FlxAssets.IMG_RECORD_ON));
		recordBtn.changeHandler(FlxG.vcr.stopRecording);
	}

	/**
	 * Usually called by FlxGame when a requested recording has stopped.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public function stoppedRecording():Void
	{
		recordBtn.changeIcon(FlxAssets.getBitmapData(FlxAssets.IMG_RECORD_ON));
		recordBtn.changeHandler(FlxG.vcr.startRecording);
	}
	
	/**
	 * Usually called by FlxGame when a replay has been stopped.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public function stoppedReplay():Void
	{
		recordBtn.changeIcon(FlxAssets.getBitmapData(FlxAssets.IMG_RECORD_OFF));
		recordBtn.changeHandler(FlxG.vcr.startRecording);
	}
	
	/**
	 * Usually called by FlxGame when a requested replay has begun.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public function playingReplay():Void
	{
		recordBtn.changeIcon(FlxAssets.getBitmapData(FlxAssets.IMG_STOP));
		recordBtn.changeHandler(FlxG.vcr.stopReplay);
	}
	
	/**
	 * Just updates the VCR GUI so the runtime displays roughly the right thing.
	 */
	public function updateRuntime(Time:Int):Void
	{
		runtime += Time;
		runtimeDisplay.text = FlxStringUtil.formatTime(Std.int(runtime / 1000), true);
		if (!runtimeDisplay.visible)
		{
			runtimeDisplay.visible = true;
		}
	}
	#end

	/**
	 * Called when the user presses the Pause button.
	 * This is different from user-defined pause behavior, or focus lost behavior.
	 * Does NOT pause music playback!!
	 */
	public function onPause():Void
	{
		playbackToggleBtn.changeHandler(FlxG.vcr.resume);
		playbackToggleBtn.changeIcon(FlxAssets.getBitmapData(FlxAssets.IMG_PLAY));
	}

	/**
	 * Called when the user presses the Play button.
	 * This is different from user-defined unpause behavior, or focus gained behavior.
	 */
	public function onResume():Void
	{
		playbackToggleBtn.changeHandler(FlxG.vcr.pause);
		playbackToggleBtn.changeIcon(FlxAssets.getBitmapData(FlxAssets.IMG_PAUSE));
	}

	/**
	 * Called when the user presses the fast-forward-looking button.
	 * Requests a 1-frame step forward in the game loop.
	 */
	public function onStep():Void
	{
		if (!FlxG.vcr.paused)
		{
			onPause();
		}
		FlxG.vcr.stepRequested = true;
	}
}