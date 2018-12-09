import flixel.addons.ui.FlxUI;
import flixel.addons.ui.interfaces.IEventGetter;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.U;
import flixel.FlxG;

#if haxe4
import haxe.xml.Access;
#else
import haxe.xml.Fast as Access;
#end

/**
 * ...
 * @author Lars Doucet
 */
class SaveSlot extends FlxUI
{
	var ptr:IEventGetter;
	public var valid:Bool;
	
	public function new(data:Access, ?_ptr:Dynamic)
	{
		super(null, _ptr);
		if (_ptr != null)
		{
			if (Std.is(_ptr, FlxUI))
			{
				var ui:FlxUI = cast _ptr;
				_ptr_tongue = ui.tongue;
			}
		}
		loadStuff(data, _ptr);
		valid = true;
		FlxG.log.add("SaveSlot(" + name + "" + _ptr + ")");

		init();
	}

	public function loadStuff(data:Access, _ptr:Dynamic):Void
	{
		load(data);
		name = U.xml_name(data.x);
	}
	
	public override function getEvent(event:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		super.getEvent(event, sender, data);
		if (Std.is(data, String))
		{
			var str:String = cast(data, String);
			switch (str) 
			{
				case "play": onPress();
				case "play+": onPlus();
				case "export": onExport();
				case "import": onImport();
				case "delete": onDel();
			}
		}
	}
	
	function init():Void
	{
	}

	function onPlus():Void
	{
		FlxG.log.add("press plus " + name);
	}

	function onPress():Void
	{
		FlxG.log.add("press " + name);
	}

	function cleanSlot():Void
	{
		valid = false;
	}

	function onExport():Void
	{
	}

	function onImport():Void
	{
	}

	function onDel():Void
	{
	}
}