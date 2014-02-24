package flixel.system.debug;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.debug.Tracker.TrackerProfile;
import flixel.system.debug.Watch;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxStringUtil;

#if (!FLX_NO_MOUSE || !FLX_NO_TOUCH)
import flixel.input.FlxSwipe;
#end

class Tracker extends Watch
{
	#if !FLX_NO_DEBUG
	public static var profiles:Array<TrackerProfile>;
	
	public static inline function addProfile(Profile:TrackerProfile):Void
	{
		if (Profile != null)
		{
			profiles.push(Profile);
		}
	}
	
	private static var _numTrackerWindows:Int = 0;
	
	private var _object:Dynamic;
	
	public function new(Object:Dynamic, ?WindowTitle:String) 
	{
		super(true);
		_object = Object;
		initProfiles();
		
		var profile:TrackerProfile = findProfile();
		if ((profile == null) || (Object == null))
		{
			FlxG.log.error("FlxG.debugger.track(): Could not find a tracking profile for this object."); 
			close();
		}
		else
		{
			initWatchEntries(profile);
		}
		
		_title.text = (WindowTitle == null) ? FlxStringUtil.getClassName(_object, true) : WindowTitle;
		visible = true;
		update();
		
		var lastWatchEntryY:Float = _watching[_watching.length - 1].nameDisplay.y;
		resize(200, lastWatchEntryY + 30);
		
		// Small x and y offset
		x = _numTrackerWindows * 100;
		y = _numTrackerWindows * 50;
		_numTrackerWindows++;
	}
	
	override public function destroy():Void
	{
		_object = null;
		super.destroy();
	}
	
	private function initProfiles():Void
	{
		if (profiles == null)
		{
			profiles = [];
			
			addProfile(new TrackerProfile(FlxPoint, ["x", "y"]));
			addProfile(new TrackerProfile(FlxRect, ["x", "y", "width", "height"]));
			addProfile(new TrackerProfile(FlxBasic, ["active", "visible", "alive", "exists"]));
			addProfile(new TrackerProfile(FlxObject, ["velocity", "acceleration"], [FlxRect, FlxBasic]));
			addProfile(new TrackerProfile(FlxSprite, ["frameWidth", "frameHeight", 
			                                            "alpha", "origin", "offset", "scale"], [FlxObject]));
			
			#if (!FLX_NO_MOUSE || !FLX_NO_TOUCH)
			addProfile(new TrackerProfile(FlxSwipe, ["ID", "start", "end", "distance", "angle", "duration"]));
			#end
		}
	}
	
	private function findProfile():TrackerProfile
	{
		var lastMatchingProfile:TrackerProfile = null;
		for (profile in profiles)
		{
			if ((profile != null) && Std.is(_object, profile.objectClass))
			{
				lastMatchingProfile = profile;
			}
		}
		return lastMatchingProfile;
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
	
	public function new(ObjectClass:Class<Dynamic>, Variables:Array<String>, ?Extensions:Array<Class<Dynamic>>)
	{
		objectClass = ObjectClass;
		variables = Variables;
		extensions = Extensions;
	}
	
	public function toString():String
	{
		return FlxStringUtil.getDebugString([ { label: "vars", value: variables },
	                                          { label: "extensions", value: extensions } ]);
	}
}