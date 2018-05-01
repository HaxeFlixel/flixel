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
	
		var installationResult = runUntilFailure([
			installHaxelibs,
			installOpenFL.bind(openfl),
			installHxcpp.bind(target)
		]);

		if (installationResult != ExitCode.SUCCESS)
			Sys.exit(ExitCode.FAILURE);
		runCommand("haxelib", ["list"]);

		Sys.exit(runAll([
			runUnitTests.bind(target),
			buildCoverageTests.bind(target),
			buildSwfVersionTests.bind(target),
			buildDemos.bind(target),
			buildNextDemos.bind(target, openfl),
			buildMechanicsDemos.bind(target)
		]));
	}

	static function installHaxelibs():ExitCode
	{
		return runUntilFailure([
			haxelibInstall.bind("munit"),
			haxelibInstall.bind("hamcrest"),
			haxelibInstall.bind("systools"),
			haxelibInstall.bind("nape"),
			haxelibInstall.bind("task"),
			haxelibInstall.bind("poly2trihx"),
			haxelibInstall.bind("spinehaxe"),
			haxelibGit.bind("HaxeFoundation", "hscript"),
			haxelibGit.bind("larsiusprime", "firetongue"),
			haxelibGit.bind("HaxeFlixel", "flixel-tools"),
			haxelibGit.bind("HaxeFlixel", "flixel-demos"),
			haxelibGit.bind("HaxeFlixel", "flixel-addons"),
			haxelibGit.bind("HaxeFlixel", "flixel-ui")
		]);
	}

	static function installOpenFL(openfl:OpenFL):ExitCode
	{
		return runAll(switch (openfl)
		{
			case NEW: [
					haxelibGit.bind("openfl", "openfl"),
					runCommand.bind("wget", ["http://builds.openfl.org.s3-us-east-2.amazonaws.com/lime/lime-6.2.0-93-g430107f.zip"]),
					runCommand.bind("unzip", ["lime-6.2.0-93-g430107f.zip"]),
					runCommand.bind("haxelib", ["dev", "lime", "lime"])
				];
			case OLD: [haxelibInstall.bind("openfl", "3.6.1"), haxelibInstall.bind("lime", "2.9.1")];
		});
	}

	static function haxelibInstall(lib:String, ?version:String):ExitCode
	{
		var args = ["install", lib];
		if (version != null)
			args.push(version);
		args.push("--quiet");
		return runCommand("haxelib", args);
	}

	static function haxelibGit(user:String, lib:String):ExitCode
	{
		return runCommand("haxelib", ["git", lib, 'https://github.com/$user/$lib', "--quiet"]);
	}
	
	static function installHxcpp(target:Target):ExitCode
	{
		if (target != Target.CPP)
			return ExitCode.SUCCESS;

		var hxcppDir = Sys.getEnv("HOME") + "/haxe/lib/hxcpp/git/";
		return runAll([
			haxelibGit.bind("HaxeFoundation", "hxcpp"),
			runCommandInDir.bind(hxcppDir + "tools/run", "haxe", ["compile.hxml"]),
			runCommandInDir.bind(hxcppDir + "tools/hxcpp", "haxe", ["compile.hxml"]),
			runCommandInDir.bind(hxcppDir + "project", "neko", ["build.n"])
		]);
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
		return runAll([
			build.bind("coverage", target, "coverage1"),
			build.bind("coverage", target, "coverage2")
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
			return runAll([
				build.bind("swfVersion/11", target),
				build.bind("swfVersion/11_2", target)
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
	
	static function runAll(methods:Array<Void->ExitCode>):ExitCode
	{
		var result = ExitCode.SUCCESS;
		for (method in methods)
			if (method() != ExitCode.SUCCESS)
				result = ExitCode.FAILURE;
		return result;
	}

	static function runUntilFailure(methods:Array<Void->ExitCode>):ExitCode
	{
		for (method in methods)
			if (method() != ExitCode.SUCCESS)
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
