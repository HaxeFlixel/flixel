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

		if(args.length < 2 || cmd.help)
		{
			neko.Lib.println("Flixel project template creation tool.\n");
			neko.Lib.println("haxelib run flixel [help] [-name \"Your Project Name\"] [-class MainProjectClass] [-screen WIDTH HEIGHT]\n");
			neko.Lib.println("\thelp - this screen");
			neko.Lib.println("\t-name \"Your Project Name\"");
			neko.Lib.println("\t-class MainProjectClass");
			neko.Lib.println("\t-screen WIDTH HEIGHT");
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

			if(StringTools.endsWith(fileName, "\\") || StringTools.endsWith(fileName, "/"))
			{
				fileName = fileName.substr(0, -1);
				neko.Lib.println("Directory: " + fileName);
				if(!neko.FileSystem.exists(cmd.projectDir + "/" +fileName))
				{
					neko.FileSystem.createDirectory(cmd.projectDir + "/" +fileName);
				}
			}
			else
			{
				var bytes:Bytes = Reader.unzip(entry);
				if(StringTools.endsWith(fileName, ".tpl"))
				{
					//TODO make some template magic
					var text:String = new haxe.io.BytesInput(bytes).readString(bytes.length);
					
					text = replaceAll(text, cmd);
					
					bytes = Bytes.ofString(text);
					
					fileName = replaceAll(fileName.substr(0, -4), cmd);
				}

				neko.Lib.println("File output: " + fileName);

				var fout:FileOutput = File.write(cmd.projectDir + "/" + fileName, true);
				fout.writeBytes(bytes, 0, bytes.length);
				fout.close();
			}				
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