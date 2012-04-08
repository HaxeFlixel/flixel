package com.werdn.haxeflixel;

import haxe.io.Bytes;
import neko.io.File;
import neko.io.FileOutput;
import neko.zip.Reader;

class CommandLine
{
	public var projectDir:String;
	public var projectName:String;
	public var projectClass:String;
	public var width:Int;
	public var height:Int;
	public var help:Bool;

	public function new()
	{
 		projectDir = null;
 		projectName = "Project Name";
 		projectClass = "ProjectClass";
 		width = 640;
 		height = 480;
 		help = false;
	}
}

/**
 * Project manager stub
 * @author Werdn
 * based on https://github.com/MattTuttle/HaxePunk/blob/master/tools/SetupTool.hx
 */
class ProjectCreator
{
	static function main():Void
	{
		new ProjectCreator();
	}

	public function new()
	{
		var args:Array<String> = neko.Sys.args();
		
		var cmd = parseCommandLine(args);

		// neko.Lib.println(neko.Sys.getCwd());		
		// neko.Lib.println(args);
		// neko.Lib.println(cmd.projectDir);
		// neko.Lib.println(cmd.projectName);

		if(args.length < 1)
		{
			neko.Lib.println("Error in command line, try to use help:\n\nhaxelib run HaxeFlixel help");
		}
		else if(cmd.help)
		{
			neko.Lib.println("haxeFlixel project template creation tool.");
			neko.Lib.println("haxelib run HaxeFlixel [help] [-name \"Your Project Name\"] [-class MainProjectClass] [-screen WIDTH HEIGHT]");
		}
		else
		{
			createProject(cmd);
		}
	}

	private function parseCommandLine(args:Array<String>):CommandLine
	{
    	var result = new CommandLine();

		var length = args.length;
		result.projectDir = trimPath(args[length - 1]);
		
		var index = 0;
    	while (index < length - 1)
    	{
    		if(args[index] == "help")
    		{
    			result.help = true;
    			break;
    		}
    		else if(args[index] == "-name" && index + 1 < length)
    		{
    			index++;
    			result.projectName = args[index];
    		}
    		else if(args[index] == "-class" && index + 1 < length)
    		{
    			index++;
    			result.projectClass = args[index];
    		}
    		else if (args[index] == "-screen" && index + 2 < length)
    		{
    			index++;
    			result.width = cast(args[index]);
    			index++;
    			result.height = cast(args[index]);
    		}
    		index++;
    	}

    	return result;
	}

	/**
	 * Extract path
	 */
	private function trimPath(path:String) 
	{
		return new neko.io.Path(path).dir;
	}

	/**
	 * Create new project from template
	 * @author Werdn
	 */
	private function createProject(cmd:CommandLine):Void
	{
		var fileInput = File.read("template.zip", true);
		var data:List<ZipEntry> = Reader.readZip(fileInput);
		fileInput.close();

		for(entry in data)
		{
			var fileName = entry.fileName;
			
			var bytes:Bytes = Reader.unzip(entry);

			if(StringTools.endsWith(fileName, ".tpl"))
			{
				//TODO make some template magic
				var text:String = new haxe.io.BytesInput(bytes).readString(bytes.length);
				
				text = replaceAll(text, cmd);
				
				bytes = Bytes.ofString(text);
				
				fileName = replaceAll(fileName.substr(0, -4), cmd);

				neko.Lib.println(text);

				neko.Lib.print("Template ");
			}

			neko.Lib.println("File output: " + fileName);
				
			//var fout:FileOutput = File.write(path + "/" + fileName, true);
			//fout.writeBytes(bytes, 0, bytes.length);
			//fout.close();
		}
	}

	function replaceAll(source:String, cmd:CommandLine):String
	{
		source = StringTools.replace(source, "${PROJECT_NAME}", cmd.projectName);
		source = StringTools.replace(source, "${PROJECT_CLASS}", cmd.projectClass);
		source = StringTools.replace(source, "${WIDTH}", cast(cmd.width));
		source = StringTools.replace(source, "${HEIGHT}", cast(cmd.height));
		return source;
	}
}