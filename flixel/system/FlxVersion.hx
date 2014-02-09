package flixel.system;

/**
 * Helper object for semantic versioning.
 * @see   http://semver.org/
 */  
class FlxVersion
{
	public var major(default, null):Int;
	public var minor(default, null):Int;
	public var patch(default, null):Int;
	public var patchVersion(default, null):String;
	
	public function new(Major:Int, Minor:Int, Patch:Int, PatchVersion:String = "") 
	{
		major = Major;
		minor = Minor;
		patch = Patch;
		patchVersion = PatchVersion;
	}
	
	/**
	 * Formats the version in the format "HaxeFlixel MAJOR.MINOR.PATCH-PATCH_VERSION", 
	 * e.g. HaxeFlixel 3.0.4
	 */
	public function toString():String
	{
		var patchVer = "";
		if ((patchVersion != null) && (patchVersion != ""))
		{
			patchVer = '-$patchVersion';
		}
		return "HaxeFlixel " + major + "." + minor + "." + patch + patchVer;
	}
}