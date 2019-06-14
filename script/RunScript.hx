package;

class RunScript
{
	/**
	 * Script that acts as an alias for "haxelib run flixel-tools".
	 */
	public static function main()
	{
		var args = Sys.args();
		var cwd = args.pop();
		Sys.setCwd(cwd);
		Sys.exit(Sys.command("haxelib", ["run", "flixel-tools"].concat(args)));
	}
}
