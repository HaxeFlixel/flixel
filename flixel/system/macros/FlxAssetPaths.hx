package flixel.system.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;

using flixel.util.FlxArrayUtil;
using StringTools;

class FlxAssetPaths
{
	public static function buildFileReferences(directory:String = "assets/", subDirectories:Bool = false, ?filterExtensions:Array<String>,
			?rename:String->String):Array<Field>
	{
		if (!directory.endsWith("/"))
			directory += "/";

		Context.registerModuleDependency(Context.getLocalModule(), directory);

		var fileReferences:Array<FileReference> = getFileReferences(directory, subDirectories, filterExtensions, rename);
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

	static function getFileReferences(directory:String, subDirectories:Bool = false, ?filterExtensions:Array<String>,
			?rename:String->String):Array<FileReference>
	{
		var fileReferences:Array<FileReference> = [];
		var resolvedPath = #if (ios || tvos) "../assets/" + directory #else directory #end;
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
					var extension:String = name.split(".").last(); // get the last string with a dot before it
					if (!filterExtensions.contains(extension))
						continue;
				}

				var reference = FileReference.fromPath(directory + name, rename);
				if (reference != null)
					fileReferences.push(reference);
			}
			else if (subDirectories)
			{
				fileReferences = fileReferences.concat(getFileReferences(directory + name + "/", true, filterExtensions, rename));
			}
		}

		return fileReferences;
	}
}

private class FileReference
{
	private static var validIdentifierPattern = ~/^[_A-Za-z]\w*$/;

	public static function fromPath(value:String, ?rename:String->String):Null<FileReference>
	{
		// replace some forbidden names to underscores, since variables cannot have these symbols.
		var name = value.split("/").last();

		if (rename != null)
		{
			name = rename(name);
		}

		name = name.split("-").join("_").split(".").join("__");
		if (!validIdentifierPattern.match(name)) // #1796
			return null;
		return new FileReference(name, value);
	}

	public var name(default, null):String;
	public var value(default, null):String;
	public var documentation(default, null):String;

	function new(name:String, value:String)
	{
		this.name = name;
		this.value = value;
		this.documentation = "`\"" + value + "\"` (auto generated).";
	}
}
