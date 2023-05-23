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

		final fileReferences = getFileReferences(directory, subDirectories, include, exclude);
		
		// determine field names, remove nulls and warn on invalid names
		nameFileReferences(fileReferences, rename);
		
		// create static list of all files
		final allFiles = [];
		for (fileRef in fileReferences)
			allFiles.push(macro $i{fileRef.name});
		
		// warns on any duplicates
		removeDuplicates(fileReferences);
		
		final fields = Context.getBuildFields();
		var listConflictingPath:String = null;
		for (fileRef in fileReferences)
		{
			// create new fields based on file references!
			fields.push(fileRef.createField());
			
			// make sure no fields conflict with the list field name
			if (listField != "" && listConflictingPath == null)
			{
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
	
	/**
	 * Returns all files in a directory that fit the include/exclude criteria.
	 * @param   directory       The folder of assets to build fields for
	 * @param   subDirectories  If true, all subfolders will be included
	 * @param   include         Regular Expression used to allow files based by name
	 * @param   exclude         Regular Expression used to omit files based by name
	 */
	static inline function getFileReferences(directory:String, subDirectories = false, ?include:EReg, ?exclude:EReg):Array<FileReference>
	{
		return addFileReferences([], directory, subDirectories, include, exclude);
	}
	
	/**
	 * Searches for all files in a directory that fit the include/exclude criteria and adds them to
	 * the target array
	 * 
	 * @param   fileReferences  The array to add the references to
	 * @param   directory       The folder of assets to build fields for
	 * @param   subDirectories  If true, all subfolders will be included
	 * @param   include         Regular Expression used to allow files based by name
	 * @param   exclude         Regular Expression used to omit files based by name
	 */
	static function addFileReferences(fileReferences:Array<FileReference>, directory:String, subDirectories = false, ?include:EReg, ?exclude:EReg):Array<FileReference>
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

				fileReferences.push(new FileReference(path));
			}
			else if (subDirectories)
			{
				addFileReferences(fileReferences, directory + name + "/", true, include, exclude);
			}
		}

		return fileReferences;
	}
	
	/**
	 * Creates a name for each file, removes null and warns on invalid names
	 */
	static function nameFileReferences(fileReferences:Array<FileReference>, ?rename:String->Null<String>)
	{
		var i = fileReferences.length;
		while (i-- > 0)
		{
			final fileRef = fileReferences[i];
			
			// create field name
			fileRef.createName(rename);
			
			if (fileRef.name == null)
				// remove if null name
				fileReferences.splice(i, 1);
		}
	}
	
	/**
	 * Searches for, removes and warns of all duplicate field names
	 */
	static function removeDuplicates(fileReferences:Array<FileReference>)
	{
		var ignoredFiles = new Map<String, Array<FileReference>>();
		function addIgnored(file:FileReference)
		{
			if (!ignoredFiles.exists(file.name))
				ignoredFiles[file.name] = [file];
			else
				ignoredFiles[file.name].push(file);
		}
		
		// loop backward so we can delete duplicates
		var i = fileReferences.length;
		while (i-- > 0)
		{
			final file = fileReferences[i];
			var j = fileReferences.length;
			while (j-- > 0)
			{
				final otherFile = fileReferences[j];
				final sameName = i != j && otherFile.name == file.name;
				// ignore the file nested deeper
				if (sameName && otherFile.value.split("/").length <= file.value.split("/").length)
				{
					fileReferences.splice(i, 1);
					addIgnored(file);
					break;
				}
			}
		}
		
		// Show warnings for ignored files, if were not doing unit tests
		#if !FLX_UNIT_TEST
		for (name=>files in ignoredFiles)
		{
			if (files.length == 1)
			{
				final file = files[0];
				file.warn('Duplicate files named "$name" ignoring "${file.value}"');
			}
			else
			{
				Context.warning('Multiple files named "$name"', Context.currentPos());
				for (file in files)
					file.warn('... ignoring "${file.value}"');
			}
		}
		#end
	}
}

private class FileReference
{
	static var valid = ~/^[_A-Za-z]\w*$/;
	
	static function defaultNamer(path:String)
	{
		return path.split("/").pop();
	}

	public var value(default, null):String;
	public var documentation(default, null):String;
	public var name(default, null):String = null;

	public function new(value:String)
	{
		this.value = value;
		this.documentation = "`\"" + value + "\"` (auto generated).";
	}
	
	/**
	 * Creates the name for this field using the supplied method and the path.
	 * @param   namer  Function that takes a path and returns a haxe field name.
	 */
	public function createName(?namer:(String)->Null<String>)
	{
		if (namer == null)
			namer = defaultNamer;
		
		name = namer(value);
		if (name == null)
			return;
		
		validateName();
	}
	
	/**
	 * Replaces hyphens, spaces and periods, and warns if the resulting name is not a valid haxe identifier.
	 */
	public function validateName()
	{
		// replace some forbidden names to underscores, since variables cannot have these symbols.
		name = name.split("-").join("_").split(" ").join("_").split(".").join("__");
		
		// warn if the name is invalid
		if (!valid.match(name)) // #1796
		{
			warnAsset('Invalid name: $name for file: $value', value);
			name = null;
		}
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
