package flixel.system.debug.interaction.tools;

import flash.display.*;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxGroup;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.system.debug.interaction;

/**
 * A tool to delete items from the screen.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Eraser extends Tool
{		
	public function new()
	{
	}
	
	override public function update():Void 
	{
		super.update();
		
		if (FlxG.keys.justPressed("DELETE"))
		{
			doDeletion(FlxG.keys.pressed("SHIFT"));
		}
	}
	
	override public function activate():Void 
	{
		super.activate();
		doDeletion(false);
	}
	
	private function doDeletion(RemoveFromMemory:Boolean):Void
	{
		var selectedItems :FlxGroup = findSelectedItemsByPointer();
		
		if (selectedItems != null)
		{
			findAndDelete(selectedItems, RemoveFromMemory);
			selectedItems.clear();
		}
	}
	
	private function findAndDelete(Items:FlxGroup, RemoveFromMemory:Boolean = false):Void
	{
		var i:Int = 0;
		var members:Array = Items.members;
		var l:Int = members.length;
		var item:FlxBasic;
		
		while (i < l)
		{
			item = members[i++];
			
			if (item != null)
			{
				if (item is FlxGroup)
				{
					// TODO: walk in the group, removing all members.
				}
				else
				{
					item.kill();
					
					if (RemoveFromMemory)
					{
						removeFromMemory(item, FlxG.state);
					}
				}
			}
		}
	}
	
	private function removeFromMemory(Item:FlxBasic, ParentGroup:FlxGroup):Void
	{
		var i:uint = 0;
		var members:Array = ParentGroup.members;
		var l:uint = members.length;
		var b:FlxBasic;
		
		while (i < l)
		{
			b = members[i++];

			if (b != null)
			{
				if (b is FlxGroup)
				{
					removeFromMemory(Item, b as FlxGroup);
				}
				else if(b == Item)
				{
					ParentGroup.remove(b);
					FlxG.log("InteractiveDebug: deleted " + Item);
				}
			}
		}
	}
	
	private function pinpointItemInGroup(Members:Array,Cursor:FlxPoint):FlxBasic
	{
		var i:uint = 0;
		var l:uint = Members.length;
		var b:FlxBasic;
		var target:FlxBasic;
		
		while (i < l)
		{
			b = Members[i++];

			if (b != null)
			{
				if (b is FlxGroup)
				{
					target = pinpointItemInGroup((b as FlxGroup).members, Cursor);
				}
				else if((b is FlxSprite) && (b as FlxSprite).overlapsPoint(Cursor, true))
				{
					target = b;
				}
				if (target != null)
				{
					break;
				}
			}
		}
		
		return target;
	}
	
	private function findSelectedItemsByPointer():FlxGroup
	{
		var tool:Pointer = brain.getTool(Pointer) as Pointer;
		return tool != null ? tool.selectedItems : null;
	}
}
