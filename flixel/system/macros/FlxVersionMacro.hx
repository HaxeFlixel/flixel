package flixel.system.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.io.Process;

using StringTools;
using haxe.macro.Tools;
#end

class FlxVersionMacro
{
	/**
	 * Group order: `[ 1 => major, 2 => minor, 3 => patch, 4 => prerelease, 5 => buildmetadata ]`
	 */
	static public final semver = ~/^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$/;
	
	#if macro
	static public function build()
	{
		switch (Context.getLocalType())
		{
			case TInst(_.get() => type, [TInst(_.get() => {kind: KExpr(macro $v{(id : String)})}, _)]):
				// trace(id, type.name);
				return buildType(type, id);
			case t:
				throw 'Class expected, found ${t}';
		}
		return null;
	}

	static function buildType(type:ClassType, id:String):ComplexType
	{
		final name = 'Version__$id';

		// Check whether the generated type already exists
		try
		{
			Context.getType(name);
			
			// Return a `ComplexType` for the generated type
			return TPath({pack: [], name: name});
		} catch (e) {} // The generated type doesn't exist yet

		final ct = Context.getLocalType().toComplexType();
		final defineID = id == null ? "log" : '$id.log';
		switch ct
		{
			case TPath(path):
				// define the type
				// final superClass = type.superClass.t.get();
				// final superTp = 
				// 	{ pack: path.pack
				// 	, name: path.name
				// 	, sub: superClass.name
				// 	#if haxe5
				// 	, pos: path.pos
				// 	#end
				// 	};
				
				if (Context.definedValue(id) == null)
					throw 'Haxelib $id not found';
				
				final libVersion = Context.definedValue(id);
				if (false == semver.match(libVersion))
					throw 'Could not parse lib version "$libVersion"';
				
				final major = Std.parseInt(semver.matched(1));
				final minor = Std.parseInt(semver.matched(2));
				final patch = Std.parseInt(semver.matched(3));
				final prerelease = semver.matched(4);
				final buildMetadata = semver.matched(5);
				
				final libPath = getLibraryPath(id);
				final sha = getGitSHA(libPath);
				final branchRaw = getGitBranch(libPath);
				final defaultBranch = getGitDefaultBranch(libPath).split("/").pop();
				
				final branch = branchRaw == defaultBranch ? null : branchRaw;
				
				// final def = macro class $name extends $superTp {
				final def = macro class $name extends flixel.system.FlxVersion {
					inline public function new()
					{
						super($v{major}, $v{minor}, $v{patch}, $v{prerelease}, $v{buildMetadata}, $v{sha});
					}
				}
				
				Context.defineType(def);
				return TPath({pack: [], name: name});
			case unexpected:
				throw 'Unexpected $unexpected';
		}
		return null;
	}
	
	public static function getLibraryPath(library:String):String
	{
		final output = getProcessOutput("haxelib", ["path", library]);
		if (output == null)
			throw 'Invalid haxelib: "$library"';
		
		final lines = output.split("\n");
		
		for (i in 1...lines.length)
		{
			if (lines[i].startsWith('-D $library='))
				return lines[i - 1].trim();
		}
		
		throw 'Invalid haxelib: "$library"';
	}
	
	public static function getGitSHA(path:String):Null<String>
	{
		final sha = getProcessOutput("git", ["-C", path, "rev-parse", "HEAD"]);
		if (sha == null || false == ~/[a-f0-9]{40}/.match(sha))
			return null;
		
		return sha;
	}
	
	public static function getGitBranch(path:String):Null<String>
	{
		return getProcessOutput("git", ["-C", path, "rev-parse", "--abbrev-ref", "HEAD"]).trim();
	}
	
	
	public static function getGitDefaultBranch(path:String):Null<String>
	{
		return getProcessOutput("git", ["-C", path, "symbolic-ref", "--short", "refs/remotes/origin/HEAD"]).trim();
	}
	
	public static function getProcessOutput(cmd:String, args:Array<String>):Null<String>
	{
		try
		{
			final process = new Process(cmd, args);
			var output = "";
			
			try
			{
				output = process.stdout.readAll().toString();
			}
			catch (_:Dynamic) {}
			
			process.close();
			return output;
		}
		catch (_:Dynamic)
		{
			return null;
		}
	}
	#end
}