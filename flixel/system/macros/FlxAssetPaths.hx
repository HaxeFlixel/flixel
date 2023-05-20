package flixel.system.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
using StringTools;
using flixel.util.FlxArrayUtil;

/**
 * This class is used internally by `flixel.system.macros.FlxAssets`
 * @see `flixel.system.macros.FlxAssets`
 */
class FlxAssetPaths
{
	/**
	 * Searches through the specified directory and adds a static public field for every file found.
	 * 
	 * @param   directory       The folder of assets to build fields for
	 * @param   subDirectories  If true, all subfolders will be included
	 * @param   include         Regular Expression used to allow files based by name
	 * @param   exclude         Regular Expression used to omit files based by name
	 * @param   rename          A function that takes a filepath and returns a field name
	 * @param   listField       If not an empty string, it adds static public field with the given
	 *                          name with an array of every file in the directory
	 * @return  The fields are added to the class using this build macro
	 */
	public static function buildFileReferences(directory = "assets/", subDirectories = false, ?include:EReg, ?exclude:EReg,
			?rename:String->Null<String>, listField = "allFiles"):Array<Field>
	{
		if (!directory.endsWith("/"))
			directory += "/";

		Context.registerModuleDependency(Context.getLocalModule(), directory);

		final fileReferences = addFileReferences([], directory, subDirectories, include, exclude, rename);
		final fields = Context.getBuildFields();
		final allFiles = [];
		var listConflictingPath:String = null;

		// create new fields based on file references!
		for (fileRef in fileReferences)
		{
			fields.push(fileRef.createField());
			if (listField != "" && listConflictingPath == null)
			{
				allFiles.push(macro $i{fileRef.name});
				if (fileRef.name == listField)
					listConflictingPath = fileRef.value;
			}
		}
		
		if (listField != "")
		{
			if (listConflictingPath != null)
			{
				Context.warning('Could not add field "$listField" due to conflicting file "$listConflictingPath"', Context.currentPos());
			}
			else
			{
				// add an array with every file
				fields.push({
					name: listField,
					doc: 'A list of every file in "$directory"',
					access: [Access.APublic, Access.AStatic],
					kind: FieldType.FVar(macro:Array<String>, macro $a{allFiles}),
					pos: Context.currentPos()
				});
			}
		}
		
		return fields;
	}

	static function addFileReferences(fileReferences:Array<FileReference>, directory:String, subDirectories = false, ?include:EReg, ?exclude:EReg,
			?rename:String->Null<String>):Array<FileReference>
	{
		var resolvedPath = #if (ios || tvos) "../assets/" + directory #else directory #end;
		var directoryInfo = FileSystem.readDirectory(resolvedPath);
		for (name in directoryInfo)
		{
			var path = resolvedPath + name;

			if (!FileSystem.isDirectory(path))
			{
				// ignore invisible files
				if (name.startsWith("."))
					continue;

				if (include != null && !include.match(path))
					continue;

				if (exclude != null && exclude.match(path))
					continue;

				var reference = FileReference.fromPath(path, rename);
				if (reference != null)
					addIfUnique(fileReferences, reference);
			}
			else if (subDirectories)
			{
				addFileReferences(fileReferences, directory + name + "/", true, include, exclude, rename);
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
					file.warn('Duplicate files named "${file.name}" ignoring $oldValue');
				}
				else
				{
					file.warn('Duplicate files named "${file.name}" ignoring ${file.value}');
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
		name = name.split("-").join("_").split(" ").join("_").split(".").join("__");
		if (!valid.match(name)) // #1796
		{
			warnAsset('Invalid name: $name for file: $value', value);
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
	
	public inline function warn(msg:String)
	{
		warnAsset(msg, value);
	}
	
	public static inline function warnAsset(msg:String, filePath:String)
	{
		Context.warning(msg, Context.makePosition({min: 0, max: 0, file: filePath}));
	}
}
