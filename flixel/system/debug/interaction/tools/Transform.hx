package flixel.system.debug.interaction.tools;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.LineScaleMode;
import flash.display.CapsStyle;
import flash.ui.Keyboard;
import flash.events.MouseEvent;
import flixel.FlxBasic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.debug.interaction.Interaction;
import flixel.util.FlxSpriteUtil;
using flixel.util.FlxArrayUtil;

@:bitmap("assets/images/debugger/buttons/transform.png")
class GraphicTransformTool extends BitmapData {}

@:bitmap("assets/images/debugger/cursorCross.png")
class GraphicTransformCursorDefault extends BitmapData {}

@:bitmap("assets/images/debugger/cursors/transformScaleY.png")
class GraphicTransformCursorScaleY extends BitmapData {}

@:bitmap("assets/images/debugger/cursors/transformScaleX.png")
class GraphicTransformCursorScaleX extends BitmapData {}

@:bitmap("assets/images/debugger/cursors/transformScaleXY.png")
class GraphicTransformCursorScaleXY extends BitmapData {}

@:bitmap("assets/images/debugger/cursors/transformRotate.png")
class GraphicTransformCursorRotate extends BitmapData {}

/**
 * A tool to scale and rotate selected game elements.
 * 
 * @author Fernando Bevilacqua (dovyski@gmail.com)
 */
class Transform extends Tool
{	
	static inline var OUTLINE_PADDING = 5.0;
	static inline var MARKER_SIZE = 3.0;
	static inline var MARKER_INTERACTION_DISTANCE = 5.0;
	static inline var RESIZE_STEP = 10.0;

	static inline var CURSOR_ROTATE = "transformRotate";
	static inline var CURSOR_SCALE_X = "transformScaleX";
	static inline var CURSOR_SCALE_Y = "transformScaleY";
	static inline var CURSOR_SCALE_XY = "transformScaleXY";

	static inline var MARKER_ROTATE = 0;
	static inline var MARKER_SCALE_X = 1;
	static inline var MARKER_SCALE_XY = 2;
	static inline var MARKER_SCALE_Y = 3;

	var _actionStartPoint:FlxPoint = new FlxPoint();
	var _actionStartTargetCenter:FlxPoint = new FlxPoint();
	var _actionStartTargetScale:FlxPoint = new FlxPoint();
	var _actionHappening:Bool;
	var _actionWhichMarker:Int;
	var _actionDirection:FlxPoint = new FlxPoint();
	var _markers:Array<FlxPoint> = [];
	var _targetArea:FlxRect = new FlxRect();
	var _mouseCursor:FlxPoint = new FlxPoint();
	
	override public function init(brain:Interaction):Tool 
	{
		super.init(brain);
		
		_name = "Transform";
		setButton(GraphicTransformTool);
		setCursor(new GraphicTransformCursorDefault(0, 0));

		brain.registerCustomCursor(CURSOR_ROTATE, new GraphicTransformCursorRotate(0, 0));
		brain.registerCustomCursor(CURSOR_SCALE_X, new GraphicTransformCursorScaleX(0, 0));
		brain.registerCustomCursor(CURSOR_SCALE_Y, new GraphicTransformCursorScaleY(0, 0));
		brain.registerCustomCursor(CURSOR_SCALE_XY, new GraphicTransformCursorScaleXY(0, 0));		

		for(i in 0...4)
			_markers.push(new FlxPoint());

		stopAction();
		return this;
	}

