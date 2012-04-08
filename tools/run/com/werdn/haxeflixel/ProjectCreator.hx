package com.werdn.haxeflixel;

/**
 * Project manager stub
 * @author Werdn
 */
class ProjectCreator
{
	static function main():Void
	{
		var args:Array<String> = neko.Sys.args();
		
		var last:String = (new neko.io.Path(args[args.length-1])).toString();
		var slash = last.substr(-1);
		if (slash=="/"|| slash=="\\") 
		{
			last = last.substr(0,last.length-1);
		}
		if (neko.FileSystem.exists(last) && neko.FileSystem.isDirectory(last)) 
		{
			neko.Sys.setCwd(last);
		}
		
		neko.Lib.print(args);
	}
}