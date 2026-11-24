package flixel.system;

/**
 * Helper object for semantic versioning.
 * @see   http://semver.org/
 */
class FlxVersion
{
	public final major:Int;
	public final minor:Int;
	public final patch:Int;
    public final prerelease:Null<String>;
    public final buildMetadata:Null<String>;
	public final sha:Null<String>;

	inline public function new(major:Int, minor:Int, patch:Int, ?prerelease:String, ?buildMetadata:String, ?sha:String)
	{
		this.major = major;
		this.minor = minor;
		this.patch = patch;
		this.prerelease = prerelease;
		this.buildMetadata = buildMetadata;
		this.sha = sha;
	}

	/**
	 * Formats the version in the format "HaxeFlixel MAJOR.MINOR.PATCH-COMMIT_SHA",
	 * e.g. HaxeFlixel 3.0.4.
	 * If this is a dev version, the git sha is included.
	 */
	inline public function toString():String
	{
		final displaySha = (sha == null ? "" : "@" + sha.substr(0, 7));
        final displayPrerelease = (prerelease == null ? "" : '-$prerelease');
        final displayMeta = (buildMetadata == null ? "" : '+$buildMetadata');
        return 'HaxeFlixel $major.$minor.$patch$displayPrerelease$displayMeta$displaySha';
	}
}
