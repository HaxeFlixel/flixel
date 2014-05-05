package flixel.system.debug;

#if !FLX_NO_DEBUG
import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxTypedGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.mouse.FlxMouse;
import flixel.input.touch.FlxTouch;
import flixel.input.FlxSwipe;
import flixel.system.debug.ConsoleUtil.PathToVariable;
import flixel.system.debug.Tracker.TrackerProfile;
import flixel.system.debug.Watch;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
#if !bitfive
import flixel.ui.FlxBar;
#end
import flixel.ui.FlxTypedButton.FlxTypedButton;
import flixel.util.FlxPath;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxTimer;
#end

import flixel.animation.FlxAnimationController;
import flixel.util.FlxStringUtil;

class Tracker extends Watch
{
	#if !FLX_NO_DEBUG
	/**
	 * Order matters here, as the last profile is the most releveant - i.e., if the 
	 * FlxSprite profile were added before the one for FlxObject, it would never be selected.
	 */
	public static var profiles:Array<TrackerProfile>;
	
	/**
	 * Stores a reference to all objects for a which a tracker window exists
	 * to prevent the creation of two windows for the same object.
	 */ 
	public static var objectsBeingTracked:Array<Dynamic> = [];
	
	private static var _numTrackerWindows:Int = 0;
	
	public static inline function addProfile(Profile:TrackerProfile):Void
	{
		if (Profile != null)
		{
			profiles.push(Profile);
		}
	}
	
	public static function findProfile(Object:Dynamic):TrackerProfile
	{
		initProfiles();
		
		var lastMatchingProfile:TrackerProfile = null;
		for (profile in profiles)
		{
			if (Std.is(Object, profile.objectClass) || (Object == profile.objectClass))
			{
				lastMatchingProfile = profile;
			}
		}
		return lastMatchingProfile;
	}
	
	public static function onStateSwitch():Void
	{
		_numTrackerWindows = 0;
	}
	
