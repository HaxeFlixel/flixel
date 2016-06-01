package flixel.system.debug.interaction.tools;

import flash.display.*;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;

/**
 * A tool to delete items from the screen.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Eraser extends Tool
{			
	override public function update():Void 
	{
		super.update();
		
		if (FlxG.keys.justPressed.DELETE)
		{
			doDeletion(FlxG.keys.pressed.SHIFT);
		}
	}
	
	override public function activate():Void 
	{
		super.activate();
		doDeletion(false);
	}
	
	private function doDeletion(RemoveFromMemory:Bool):Void
	{
		var selectedItems :FlxGroup = getBrain().getSelectedItems();
		
		if (selectedItems != null)
		{
			findAndDelete(selectedItems, RemoveFromMemory);
			selectedItems.clear();
		}
	}
	
	private function findAndDelete(Items:FlxGroup, RemoveFromMemory:Bool = false):Void
	{
		var i:Int = 0;
		var members:Array<FlxBasic> = Items.members;
		var total:Int = members.length;
		var item:FlxBasic;
		
		while (i < total)
		{
			item = members[i++];
			
			if (item != null)
			{
				if (Std.is(item, FlxGroup))
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
		var i:Int = 0;
		var members:Array<FlxBasic> = ParentGroup.members;
		var total:Int = members.length;
		var b:FlxBasic;
		
		while (i < total)
		{
			b = members[i++];

			if (b != null)
			{
				if (Std.is(b, FlxGroup))
				{
					removeFromMemory(Item, cast b);
				}
				else if(b == Item)
				{
					ParentGroup.remove(b);
				}
			}
		}
	}
}
