package flixel.system;

/**
 * Helper object for semantic versioning.
 * @see   http://semver.org/
 */  
class FlxVersion
{
	public var major:Int;
	public var minor:Int;
	public var patch:Int;
	public var patchVersion:String;
	
	public function new(Major:Int, Minor:Int, Patch:Int, PatchVersion:String) 
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
	inline public function toString():String
	{
		return "HaxeFlixel " + major + "." + minor + "." + patch + "-" + patchVersion;
	}
}