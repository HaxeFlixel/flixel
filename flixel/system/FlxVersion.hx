package flixel.system;

/**
 * Helper object for semantic versioning.
 * @see   http://semver.org/
 */
@:build(flixel.system.macros.FlxGitSHA.buildGitSHA("flixel"))
class FlxVersion
{
	public var major(default, null):Int;
	public var minor(default, null):Int;
	public var patch(default, null):Int;

	public var branch(default, null):String;
	public var display(default, null):String;
	
	public function new(Major:Int, Minor:Int, Patch:Int, ?Branch:String, ?Display:String)
	{
		major = Major;
		minor = Minor;
		patch = Patch;
		if (Branch != null)
			branch = '-$Branch';
			
		if (Display != null)
			display = '$Display ';
	}

	/**
	 * Formats the version in the format "HaxeFlixel MAJOR.MINOR.PATCH-COMMIT_SHA",
	 * e.g. HaxeFlixel 3.0.4.
	 * If this is a dev version, the git sha is included.
	 */
	public function toString():String
	{
		var sha = FlxVersion.sha;
		if (sha != "")
		{
			sha = "@" + sha.substring(0, 7);
		}
		return '$display$major.$minor.$patch$branch$sha';
	}
}
