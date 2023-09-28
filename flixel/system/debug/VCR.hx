package flixel.system.debug;

#if FLX_DEBUG
import openfl.display.BitmapData;
import openfl.text.TextField;
import flixel.FlxG;
import flixel.system.ui.FlxSystemButton;
import flixel.system.debug.FlxDebugger.GraphicArrowRight;
#if FLX_RECORD
import flixel.util.FlxStringUtil;
#end

@:bitmap("assets/images/debugger/buttons/open.png")
private class GraphicOpen extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/pause.png")
private class GraphicPause extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/record_off.png")
private class GraphicRecordOff extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/record_on.png")
private class GraphicRecordOn extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/restart.png")
private class GraphicRestart extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/step.png")
private class GraphicStep extends BitmapData {}

@:bitmap("assets/images/debugger/buttons/stop.png")
private class GraphicStop extends BitmapData {}

/**
 * This class contains the record, stop, play, and step 1 frame buttons seen on the top edge of the debugger overlay.
 */
class VCR
{
	/**
	 * Texfield that displays the runtime display data for a game replay
	 */
	public var runtimeDisplay:TextField;

	public var runtime:Float = 0;

	/**
	 * `true` if the pause happened via the debugger UI, `false` if it happened programmatically
	 * (or if the VCR is not paused at all right now).
	 */
	public var manualPause(default, null):Bool = false;

	public var playbackToggleBtn:FlxSystemButton;
	public var stepBtn:FlxSystemButton;
	public var restartBtn:FlxSystemButton;
	public var recordBtn:FlxSystemButton;
	public var openBtn:FlxSystemButton;

	/**
	 * Creates the "VCR" control panel for debugger pausing, stepping, and recording.
	 */
	public function new(Debugger:FlxDebugger)
	{
		restartBtn = Debugger.addButton(CENTER, new GraphicRestart(0, 0), FlxG.resetState);
		#if FLX_RECORD
		recordBtn = Debugger.addButton(CENTER, new GraphicRecordOff(0, 0), FlxG.vcr.startRecording.bind(true));
		openBtn = Debugger.addButton(CENTER, new GraphicOpen(0, 0), FlxG.vcr.onOpen);
		#if !flash
		openBtn.enabled = false;
		openBtn.alpha = 0.3;
		#end
		#end
		playbackToggleBtn = Debugger.addButton(CENTER, new GraphicPause(0, 0), onManualPause);
		stepBtn = Debugger.addButton(CENTER, new GraphicStep(0, 0), onStep);

		#if FLX_RECORD
		runtimeDisplay = DebuggerUtil.createTextField(0, -9);
		updateRuntime(0);

		var runtimeBtn = Debugger.addButton(CENTER);
		runtimeBtn.addChild(runtimeDisplay);
		#end
	}

	#if FLX_RECORD
	/**
	 * Usually called by FlxGame when a requested recording has begun.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public inline function recording():Void
	{
		recordBtn.changeIcon(new GraphicRecordOn(0, 0));
		recordBtn.upHandler = FlxG.vcr.stopRecording.bind(true);
	}

	/**
	 * Usually called by FlxGame when a requested recording has stopped.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public inline function stoppedRecording():Void
	{
		recordBtn.changeIcon(new GraphicRecordOn(0, 0));
		recordBtn.upHandler = FlxG.vcr.startRecording.bind(true);
	}

	/**
	 * Usually called by FlxGame when a replay has been stopped.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public inline function stoppedReplay():Void
	{
		recordBtn.changeIcon(new GraphicRecordOff(0, 0));
		recordBtn.upHandler = FlxG.vcr.startRecording.bind(true);
	}

	/**
	 * Usually called by FlxGame when a requested replay has begun.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public inline function playingReplay():Void
	{
		recordBtn.changeIcon(new GraphicStop(0, 0));
		recordBtn.upHandler = FlxG.vcr.stopReplay;
	}

	/**
	 * Just updates the VCR GUI so the runtime displays roughly the right thing.
	 */
	public function updateRuntime(Time:Float):Void
	{
		runtime += Time;
		runtimeDisplay.text = FlxStringUtil.formatTime(Std.int(runtime / 1000), true);
		if (!runtimeDisplay.visible)
		{
			runtimeDisplay.visible = true;
		}
	}
	#end

	function onManualPause()
	{
		manualPause = true;
		FlxG.vcr.pause();
	}

	/**
	 * Called when the user presses the Pause button.
	 * This is different from user-defined pause behavior, or focus lost behavior.
	 * Does NOT pause music playback!!
	 */
	public function onPause():Void
	{
		playbackToggleBtn.upHandler = FlxG.vcr.resume;
		playbackToggleBtn.changeIcon(new GraphicArrowRight(0, 0));
	}

	/**
	 * Called when the user presses the Play button.
	 * This is different from user-defined unpause behavior, or focus gained behavior.
	 */
	public function onResume():Void
	{
		manualPause = false;
		playbackToggleBtn.upHandler = onManualPause;
		playbackToggleBtn.changeIcon(new GraphicPause(0, 0));
	}

	/**
	 * Called when the user presses the fast-forward-looking button.
	 * Requests a 1-frame step forward in the game loop.
	 */
	public function onStep():Void
	{
		if (!FlxG.vcr.paused)
		{
			FlxG.vcr.pause();
		}
		FlxG.vcr.stepRequested = true;
	}
}
#end
