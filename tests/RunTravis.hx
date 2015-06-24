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
		var target:Target = Sys.args()[0];
		if (target == null)
			target = Target.FLASH;
		
		Sys.exit(getResult([
			runUnitTests(target),
			buildCoverageTests(target),
			buildSwfVersionTests(target),
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
	
	static function buildCoverageTests(target:Target):ExitCode
	{
		Sys.println("\nBuilding coverage tests...\n");
		return getResult([
			build("coverage", target, "coverage1"),
			build("coverage", target, "coverage2")
		]);
	}
	
	static function buildDemos(target:Target):ExitCode
	{
		Sys.println("\nBuilding demos...\n");
		var demos = [];
		if (target == Target.CPP)
			demos = ["Mode", "RPG Interface", "FlxNape"];
		return haxelibRun(["flixel-tools", "bp", target].concat(demos));
	}
	
	static function buildSwfVersionTests(target:Target):ExitCode
	{
		if (target == Target.FLASH)
		{
			Sys.println("\nBuilding swf version tests...\n");
			return getResult([
				build("swfVersion/11", target),
				build("swfVersion/11_2", target)
			]);
		}
		else return ExitCode.SUCCESS;
	}
	
	static function build(path:String, target:Target, ?define:String):ExitCode
	{
		return runOpenFL("build", path, target, define);
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