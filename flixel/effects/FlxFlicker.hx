package flixel.effects;

import flixel.FlxObject;
import flixel.util.FlxPool;
import flixel.util.FlxTimer;
import flixel.interfaces.IFlxDestroyable;

/**
* The retro flickering effect with callbacks.
* You can use this as a mixin in any FlxObject subclass or by calling the static functions.
* @author pixelomatic
*/
class FlxFlicker implements IFlxDestroyable
{
	/**
	* Pool for reusing FlxFlicker objects.
	*/
	public static var pool:FlxPool<FlxFlicker> = new FlxPool<FlxFlicker>(FlxFlicker);
	/**
	* The flickering object.
	*/
	public var object(default, null):FlxObject;
	
	/**
	* The final visibility of the object after flicker is complete.
	*/
	public var endVisibility(default, null):Bool;
	
	/**
	* The flicker timer. You can check how many seconds has passed since flickering started etc.
	*/
	public var timer(default, null):FlxTimer;
	
	/**
	* The callback that will be triggered after flicker has completed.
	*/
	public var completionCallback(default, null):FlxFlicker->Void;
	
	/**
	* The callback that will be triggered every time object visiblity is changed.
	*/
	public var progressCallback(default, null):FlxFlicker->Void;
	
	/**
	* The duration of the flicker.
	*/
	public var duration(default, null):Float;
	
	/**
	* The interval of the flicker.
	*/
	public var interval(default, null):Float;
	
	/**
	* Internal map for looking up which objects are currently flickering and getting their flicker data.
	*/
	private static var _boundObjects:Map<FlxObject, FlxFlicker> = new Map<FlxObject, FlxFlicker>();
	
	/**
	* A simple flicker effect for sprites using a ping-pong tween by toggling visibility.
	* 
	* @param  Object            The sprite.
	* @param  Duration        How long to flicker for.
	* @param  Interval          In what interval to toggle visibility. Set to FlxG.elapsed if <= 0!
	* @param  EndVisibility    Force the visible value when the flicker completes, useful with fast repetitive use.
	* @param  ForceRestart    Force the flicker to restart from beginnig, discarding the flickering effect already in progress if there is one.
	* @param  ?CompletionCallback An optional callback that will be triggered when a flickering has finished.
	* @param  ?ProgressCallback   An optional callback that will be triggered when visibility is toggled.
	*/
	public static function flicker(Object:FlxObject, Duration:Float = 1, Interval:Float = 0.04, EndVisibility:Bool = true, ForceRestart:Bool = true, ?CompletionCallback:FlxFlicker->Void, ?ProgressCallback:FlxFlicker->Void):Void
	{
		if (isFlickering(Object))
		{
			if (ForceRestart)
			{
				stopFlickering(Object);
			}
			else
			{
				// Ignore this call if object is already flickering.
				return;
			}
		}
		
		if (Interval <= 0) 
		{
			Interval = FlxG.elapsed;
		}
		
		var flicker:FlxFlicker = pool.get();
		flicker.start(Object, Duration, Interval, EndVisibility, CompletionCallback, ProgressCallback);
		_boundObjects[Object] = flicker;
	}
	
	/**
	* Returns whether the object is flickering or not.
	* @param  Object The object to test.
	*/
	public static function isFlickering(Object:FlxObject):Bool
	{
		return _boundObjects.exists(Object);
	}
	
	/**
	* Stops flickering of the object. Also it will make the object visible.
	* @param  Object The object to stop flickering.
	*/
	public static function stopFlickering(Object:FlxObject):Void
	{
		var boundFlicker:FlxFlicker = _boundObjects[Object];
		if (boundFlicker != null)
		{
			boundFlicker.stop();
		}
	}
	
	/**
	* Nullifies the references to prepare object for reuse and avoid memory leaks.
	*/
	public function destroy():Void
	{
		object = null;
		timer = null;
		completionCallback = null;
		progressCallback = null;
	}
	
	/**
	* Starts flickering behavior.
	* @param  Object
	* @param  Duration
	* @param  Interval
	* @param  EndVisibility
	* @param  ?CompletionCallback
	* @param  ?ProgressCallback
	*/
	private function start(Object:FlxObject, Duration:Float, Interval:Float, EndVisibility:Bool, ?CompletionCallback:FlxFlicker->Void, ?ProgressCallback:FlxFlicker->Void):Void
	{
		object = Object;
		duration = Duration;
		interval = Interval;
		completionCallback = CompletionCallback;
		progressCallback = ProgressCallback;
		endVisibility = EndVisibility;
		timer = FlxTimer.start(interval, flickerProgress, Std.int(duration / interval));
	}
	
	/**
	* Prematurely ends flickering.
	*/
	private function stop():Void
	{
		timer.abort();
		object.visible = true;
		release();
	}
	
	/**
	* Unbinds the object from flicker and releases it into pool for reuse.
	*/
	private function release():Void
	{
		_boundObjects.remove(object);
		pool.put(this);
	}
	
	/**
	* Just a helper function for flicker() to update object's visibility.
	*/
	private function flickerProgress(Timer:FlxTimer):Void
	{
		object.visible = !object.visible;
		
		if (progressCallback != null)
		{
			progressCallback(this);
		}
		
		if (Timer.loops > 0 && Timer.loopsLeft == 0)
		{
			object.visible = endVisibility;
			if (completionCallback != null)
			{
				completionCallback(this);
			}
			release();
		}
	}
	
	/**
	* Internal constructor. Use static methods.
	*/
	private function new() {  }
}