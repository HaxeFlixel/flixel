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
abstract OpenFL(String) from String to String
{
	var OLD = "old";
	var NEW = "new";
}

@:enum
abstract ExitCode(Int) from Int to Int
{
	var SUCCESS = 0;
	var FAILURE = 1;
}

class RunTravis
{
	static var importantDemos = ["Mode"];
	static var dryRun:Bool;

	public static function main():Void
	{
		var target:Target = Sys.args()[0];
		if (target == null)
			target = Target.FLASH;

		var openfl:OpenFL = Sys.args()[1];
		
		dryRun = Sys.args().indexOf("-dry-run") != -1;
	
		Sys.exit(getResult([
			installOpenFL(openfl),
			installHxcpp(target),
			runUnitTests(target),
			buildCoverageTests(target),
			buildSwfVersionTests(target),
			buildDemos(target),
			buildNextDemos(target, openfl),
			buildMechanicsDemos(target)
		]));
	}

	static function installOpenFL(openfl:OpenFL):ExitCode
	{
		return getResult(switch (openfl)
		{
			case NEW: [runCommand("haxelib", ["git", "openfl", "https://github.com/openfl/openfl", "Gama11-patch-1"]), haxelibInstall("lime")];
			case OLD: [haxelibInstall("openfl", "3.6.1"), haxelibInstall("lime", "2.9.1")];
		});
	}

	static function haxelibInstall(lib:String, ?version:String):ExitCode
	{
		var args = ["install", lib];
		if (version != null)
			args.push(version);
		return runCommand("haxelib", args);
	}
	
	static function installHxcpp(target:Target):ExitCode
	{
		if (target != Target.CPP)
			return ExitCode.SUCCESS;

		#if (haxe_ver >= "3.3")
		var hxcppDir = Sys.getEnv("HOME") + "/haxe/lib/hxcpp/git/";
		return getResult([
			runCommand("haxelib", ["git", "hxcpp", "https://github.com/HaxeFoundation/hxcpp"]),
			runCommandInDir(hxcppDir + "tools/run", "haxe", ["compile.hxml"]),
			runCommandInDir(hxcppDir + "tools/hxcpp", "haxe", ["compile.hxml"]),
			runCommandInDir(hxcppDir + "project", "neko", ["build.n"])
		]);
		#else
		return haxelibInstall("hxcpp", "3.3.49");
		#end
	}
	
	static function runCommandInDir(dir:String, cmd:String, args:Array<String>):ExitCode
	{
		return runInDir(dir, function() return runCommand(cmd, args));
	}
	
	static function runUnitTests(target:Target):ExitCode
	{
		if (target == Target.FLASH)
			return ExitCode.SUCCESS;

		runInDir("unit", function()
			return haxelibRun(["munit", "gen"])
		);

		if (target == Target.FLASH || target == Target.HTML5)
		{	
			// can't run / display results without a browser,
			// this at least checks if the tests compile
			Sys.println("Building unit tests...\n");
			return build("unit", target);
		}
		else
		{
			Sys.println("Running unit tests...\n");
			return runOpenFL("test", "unit", target);
		}
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
			demos = importantDemos;
		return buildProjects(target, demos);
	}
	
	static function buildNextDemos(target:Target, openfl:OpenFL):ExitCode
	{
		if (target == Target.FLASH || target == Target.HTML5 || openfl == NEW)
			return ExitCode.SUCCESS;
		
		Sys.println("\nBuilding demos for OpenFL Next...\n");
		return buildProjects(target, importantDemos.concat(["-Dnext"]));
	}
	
	static function buildMechanicsDemos(target:Target):ExitCode
	{
		if (target == Target.CPP)
			return ExitCode.SUCCESS;
		
		Sys.println("\nBuilding mechanics demos...\n");
		runCommand("git", ["clone", "https://github.com/HaxeFlixel/haxeflixel-mechanics"]);
		
		return buildProjects(target, ["-dir", "haxeflixel-mechanics"]);
	}
	
	static function buildProjects(target:Target, args:Array<String>):ExitCode
	{
		return haxelibRun(["flixel-tools", "bp", target].concat(args));
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
		return runCommand("haxelib", ["run"].concat(args));
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
		cd(dir);
		var result = func();
		cd(oldCwd);
		return result;
	}
	
	static function cd(dir:String)
	{
		Sys.println("cd " + dir);
		if (!dryRun)
			Sys.setCwd(dir);
	}
	
	static function runCommand(cmd:String, args:Array<String>):ExitCode
	{
		Sys.println(cmd + " " + args.join(" "));
		if (dryRun)
			return ExitCode.SUCCESS;
		return Sys.command(cmd, args);
	}
}