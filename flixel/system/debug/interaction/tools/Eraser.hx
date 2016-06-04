package flixel.system.debug.interaction.tools;

import flash.display.BitmapData;
import flash.ui.Keyboard;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.system.debug.interaction.Interaction;

@:bitmap("assets/images/debugger/buttons/eraser.png") 
class GraphicEraserTool extends BitmapData { }

/**
 * A tool to delete items from the screen.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Eraser extends Tool
{			
	override public function init(Brain:Interaction):Tool 
	{
		super.init(Brain);
		setButton(GraphicEraserTool);
		return this;
	}
	
	override public function update():Void 
	{
		var brain:Interaction = getBrain();
		
		super.update();
		
		if (brain.keyJustPressed(Keyboard.DELETE))
		{
			doDeletion(brain.keyPressed(Keyboard.SHIFT));
		}
	}
	
	override public function activate():Void 
	{
		super.activate();
		doDeletion(getBrain().keyPressed(Keyboard.SHIFT));
		
		// No need to stay active
		deactivate();
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
