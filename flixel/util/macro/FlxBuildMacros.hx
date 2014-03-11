package flixel.util.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
using StringTools;

class FlxBuildMacros
{
	/**
	 * Reads files from a directory relative to this project and generates public static inlined
	 * variables containing the string paths to the files in it. 
	 * 
	 * Example usage:
	 * @:build(flixel.util.macro.FlxBuildMacros.buildFileReferences("assets/images"))
	 * class Images {}
	 * 
	 * Mostly copied from:
	 * @author Mark Knol
	 * @see http://blog.stroep.nl/2014/01/haxe-macros/
	 * 
	 * @param   directory          The directory to scan for files
	 * @param   subDirectories     Whether to include subdirectories
	 * @param   filterExtensions   Example: [jpg, png, gif] will only add files with that extension. Null means: all extensions
	 */
	macro public static function buildFileReferences(directory:String = "assets/", subDirectories:Bool = false, ?filterExtensions:Array<String>):Array<Field>
	{
		if (!directory.endsWith("/"))
			directory += "/";
		
		var fileReferences:Array<FileReference> = getFileReferences(directory, subDirectories, filterExtensions);
		
		var fields:Array<Field> = Context.getBuildFields();
		for (fileRef in fileReferences)
		{
			// create new field based on file references!
			fields.push({
				name: fileRef.name,
				doc: fileRef.documentation,
				access: [Access.APublic, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:String, macro $v{fileRef.value}),
				pos: Context.currentPos()
			});
		}
		return fields;
	}
	
	private static function getFileReferences(directory:String, subDirectories:Bool = false, ?filterExtensions:Array<String>):Array<FileReference>
	{
		var fileReferences:Array<FileReference> = [];
		var directoryInfo = FileSystem.readDirectory(directory);
		for (name in directoryInfo)
		{
			if (!FileSystem.isDirectory(directory + name))
			{
				if (filterExtensions != null)
				{
					var extension:String = name.split(".")[1]; // get the string after the dot
					if (filterExtensions.indexOf(extension) == -1)
						break;
				}
				
				fileReferences.push(new FileReference(directory + name));
			}
			else if (subDirectories)
			{
				fileReferences = fileReferences.concat(getFileReferences(directory + name + "/", true, filterExtensions));
			}
		}
		return fileReferences;
	}
}

private class FileReference
{
    public var name:String;
    public var value:String;
    public var documentation:String;
    
    public function new(value:String)
    {
        this.value = value;
        
        // replace some forbidden names to underscores, since variables cannot have these symbols.
        this.name = value.split("-").join("_").split(".").join("__");
		var split:Array<String> = name.split("/");
		this.name = split[split.length - 1];
        
        // auto generate documentation
        this.documentation = "\"" + value + "\" (auto generated).";
    }
}