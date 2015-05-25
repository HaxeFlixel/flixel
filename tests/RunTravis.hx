package;

@:enum
abstract Target(String) from String to String
{
	var FLASH = "flash";
	var NEKO = "neko";
	var CPP = "cpp";
	var HTML5 = "html5";
}

@:enum
abstract ExitCode(Int) from Int to Int
{
	var SUCCESS = 0;
	var FAILURE = 1;
}

class RunTravis
{
	public static function main():Void
	{
		var target:Target = Sys.getEnv("TARGET");
		Sys.exit(getResult([
			runUnitTests(target),
			runCoverageTests(target),
			buildDemos(target)
		]));
	}
	
	static function runUnitTests(target:Target):ExitCode
	{
		if (target == Target.HTML5) // no HTML5 unit tests atm
			return ExitCode.SUCCESS;
		
		Sys.println("Running unit tests...\n");
		if (target == Target.FLASH)
		{
			return runInDir("unit", function() {
				// can't run / display results without a browser,
				// this at least checks if the tests compile
				return haxelibRun(["munit", "test", "-as3", "-norun"]);
			});
		}
		else return runOpenFL("test", "unit", target);
	}
	
	static function runCoverageTests(target:Target):ExitCode
	{
		Sys.println("\nRunning coverage tests...\n");
		return getResult([
			runOpenFL("build", "coverage", target, "coverage1"),
			runOpenFL("build", "coverage", target, "coverage2")
		]);
	}
	
	static function buildDemos(target:Target):ExitCode
	{
		Sys.println("\nBuilding demos...\n");
		var demos = [];
		if (target == Target.CPP)
			demos = ["Mode", '"RPG Interface"', "FlxNape"];
		return haxelibRun(["flixel-tools", "td", target].concat(demos));
	}
	
	static function runOpenFL(operation:String, path:String, target:Target, ?define:String):ExitCode
	{
		var args = ["openfl", operation, path, target];
		if (define != null)
			args.push('-D$define');
		return haxelibRun(args);
	}
	
	static function haxelibRun(args:Array<String>):ExitCode
	{
		return Sys.command("haxelib", ["run"].concat(args));
	}
	
	static function getResult(results:Array<ExitCode>):ExitCode
	{
		for (result in results)
			if (result != ExitCode.SUCCESS)
				return ExitCode.FAILURE;
		return ExitCode.SUCCESS;
	}
	
	static function runInDir(dir:String, func:Void->ExitCode):ExitCode
	{
		var oldCwd = Sys.getCwd();
		Sys.setCwd(dir);
		var result = func();
		Sys.setCwd(oldCwd);
		return result;
	}
}