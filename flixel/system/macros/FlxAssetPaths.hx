package flixel.system.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
using flixel.util.FlxArrayUtil;
using StringTools;

class FlxAssetPaths 
{
	public static function buildFileReferences(directory:String = "assets/", subDirectories:Bool = false, ?filterExtensions:Array<String>):Array<Field>
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
				kind: FieldType.FVar(macro:String, macro $v{ fileRef.value }),
				pos: Context.currentPos()
			});
		}
		return fields;
	}
	
	private static function getFileReferences(directory:String, subDirectories:Bool = false, ?filterExtensions:Array<String>):Array<FileReference>
	{
		var fileReferences:Array<FileReference> = [];
		var resolvedPath = #if (ios || tvos) Context.resolvePath(directory) #else directory #end;
		var directoryInfo = FileSystem.readDirectory(resolvedPath);
		for (name in directoryInfo)
		{
			if (!FileSystem.isDirectory(resolvedPath + name))
			{
				// ignore invisible files
				if (name.startsWith("."))
					continue;
				
				if (filterExtensions != null)
				{
					var explodedName:Array<String> = name.split(".");
					var extension:String = explodedName[explodedName.length-1]; // get the last string with a dot before it
					if (filterExtensions.indexOf(extension) == -1)
						continue;
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
		this.name = split.last();
		
		// auto generate documentation
		this.documentation = "\"" + value + "\" (auto generated).";
	}
}
#end
