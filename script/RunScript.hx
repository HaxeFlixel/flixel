package;

class RunScript
{
	/**
	 * Script that acts as an alias for "haxelib run flixel-tools".
	 */
	public static function main()
	{
		var args = Sys.args();
		args.pop(); // working directory path
		Sys.command("haxelib",  ["run", "flixel-tools"].concat(args));
	}
}