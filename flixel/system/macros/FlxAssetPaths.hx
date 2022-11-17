package flixel.system.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;

using StringTools;
using flixel.util.FlxArrayUtil;

class FlxAssetPaths
{
	public static function buildFileReferences(directory = "assets/", subDirectories = false, ?include:EReg, ?exclude:EReg,
			?rename:String->Null<String>):Array<Field>
	{
		if (!directory.endsWith("/"))
			directory += "/";

		Context.registerModuleDependency(Context.getLocalModule(), directory);

		var fileReferences = getFileReferences(directory, subDirectories, include, exclude, rename);
		var fields = Context.getBuildFields();

		// create new fields based on file references!
		for (fileRef in fileReferences)
			fields.push(fileRef.createField());
		
		return fields;
	}

	static function getFileReferences(directory:String, subDirectories = false, ?include:EReg, ?exclude:EReg,
			?rename:String->Null<String>):Array<FileReference>
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
					addIfUnique(fileReferences, reference);
			}
			else if (subDirectories)
			{
				fileReferences = fileReferences.concat(getFileReferences(directory + name + "/", true, include, exclude, rename));
			}
		}

		return fileReferences;
	}
	
	static function addIfUnique(fileReferences:Array<FileReference>, file:FileReference)
	{
		for (i in 0...fileReferences.length)
		{
			if (fileReferences[i].name == file.name)
			{
				var oldValue = fileReferences[i].value;
				// if the old file is nested deeper in the folder structure
				if (oldValue.split("/").length > file.value.split("/").length)
				{
					// replace it with the new one
					fileReferences[i] = file;
					Context.warning('Duplicate files named "${file.name}" ignoring $oldValue', Context.currentPos());
				}
				else
				{
					Context.warning('Duplicate files named "${file.name}" ignoring ${file.value}', Context.currentPos());
				}
				return;
			}
		}
		
		fileReferences.push(file);
	}
}

private class FileReference
{
	static var valid = ~/^[_A-Za-z]\w*$/;

	public static function fromPath(value:String, ?library:String, ?rename:String->Null<String>):Null<FileReference>
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
			Context.warning('Invalid name: $name for file: $value', Context.currentPos());
			return null;
		}
		
		if (library != "default" && library != "" && library != null)
			value = '$library:$value';
		
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
	
	public function createField():Field
	{
		return {
			name: name,
			doc: documentation,
			access: [Access.APublic, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:String, macro $v{value}),
			pos: Context.currentPos()
		};
	}
}
