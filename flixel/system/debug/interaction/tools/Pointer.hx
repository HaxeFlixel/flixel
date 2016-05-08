package flixel.system.debug.interaction.tools;

import flash.display.*;
import flixel.*;
import flixel.tile.*;
import flixel.ui.*;
import flixel.util.*;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.system.debug.interaction.Interaction;

/**
 * A tool to use the mouse cursor to select game elements.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Pointer extends Tool
{		
	private var _mouse:FlxPoint;
	private var _selectedItems:FlxGroup;
	private var _label:FlxText;
	
	public function new()
	{	
		super();
		_mouse = new FlxPoint();
		_selectedItems = new FlxGroup();
		_label = new FlxText(0, 0, 200);
		_label.color = 0xffff0000;
		_label.scrollFactor.x = 0;
		_label.scrollFactor.y = 0;
	}
	
	override public function update():Void 
	{
		var item :FlxBasic;
		
		super.update();
		
		if ((FlxG.mouse.justReleased || FlxG.mouse.justPressed) && isActive())
		{
			_mouse.x = FlxG.mouse.x;
			_mouse.y = FlxG.mouse.y;
			
			item = pinpointItemInGroup(FlxG.state.members, _mouse);
			
			if (item != null)
			{
				handleItemClick(item);
			}
			else if(FlxG.mouse.justPressed)
			{
				// User clicked an empty space, so it's time to unselect everything.
				clearSelection();
			}
		}
	}
	
	override public function draw():Void 
	{
		var i:Int = 0;
		var l:Int = _selectedItems.members.length;
		var item:FlxObject;
		
		//Set up our global flash graphics object to draw out the debug stuff
		var gfx:Graphics = FlxSpriteUtil.flashGfx;
		gfx.clear();

		super.draw();
		
		while (i < l)
		{
			item = cast _selectedItems.members[i++];
			if (item != null && item.isOnScreen())
			{
				// Render a red rectangle centered at the selected item
				gfx.lineStyle(2, 0xff0000);
				gfx.drawRect(item.x - FlxG.camera.scroll.x, item.y - FlxG.camera.scroll.y, item.width * 1.0, item.height * 1.0);
				
				// Position the label above the selected item and show
				// its class name.
				_label.x = item.x - FlxG.camera.scroll.x;
				_label.y = item.y - FlxG.camera.scroll.y - 10;
				_label.text = FlxStringUtil.getClassName(item);
				//_label.draw();
			}
		}
		
		if (FlxG.renderBlit)
		{
			// Draw the rectangles to the main camera buffer.
			FlxG.camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
		}
	}
	
	private function clearSelection():Void
	{
		_selectedItems.clear();
	}
	
	private function handleItemClick(Item:FlxBasic):Void
	{			
		// Is it the first thing selected or are we adding things using Ctrl?
		if(_selectedItems.length == 0 || FlxG.keys.pressed.CONTROL)
		{
			// Yeah, that's the case. Just add the new thing to the selection.
			_selectedItems.add(Item);
		}
		else
		{
			// There is something already selected
			if (_selectedItems.members.indexOf(Item) == -1)
			{
				clearSelection();
			}
			_selectedItems.add(Item);
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
	
	public function getSelectedItems():FlxGroup
	{
		return _selectedItems;
	}
}
