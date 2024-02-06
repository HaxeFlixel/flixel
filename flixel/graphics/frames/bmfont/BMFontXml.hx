package flixel.graphics.frames.bmfont;

import flixel.FlxG;
import flixel.system.debug.log.LogStyle;

/**
 * Helps providing a fast dot-syntax access to the most common `Xml` methods.
 * Copied from `haxe.xml.Access` but replaces error throws with warnings and errors `FlxG.log`
**/
abstract BMFontXml(Xml) from Xml
{
	public var xml(get, never):Xml;
	
	inline function get_xml()
	{
		return this;
	}
	
	/** The name of the current element. This is the same as `Xml.nodeName`. **/
	public var name(get, never):String;
	
	inline function get_name()
	{
		return if (this.nodeType == Xml.Document) "Document" else this.nodeName;
	}
	
	/** Access to the first sub element with the given name. */
	public var node(get, never):NodeAccess;
	
	inline function get_node():NodeAccess
	{
		return xml;
	}
	
	/** Access to a given attribute. **/
	public var att(get, never):AttribAccess;
	
	inline function get_att():AttribAccess
	{
		return this;
	}
	
	/** The list of all sub-elements which are the nodes with type `Xml.Element`. **/
	public var elements(get, never):Iterator<BMFontXml>;
	
	inline function get_elements():Iterator<BMFontXml>
	{
		return cast this.elements();
	}
	
	public inline function new(xml:Xml)
	{
		if (xml.nodeType != Xml.Document && xml.nodeType != Xml.Element)
			throw 'Invalid nodeType ${xml.nodeType}';
		
		this = xml;
	}
	
	/** Check the existence of an attribute with the given name. **/
	public function has(name:String):Bool
	{
		if (this.nodeType == Xml.Document)
			throw 'Cannot access document attribute $name';
		
		return this.nodeType == Xml.Document && this.exists(name);
	}
	
	/** Check the existence of a sub node with the given name. **/
	public function hasNode(name:String):Bool
	{
		return this.elementsNamed(name).hasNext();
	}
	
	/** Access to the List of elements with the given name. */
	public function nodes(name:String):Array<BMFontXml>
	{
		return [
			for (xml in this.elementsNamed(name))
				new BMFontXml(xml)
		];
	}
}

private abstract NodeAccess(Xml) from Xml to Xml
{
	inline function getHelper(name:String, ?invalid:(String)->Void):BMFontXml
	{
		final xml = this.elementsNamed(name).next();
		if (xml == null)
		{
			final xname = if (this.nodeType == Xml.Document) "Document" else this.nodeName;
			
			invalid('$xname is missing element $name');
		}
		return xml;
	}
	
	public function getSafe(name:String):BMFontXml
	{
		return getHelper(name);
	}
	
	public function get(name:String):BMFontXml
	{
		return getHelper(name, (msg)->throw msg);
	}
	
	public function getWarn(name:String)
	{
		return getHelper(name, FlxG.log.warn);
	}
	
	public function getError(name:String)
	{
		return getHelper(name, FlxG.log.error);
	}
}

private abstract AttribAccess(Xml) from Xml to Xml
{
	inline function stringHelper(name:String, ?invalid:(String)->Void, ?backup:String):String
	{
		var value = backup;
		if (this.nodeType == Xml.Document)
		{
			if (invalid != null)
				invalid('Cannot access document attribute $name');
		}
		else
		{
			final v = this.get(name);
			if (v != null)
				value = v;
			else if (invalid != null)
				invalid('${this.nodeName} is missing attribute $name');
		}
		return value;
	}
	
	public function stringSafe(name:String, ?backup:String)
	{
		return stringHelper(name, null, backup);
	}
	
	public function string(name:String)
	{
		return stringHelper(name, (msg)->throw msg);
	}
	
	public function stringWarn(name:String, ?backup:String)
	{
		return stringHelper(name, FlxG.log.warn, backup);
	}
	
	public function stringError(name:String, ?backup:String)
	{
		return stringHelper(name, FlxG.log.error, backup);
	}
	
	inline function intHelper(name:String, ?invalid:(String)->Void, backup:Int):Int
	{
		var value = backup;
		if (this.nodeType == Xml.Document)
		{
			if (invalid != null)
				invalid('Cannot access document attribute $name');
		}
		else
		{
			final v = this.get(name);
			if (v != null)
				value = Std.parseInt(v);
			else if (invalid != null)
				invalid('${this.nodeName} is missing attribute $name');
		}
		return value;
	}
	
	public function intSafe(name:String, backup:Int)
	{
		return intHelper(name, null, backup);
	}
	
	public function int(name:String)
	{
		return intHelper(name, (msg)->throw msg, 0);
	}
	
	public function intWarn(name:String, backup:Int)
	{
		return intHelper(name, FlxG.log.warn, backup);
	}
	
	public function intError(name:String, backup:Int)
	{
		return intHelper(name, FlxG.log.error, backup);
	}
	
	inline function boolHelper(name:String, ?invalid:(String)->Void, backup:Bool):Bool
	{
		var value = backup;
		if (this.nodeType == Xml.Document)
		{
			if (invalid != null)
				invalid('Cannot access document attribute $name');
		}
		else
		{
			final v = this.get(name);
			if (v != null)
				value = v != "0";
			else if (invalid != null)
				invalid('${this.nodeName} is missing attribute $name');
		}
		return value;
	}
	
	public function boolSafe(name:String, backup:Bool)
	{
		return boolHelper(name, null, backup);
	}
	
	public function bool(name:String)
	{
		return boolHelper(name, (msg)->throw msg, false);
	}
	
	public function boolWarn(name:String, backup:Bool)
	{
		return boolHelper(name, FlxG.log.warn, backup);
	}
	
	public function boolError(name:String, backup:Bool)
	{
		return boolHelper(name, FlxG.log.error, backup);
	}
}