	private static function initProfiles():Void
	{
		if (profiles == null)
		{
			profiles = [];
			
			addProfile(new TrackerProfile(FlxG, ["width", "height", "worldBounds.x", "worldBounds.y", "worldBounds.width", "worldBounds.height", 
			                                     "worldDivisions", "updateFramerate", "drawFramerate", "elapsed", "maxElapsed", "autoPause", "fixedTimestep", "timeScale"]));
			
			addProfile(new TrackerProfile(FlxPoint, ["x", "y"]));
			addProfile(new TrackerProfile(FlxRect, ["width", "height"], [FlxPoint]));
			
			addProfile(new TrackerProfile(FlxBasic, ["active", "visible", "alive", "exists"]));
			addProfile(new TrackerProfile(FlxObject, ["velocity", "acceleration", "drag", "angle"],
			                                         [FlxRect, FlxBasic]));
			addProfile(new TrackerProfile(FlxTilemap, ["auto", "widthInTiles", "heightInTiles", "totalTiles", "scaleX", "scaleY"], [FlxObject]));
			addProfile(new TrackerProfile(FlxSprite, ["frameWidth", "frameHeight", "alpha", "origin", "offset", "scale"], [FlxObject]));
			addProfile(new TrackerProfile(FlxTypedButton, ["status", "labelAlphas"], [FlxSprite]));
			#if !bitfive // FlxBar uses FlxGradient which uses missing gradient matrix
			addProfile(new TrackerProfile(FlxBar, ["min", "max", "range", "pct", "pxPerPercent", "value"], [FlxSprite]));
			#end
			addProfile(new TrackerProfile(FlxText, ["text", "size", "font", "embedded", "bold", "italic", "wordWrap", "borderSize", 
			                                        "borderStyle"], [FlxSprite]));
			
			addProfile(new TrackerProfile(FlxTypedGroup, ["length", "members.length", "maxSize"], [FlxBasic]));
			addProfile(new TrackerProfile(FlxSpriteGroup, null, [FlxSprite, FlxTypedGroup]));
			addProfile(new TrackerProfile(FlxState, ["persistentUpdate", "persistentDraw", "destroySubStates", "bgColor"], [FlxTypedGroup]));
			
			addProfile(new TrackerProfile(FlxCamera, ["style", "followLerp", "followLead", "deadzone", "bounds", "zoom", 
			                                          "alpha", "angle"], [FlxBasic, FlxRect]));
			
			addProfile(new TrackerProfile(FlxTween, ["active", "duration", "type", "percent", "finished", 
			                                         "scale", "backward", "executions", "startDelay", "loopDelay"]));
			
			addProfile(new TrackerProfile(FlxPath, ["speed", "angle", "autoCenter", "_nodeIndex", "active", "finished"]));
			addProfile(new TrackerProfile(FlxTimer, ["time", "loops", "active", "finished", "timeLeft", "elapsedTime", "loopsLeft", "elapsedLoops", "progress"]));
			
			addProfile(new TrackerProfile(FlxAnimationController, ["frameIndex", "frameName", "name", "paused", "finished", "frames"]));
			
			// Inputs
			#if !FLX_NO_MOUSE
			addProfile(new TrackerProfile(FlxMouse, ["screenX", "screenY", "wheel", "visible", "useSystemCursor", "pressed", "justPressed", 
			                                         "justReleased" #if !FLX_NO_MOUSE_ADVANCED , "pressedMiddle", "justPressedMiddle", 
			                                         "justReleasedMiddle", "pressedRight", "justPressedRight", "justReleasedRight" #end], [FlxPoint]));
			#end
			#if !FLX_NO_TOUCH 
			addProfile(new TrackerProfile(FlxTouch, ["screenX", "screenY", "touchPointID", "pressed", "justPressed", "justReleased", "isActive"], [FlxPoint]));
			#end
			#if !FLX_NO_GAMEPAD
			addProfile(new TrackerProfile(FlxGamepad, ["id", "deadZone", "hat", "ball", "dpadUp", "dpadDown", "dpadLeft", "dpadRight"]));
			#end
			
			#if (!FLX_NO_MOUSE || !FLX_NO_TOUCH)
			addProfile(new TrackerProfile(FlxSwipe, ["ID", "startPosition", "endPosition", "distance", "angle", "duration"]));
			#end
			
			addProfile(new TrackerProfile(DisplayObject, ["z", "scaleX", "scaleY", "mouseX", "mouseY", "rotationX", "rotationY", "visible"], [FlxRect]));
			addProfile(new TrackerProfile(Point, null, [FlxPoint]));
			addProfile(new TrackerProfile(Rectangle, null, [FlxRect]));
			addProfile(new TrackerProfile(Matrix, ["a", "b", "c", "d", "tx", "ty"]));
		}
	}
	
	private var _object:Dynamic;
	
	public function new(Profile:TrackerProfile, Object:Dynamic, ?WindowTitle:String) 
	{
		super(true);
		
		initProfiles();
		_object = Object;
		objectsBeingTracked.push(_object);
		
		initWatchEntries(Profile);
		
		_title.text = (WindowTitle == null) ? FlxStringUtil.getClassName(_object, true) : WindowTitle;
		visible = true;
		
		var lastWatchEntryY:Float = _watching[_watching.length - 1].nameDisplay.y;
		resize(200, lastWatchEntryY + 30);
		
		// Small x and y offset
		x = _numTrackerWindows * 80;
		y = _numTrackerWindows * 25 + 20;
		_numTrackerWindows++;
		
		FlxG.signals.stateSwitched.add(close);
	}
	
	override public function destroy():Void
	{
		FlxG.signals.stateSwitched.remove(close);
		_numTrackerWindows--;
		objectsBeingTracked.remove(_object);
		_object = null;
		super.destroy();
	}
	
	private function findProfileByClass(ObjectClass:Class<Dynamic>):TrackerProfile
	{
		for (profile in profiles)
		{
			if (profile.objectClass == ObjectClass)
			{
				return profile;
			}
		}
		return null;
	}
	
	private function initWatchEntries(Profile:TrackerProfile):Void
	{
		if (Profile != null)
		{
			addExtensions(Profile);
			addVariables(Profile.variables);
		}
	}
	
	private function addExtensions(Profile:TrackerProfile):Void
	{
		if (Profile.extensions != null)
		{
			for (extension in Profile.extensions)
			{
				if (extension != null)
				{
					var extensionProfile:TrackerProfile = findProfileByClass(extension);
					if (extensionProfile != null)
					{
						addVariables(extensionProfile.variables);
						addExtensions(extensionProfile); // recursively
					}
				}
			}
		}
	}
	
	private function addVariables(Variables:Array<String>):Void
	{
		if (Variables != null)
		{
			for (variable in Variables)
			{
				add(_object, variable, variable);
			}
		}
	}
	#end
}

class TrackerProfile
{
	public var objectClass:Class<Dynamic>;
	public var variables:Array<String>;
	public var extensions:Array<Class<Dynamic>>;
	
	public function new(ObjectClass:Class<Dynamic>, ?Variables:Array<String>, ?Extensions:Array<Class<Dynamic>>)
	{
		objectClass = ObjectClass;
		variables = Variables;
		extensions = Extensions;
	}
	
	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("variables", variables),
			LabelValuePair.weak("extensions", extensions)]);
	}
}