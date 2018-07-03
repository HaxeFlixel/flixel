package flixel.system.debug.interaction.tools;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.ui.Keyboard;
import flash.events.MouseEvent;
import flixel.FlxBasic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.debug.interaction.Interaction;
import flixel.util.FlxSpriteUtil;
using flixel.util.FlxArrayUtil;

@:bitmap("assets/images/debugger/cursorCross.png")
class GraphicCursorScale extends BitmapData {}

/**
 * A tool to scale and rotate selected game elements.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Transform extends Tool
{		
	var _selectionStartPoint:FlxPoint = new FlxPoint();
	var _selectionEndPoint:FlxPoint = new FlxPoint();
	var _selectionHappening:Bool = false;
	var _selectionCancelled:Bool = false;
	var _selectionArea:FlxRect = new FlxRect();
	var _itemsInSelectionArea:Array<FlxBasic> = [];
	var _targetArea:FlxRect = new FlxRect();
	
	override public function init(brain:Interaction):Tool 
	{
		super.init(brain);
		
		_name = "Transform";
		setButton(GraphicCursorScale);
		setCursor(new GraphicCursorScale(0, 0));

		return this;
	}

	private function handleMouseMarkerInteraction(event:MouseEvent):Void
	{
		trace(event.type);
	}

	private function updateTargetArea():Void
	{
		_targetArea.setPosition(0, 0);
		_targetArea.setSize(0, 0);

		// TODO: refactor this
		var groupTargetArea:Bool = _brain.selectedItems.length > 1;

		for (member in _brain.selectedItems)
		{
			if (member != null && member.scrollFactor != null && member.isOnScreen())
			{
				if (!groupTargetArea)
				{
					_targetArea.setPosition(member.x, member.y);
					_targetArea.setSize(member.width, member.height);
				}
				else
				{
					// TODO: calculate targetArea using multiple elements, i.e. centroid, etc.
				}
				//cast(member, FlxSprite).scale.set(3, 3);
			}
		}
	}
	
	override public function update():Void 
	{
		if (_brain.selectedItems.length == 0)
			return;

		updateTargetArea();
	}
	
	private function drawControlMarkers(gfx:Graphics):Void
	{
		gfx.lineStyle(1.2, 0xd800ff);
		for(i in 0...8)
			gfx.drawRect(_targetArea.x - FlxG.camera.scroll.x - 5, _targetArea.y - FlxG.camera.scroll.y - 5, 3, 3);
	}

	override public function draw():Void 
	{
		var gfx:Graphics = _brain.getDebugGraphics();
		if (gfx == null)
			return;
		
		if (_brain.selectedItems.length == 0)
			return;

		drawControlMarkers(gfx);

		for (member in _brain.selectedItems)
		{
			if (member != null && member.scrollFactor != null && member.isOnScreen())
			{
				// Render transformation marks on key positions of the item
				//gfx.lineStyle(1.9, 0xd800ff);
				//gfx.drawRect(member.x - FlxG.camera.scroll.x - 10,
				//	member.y - FlxG.camera.scroll.y + 10,
				//	member.width * 1.0, member.height * 1.0);
			}
		}
		
		// Draw the debug info to the main camera buffer.
		if (FlxG.renderBlit)
			FlxG.camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}
}
