package flixel.system.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.PosInfos;
import sys.FileSystem;

using StringTools;
using flixel.util.FlxArrayUtil;

class FlxAssetPaths
{
	public static function buildFileReferences(directory = "assets/", subDirectories = false, ?include:EReg, ?exclude:EReg,
			?rename:String->String):Array<Field>
	{
		if (!directory.endsWith("/"))
			directory += "/";

		Context.registerModuleDependency(Context.getLocalModule(), directory);

		var fileReferences = getFileReferences(directory, subDirectories, include, exclude, rename);
		var fields = Context.getBuildFields();

		var addedFields = new Array<String>();

		for (fileRef in fileReferences)
		{
			if (addedFields.contains(fileRef.name))
			{
				warn('Duplicate files named "${fileRef.name}" ignoring ${fileRef.value}');
			}
			else
			{
				addedFields.push(fileRef.name);
				// create new field based on file references!
				fields.push({
					name: fileRef.name,
					doc: fileRef.documentation,
					access: [Access.APublic, Access.AStatic, Access.AInline],
					kind: FieldType.FVar(macro:String, macro $v{fileRef.value}),
					pos: Context.currentPos()
				});
			}
		}
		return fields;
	}

	static function getFileReferences(directory:String, subDirectories = false, ?include:EReg, ?exclude:EReg,
			?rename:String->String):Array<FileReference>
	{
		var fileReferences:Array<FileReference> = [];
		var resolvedPath = #if (ios || tvos) "../assets/" + directory #else directory #end;
		var directoryInfo = FileSystem.readDirectory(resolvedPath);
		for (name in directoryInfo)
		{
			var path = resolvedPath + name;

			if (include != null && !include.match(path))
				continue;

			if (exclude != null && exclude.match(path))
				continue;

			if (!FileSystem.isDirectory(path))
			{
				// ignore invisible files
				if (name.startsWith("."))
					continue;

				var reference = FileReference.fromPath(path, rename);
				if (reference != null)
					fileReferences.push(reference);
			}
			else if (subDirectories)
			{
				fileReferences = fileReferences.concat(getFileReferences(directory + name + "/", true, include, exclude, rename));
			}
		}

		return fileReferences;
	}

	static inline function warn(msg:String, ?info:PosInfos)
	{
		haxe.Log.trace("[Warning] " + msg, info);
	}
}

private class FileReference
{
	static var valid = ~/^[_A-Za-z]\w*$/;

	public static function fromPath(value:String, ?rename:String->String):Null<FileReference>
	{
		var name = value;

		if (rename != null)
		{
			name = rename(name);
			// exclude null
			if (name == null)
				return null;
		}
		else
			name = value.split("/").pop();

		// replace some forbidden names to underscores, since variables cannot have these symbols.
		name = name.split("-").join("_").split(".").join("__");
		if (!valid.match(name)) // #1796
		{
			trace('[Warning] Invalid name: $name for file: $value');
			return null;
		}

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
