package flixel.system.macros;

#if macro
import haxe.io.BytesOutput;
import haxe.io.Eof;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.io.Process;
using StringTools;

/**
 * Heavily inspired by HaxePunk's HaxeLibInfo.hx
 */ 
class FlxGitSHA
{
	public static function buildGitSHA(library:String):Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields();
		var libraryPath:String;
		var sha:String = "";
		
		// make sure the build isn't cancelled if a Sys call fails
		try
		{
			libraryPath = getLibraryPath(library);
			sha = getGitSHA(libraryPath);
		}
		catch (_:Dynamic) {}
		
		fields.push({
			name: "sha",
			doc: null,
			meta: [],
			access: [Access.APublic, Access.AStatic],
			kind: FieldType.FProp("default", "null", macro:Dynamic, macro $v{sha}),
			pos: Context.currentPos()
		});
		
		return fields;
	}
	
	public static function getLibraryPath(library:String):String
	{
		var output = getProcessOutput("haxelib", ["path", library]);
		
		var result = "";
		var lines = output.split("\n");
		
		for (i in 1...lines.length)
		{
			if (lines[i].startsWith('-D $library'))
			{
				result = lines[i - 1].trim(); 
			}
		}
		
		return result;
	}
	
	public static function getGitSHA(path:String):String
	{
		var oldWd = Sys.getCwd();
		
		Sys.setCwd(path);
		var sha = getProcessOutput("git", ["rev-parse", "HEAD"]);
		var shaRegex = ~/[a-f0-9]{40}/g;
		if (!shaRegex.match(sha))
			sha = "";
		
		Sys.setCwd(oldWd);
		return sha;
	}
	
	public static function getProcessOutput(cmd:String, args:Array<String>):String
	{
		return new Process(cmd, args).stdout.readAll().toString();
	}
}
#end