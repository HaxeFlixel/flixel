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
	var _actionStartPoint:FlxPoint = new FlxPoint();
	var _actionStartTargetCenter:FlxPoint = new FlxPoint();
	var _actionStartTargetScale:FlxPoint = new FlxPoint();
	var _actionHappening:Bool;
	var _actionWhichMarker:Int;
	var _markers:Array<FlxPoint> = [];
	var _targetArea:FlxRect = new FlxRect();
	var _mouseCursor:FlxPoint = new FlxPoint();
	
	override public function init(brain:Interaction):Tool 
	{
		super.init(brain);
		
		_name = "Transform";
		setButton(GraphicCursorScale);
		setCursor(new GraphicCursorScale(0, 0));

		// TODO: name markers with enum
		for(i in 0...5)
			_markers.push(new FlxPoint());

		stopAction();
		return this;
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
					_targetArea.setPosition(member.x - FlxG.camera.scroll.x, member.y - FlxG.camera.scroll.y);
					_targetArea.setSize(member.width, member.height);
					
					if (!_actionHappening)
						_actionStartTargetScale.set(cast(member, FlxSprite).scale.x, cast(member, FlxSprite).scale.y);
				}
				else
				{
					// TODO: calculate targetArea using multiple elements, i.e. centroid, etc.
				}
				//cast(member, FlxSprite).scale.set(3, 3);
			}
		}
	}

	/**
	 * Start an interaction with a marker. Depending on the marker being used, the interaction
	 * can be for resizing or rotating something.
	 */
	private function startAction(whichMarker:Int):Void
	{
		if (_actionHappening)
			return;

		_actionHappening = true;
		_actionWhichMarker = whichMarker;
		_actionStartPoint.set(
			_brain.flixelPointer.x - FlxG.camera.scroll.x,
			_brain.flixelPointer.y - FlxG.camera.scroll.y
		);		
		_actionStartTargetCenter.set(_targetArea.x, _targetArea.y);
	}
	
	/**
	 * Stop any interaction activity that is happening with any marker.
	 */
	private function stopAction():Void
	{	
		_actionHappening = false;
		_actionWhichMarker = -1;
	}

	private function handleInteractionsWithMarkersUI():Void
	{
		if (_actionHappening)
			// If any action is happening, e.g. resizing, UI interactions with
			// any other marker different than the active one are not allowed.
			return;

		for (i in 0..._markers.length)
			if (_mouseCursor.distanceTo(_markers[i]) <= 10)
			{
				// TODO: change mouse cursor according to current marker
				if (_brain.pointerJustPressed)
				{
					startAction(i);
					break;
				}
			}
	}

	private function calculateActionsMovementDirection():FlxPoint
	{
		var direction :FlxPoint = new FlxPoint(); // TODO: remove this dynamic allocation?
		var deltaX = _mouseCursor.x - _actionStartPoint.x;
		var deltaY = _mouseCursor.y - _actionStartPoint.y;

		direction.x = deltaX >=0 ? 1 : -1;
		direction.y = deltaY >=0 ? 1 : -1;

		return direction;
	}

	private function updateAction():Void
	{
		if (!_actionHappening || _actionWhichMarker < 0)
			return;

		var distanceTargetCenter = _mouseCursor.distanceTo(_actionStartTargetCenter);
		var distanceStartMarker = _mouseCursor.distanceTo(_actionStartPoint);
		var direction = calculateActionsMovementDirection();
		var deltaX = direction.x * Math.abs(_mouseCursor.x - _actionStartPoint.x) / 10;
		var deltaY = direction.y * Math.abs(_mouseCursor.y - _actionStartPoint.y) / 10;
		
		FlxG.log.add("distC=" + distanceTargetCenter + ", distM=" + distanceStartMarker + ", d=" + direction + " -> dx=" + deltaX + ", dy=" + deltaY);

		//if (deltaX <= 0.01 || deltaY <= 0.01)
			// Almost no movement in the interaction, nothing to do actually.
		//	return;

		for (member in _brain.selectedItems)
		{
			if (member != null && member.scrollFactor != null && member.isOnScreen())
				if (_actionWhichMarker == 4)
				{
					// TODO: implement rotation action
				}
				else
				{
					var target = cast(member, FlxSprite);
					if(_actionWhichMarker == 1 || _actionWhichMarker == 2)
						target.scale.x = _actionStartTargetScale.x + deltaX;
					if(_actionWhichMarker == 2 || _actionWhichMarker == 3)						
						target.scale.y = _actionStartTargetScale.y + deltaY;
					target.updateHitbox();
					target.centerOrigin();
				}
		}
	}

	private function updateMarkersPosition():Void
	{
		var padding = 5;
		var topLeftX = _targetArea.x - padding;
		var topLeftY = _targetArea.y - padding;
		var width = _targetArea.width + padding * 2;
		var height = _targetArea.height + padding * 2;

		// Markers in the corners of the target area
		_markers[0].set(topLeftX, topLeftY);
		_markers[1].set(topLeftX + width, topLeftY);
		_markers[2].set(topLeftX + width, topLeftY + height);
		_markers[3].set(topLeftX, topLeftY + height);

		// Marker separated from the target area used
		// to handle rotations
		_markers[4].set(topLeftX + width / 2, topLeftY - padding * 3);
	}
	
	override public function update():Void 
	{
		//if (_brain.selectedItems.length == 0)
		//	return;

		_mouseCursor.x = _brain.flixelPointer.x - FlxG.camera.scroll.x;
		_mouseCursor.y = _brain.flixelPointer.y - FlxG.camera.scroll.y;

		updateTargetArea();
		updateMarkersPosition();
		
		if (_actionHappening)
		{
			updateAction();
			if (_brain.pointerJustReleased)
				stopAction();
		}
		else
			handleInteractionsWithMarkersUI();
	}
	
	private function drawTargetAreaOutline(gfx:Graphics):Void
	{
		gfx.moveTo(_markers[0].x, _markers[0].y);		
		gfx.lineStyle(1.0, 0xd800ff);		

		for(i in 0...4)
			gfx.lineTo(_markers[i].x, _markers[i].y);

		gfx.lineTo(_markers[0].x, _markers[0].y);
	}

	private function drawMarkers(gfx:Graphics):Void
	{
		var markerSize = 3;
		
		gfx.lineStyle(1.5, 0xd800ff);
		for(i in 1...4)
			gfx.drawRect(_markers[i].x - markerSize / 2, _markers[i].y - markerSize / 2, markerSize, markerSize);
	}

	override public function draw():Void 
	{
		var gfx:Graphics = _brain.getDebugGraphics();

		if (gfx == null || _brain.selectedItems.length == 0)
			return;

		drawTargetAreaOutline(gfx);
		drawMarkers(gfx);
		
		// Draw the debug info to the main camera buffer.
		if (FlxG.renderBlit)
			FlxG.camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}
}
