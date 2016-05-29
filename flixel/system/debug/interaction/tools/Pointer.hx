package flixel.system.debug.interaction.tools;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.system.debug.interaction.Interaction;
import flixel.system.debug.interaction.tools.Tool;

@:bitmap("assets/images/debugger/buttons/console.png") 
class GraphicInteractiveCursor extends BitmapData {} // TODO: replace with proper cursor art

/**
 * A tool to use the mouse cursor to select game elements.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Pointer extends Tool
{		
	private var _customCursor:Bitmap;
	private var _mouse:FlxPoint;
	
	override public function init(Brain:Interaction):Tool 
	{
		super.init(Brain);
		
		_mouse = new FlxPoint();
		
		_customCursor = new Bitmap(new GraphicInteractiveCursor(0, 0));
		Brain.getContainer().addChild(_customCursor);
		
		FlxG.stage.addEventListener(MouseEvent.MOUSE_MOVE, updateMouse);
		
		return this;
	}
	
	public function updateMouse(Event:MouseEvent):Void
	{
		// Store Flixel mouse coordinates to speed up all
		// internal calculations (overlap, etc)
		_mouse.x = FlxG.mouse.x;
		_mouse.y = FlxG.mouse.y;
		
		// Position the custom interaction mouse cursor
		_customCursor.x = Event.stageX;
		_customCursor.y = Event.stageY;
	}
	
	override public function update():Void 
	{
		var item :FlxBasic;
		
		super.update();
		
		if ((FlxG.mouse.justReleased || FlxG.mouse.justPressed) && isActive())
		{
			item = pinpointItemInGroup(FlxG.state.members, _mouse);
			
			if (item != null)
			{
				handleItemClick(item);
			}
			else if(FlxG.mouse.justPressed)
			{
				// User clicked an empty space, so it's time to unselect everything.
				getBrain().clearSelection();
			}
		}
	}
	
	private function handleItemClick(Item:FlxBasic):Void
	{			
		var selectedItems:FlxGroup = getBrain().getSelectedItems();
		
		// Is it the first thing selected or are we adding things using Ctrl?
		if(selectedItems.length == 0 || FlxG.keys.pressed.CONTROL)
		{
			// Yeah, that's the case. Just add the new thing to the selection.
			selectedItems.add(Item);
		}
		else
		{
			// There is something already selected
			if (selectedItems.members.indexOf(Item) == -1)
			{
				getBrain().clearSelection();
			}
			selectedItems.add(Item);
		}
	}
	
	private function pinpointItemInGroup(Members:Array<FlxBasic>,Cursor:FlxPoint):FlxBasic
	{
		var i:Int = 0;
		var l:Int = Members.length;
		var b:FlxBasic;
		var target:FlxBasic = null;
		
		while (i < l)
		{
			b = Members[i++];

			if (b != null)
			{
				if (Std.is(b, FlxGroup))
				{
					target = pinpointItemInGroup((cast b).members, Cursor);
				}
				else if(Std.is(b, FlxSprite) && (cast b).overlapsPoint(Cursor, true))
				{
					target = b;
				}
				if (target != null)
				{
					break;
				}
			}
		}
		FlxG.log.add("Pinpointed: " + target);
		return target;
	}
}
