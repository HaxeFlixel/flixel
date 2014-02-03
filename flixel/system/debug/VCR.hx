package flixel.system.debug;

#if !FLX_NO_DEBUG
import flash.display.BitmapData;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

@:bitmap("assets/images/debugger/buttons/open.png")         private class GraphicOpen        extends BitmapData {}
@:bitmap("assets/images/debugger/buttons/pause.png")        private class GraphicPause       extends BitmapData {}
@:bitmap("assets/images/debugger/buttons/play.png")         private class GraphicPlay        extends BitmapData {}
@:bitmap("assets/images/debugger/buttons/record_off.png")   private class GraphicRecordOff   extends BitmapData {}
@:bitmap("assets/images/debugger/buttons/record_on.png")    private class GraphicRecordOn    extends BitmapData {}
@:bitmap("assets/images/debugger/buttons/restart.png")      private class GraphicRestart     extends BitmapData {}
@:bitmap("assets/images/debugger/buttons/step.png")         private class GraphicStep        extends BitmapData {}
@:bitmap("assets/images/debugger/buttons/stop.png")         private class GraphicStop        extends BitmapData {}

/**
 * This class contains the record, stop, play, and step 1 frame buttons seen on the top edge of the debugger overlay.
 */
class VCR
{
	/**
	* Texfield that displays the runtime display data for a game replay
	*/
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
	public function new(Debugger:FlxDebugger)
	{
		restartBtn = Debugger.addButton(MIDDLE, new GraphicRestart(0, 0), FlxG.resetState);
		#if FLX_RECORD
		recordBtn = Debugger.addButton(MIDDLE, new GraphicRecordOff(0, 0), FlxG.vcr.startRecording.bind(true));
		openBtn = Debugger.addButton(MIDDLE, new GraphicOpen(0, 0), FlxG.vcr.onOpen);
		#end
		playbackToggleBtn = Debugger.addButton(MIDDLE, new GraphicPause(0, 0), FlxG.vcr.pause);
		stepBtn = Debugger.addButton(MIDDLE, new GraphicStep(0, 0), onStep);
		
		#if FLX_RECORD
		runtimeDisplay = new TextField();
		runtimeDisplay.height = 10;
		runtimeDisplay.y = -9;
		runtimeDisplay.selectable = false;
		runtimeDisplay.multiline = false;
		runtimeDisplay.embedFonts = true;
		var format = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, FlxColor.WHITE);
		runtimeDisplay.defaultTextFormat = format;
		runtimeDisplay.autoSize = TextFieldAutoSize.LEFT;
		updateRuntime(0);
		
		var runtimeBtn = Debugger.addButton(MIDDLE);
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
		recordBtn.downHandler = FlxG.vcr.stopRecording;
	}

	/**
	 * Usually called by FlxGame when a requested recording has stopped.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public inline function stoppedRecording():Void
	{
		recordBtn.changeIcon(new GraphicRecordOn(0, 0));
		recordBtn.downHandler = FlxG.vcr.startRecording.bind(true);
	}
	
	/**
	 * Usually called by FlxGame when a replay has been stopped.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public inline function stoppedReplay():Void
	{
		recordBtn.changeIcon(new GraphicRecordOff(0, 0));
		recordBtn.downHandler = FlxG.vcr.startRecording.bind(true);
	}
	
	/**
	 * Usually called by FlxGame when a requested replay has begun.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public inline function playingReplay():Void
	{
		recordBtn.changeIcon(new GraphicStop(0, 0));
		recordBtn.downHandler = FlxG.vcr.stopReplay;
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
	public inline function onPause():Void
	{
		playbackToggleBtn.downHandler = FlxG.vcr.resume;
		playbackToggleBtn.changeIcon(new GraphicPlay(0, 0));
	}

	/**
	 * Called when the user presses the Play button.
	 * This is different from user-defined unpause behavior, or focus gained behavior.
	 */
	public inline function onResume():Void
	{
		playbackToggleBtn.downHandler = FlxG.vcr.pause;
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