	private function updateTargetArea():Void
	{
		_targetArea.setPosition(0, 0);
		_targetArea.setSize(0, 0);

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
				// TODO: calculate targetArea using multiple elements, i.e. centroid, etc.
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

	private function getCursorNameByMarker(marker:Int):String
	{
		return switch(marker)
		{
			case MARKER_ROTATE: CURSOR_ROTATE;
			case MARKER_SCALE_X: CURSOR_SCALE_X;
			case MARKER_SCALE_XY: CURSOR_SCALE_XY;
			case MARKER_SCALE_Y: CURSOR_SCALE_Y;
			case _: "";
		}
	}

	private function handleInteractionsWithMarkersUI():Void
	{
		if (_actionHappening)
			// If any action is happening, e.g. resizing, UI interactions with
			// any other marker different than the active one are not allowed.
			return;

		var cursorName = "";

		for (i in 0..._markers.length)
		{
			if (_mouseCursor.distanceTo(_markers[i]) <= MARKER_INTERACTION_DISTANCE)
			{
				cursorName = getCursorNameByMarker(i);
				if (_brain.pointerJustPressed)
				{
					startAction(i);
					break;
				}
			}
		}
		
		if (cursorName != "")
			setCursorInUse(cursorName);
		else
			useDefaultCursor();		
	}

	private function updateActionDirection():Void
	{
		var deltaX = _mouseCursor.x - _actionStartPoint.x;
		var deltaY = _mouseCursor.y - _actionStartPoint.y;

		_actionDirection.x = deltaX >=0 ? 1 : -1;
		_actionDirection.y = deltaY >=0 ? 1 : -1;
	}

	private function updateAction():Void
	{
		if (!_actionHappening || _actionWhichMarker < 0)
			return;

		// Decide if the mouse cursor is moving away from or towards the target,
		// i.e. making the object bigger or smaller.
		updateActionDirection();

		var deltaX = _actionDirection.x * Math.abs(_mouseCursor.x - _actionStartPoint.x) / RESIZE_STEP;
		var deltaY = _actionDirection.y * Math.abs(_mouseCursor.y - _actionStartPoint.y) / RESIZE_STEP;

		for (member in _brain.selectedItems)
		{
			if (member != null && member.scrollFactor != null && member.isOnScreen())
			{
				if (_actionWhichMarker == MARKER_ROTATE)
				{
					// TODO: implement the rotation action
				}
				else
				{
					// This is a scale action
					var target = cast(member, FlxSprite);

					if(_actionWhichMarker == MARKER_SCALE_X || _actionWhichMarker == MARKER_SCALE_XY)
						target.scale.x = _actionStartTargetScale.x + deltaX;
					if(_actionWhichMarker == MARKER_SCALE_XY || _actionWhichMarker == MARKER_SCALE_Y)
						target.scale.y = _actionStartTargetScale.y + deltaY;
					
					target.updateHitbox();
					target.centerOrigin();
				}
			}
		}
	}

	private function updateMarkersPosition():Void
	{
		var topLeftX = _targetArea.x - OUTLINE_PADDING;
		var topLeftY = _targetArea.y - OUTLINE_PADDING;
		var width = _targetArea.width + OUTLINE_PADDING * 2;
		var height = _targetArea.height + OUTLINE_PADDING * 2;

		_markers[MARKER_ROTATE].set(topLeftX, topLeftY);
		_markers[MARKER_SCALE_X].set(topLeftX + width, topLeftY);
		_markers[MARKER_SCALE_XY].set(topLeftX + width, topLeftY + height);
		_markers[MARKER_SCALE_Y].set(topLeftX, topLeftY + height);
	}
	
	override public function update():Void 
	{
		if (!isActive() || _brain.selectedItems.length == 0)
			return;

		// Calculate mouse cursor position on the screen (screen space/coordinates)
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
		gfx.lineStyle(1, 0xd800ff, 1.0, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
		
		gfx.moveTo(_markers[0].x, _markers[0].y);		
		for(i in 0..._markers.length)
			gfx.lineTo(_markers[i].x, _markers[i].y);

		gfx.lineTo(_markers[0].x, _markers[0].y);
	}

	private function drawMarkers(gfx:Graphics):Void
	{
		gfx.lineStyle(1, 0xd800ff, 1.0, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
		gfx.beginFill(0xd800ff);
		for(i in 0..._markers.length)
			if (i == 0)
				// Rotation marker
				gfx.drawCircle(_markers[i].x, _markers[i].y, MARKER_SIZE * 0.9);
			else
				// Scale marker
				gfx.drawRect(_markers[i].x - MARKER_SIZE / 2, _markers[i].y - MARKER_SIZE / 2, MARKER_SIZE, MARKER_SIZE);
		gfx.endFill();
	}

	override public function draw():Void 
	{
		var gfx:Graphics = _brain.getDebugGraphics();

		if (gfx == null || _brain.selectedItems.length == 0 || !isActive())
			return;

		drawTargetAreaOutline(gfx);
		drawMarkers(gfx);
		
		// Draw the debug info to the main camera buffer.
		if (FlxG.renderBlit)
			FlxG.camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}
}
