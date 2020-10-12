package flixel.system.debug.interaction.tools;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.LineScaleMode;
import flash.display.CapsStyle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.system.debug.interaction.Interaction;
import flixel.system.debug.Tooltip;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;

using flixel.util.FlxArrayUtil;

@:bitmap("assets/images/debugger/buttons/transform.png")
private class GraphicTransformTool extends BitmapData {}

@:bitmap("assets/images/debugger/cursorCross.png")
private class GraphicTransformCursorDefault extends BitmapData {}

@:bitmap("assets/images/debugger/cursors/transformScaleY.png")
private class GraphicTransformCursorScaleY extends BitmapData {}

@:bitmap("assets/images/debugger/cursors/transformScaleX.png")
private class GraphicTransformCursorScaleX extends BitmapData {}

@:bitmap("assets/images/debugger/cursors/transformScaleXY.png")
private class GraphicTransformCursorScaleXY extends BitmapData {}

@:bitmap("assets/images/debugger/cursors/transformRotate.png")
private class GraphicTransformCursorRotate extends BitmapData {}

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

	var _actionTargetStartScale:FlxPoint = new FlxPoint();
	var _actionTargetStartAngle:Float;
	var _actionStartPoint:FlxPoint = new FlxPoint();
	var _actionHappening:Bool;
	var _actionMarker:Int;
	var _actionScaleDirection:FlxPoint = new FlxPoint();
	var _tooltip:TooltipOverlay;
	var _markers:Array<FlxPoint> = [];
	var _target:FlxSprite;
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

		_tooltip = Tooltip.add(null, "");
		_tooltip.textField.wordWrap = false;

		for (i in 0...4)
			_markers.push(new FlxPoint());

		stopAction();

		FlxG.signals.preStateSwitch.add(function() _target = null);
		return this;
	}

	function updateTargetArea():Void
	{
		if (_target == null)
		{
			_targetArea.setPosition(0, 0);
			_targetArea.setSize(0, 0);
		}
		else
		{
			_targetArea.setPosition(_target.x - FlxG.camera.scroll.x, _target.y - FlxG.camera.scroll.y);
			_targetArea.setSize(_target.width, _target.height);
		}
	}

	/**
	 * Start an interaction with a marker. Depending on the marker being used, the interaction
	 * can be to resize or rotate something.
	 */
	function startAction(whichMarker:Int):Void
	{
		if (_actionHappening)
			return;

		_actionHappening = true;
		_actionMarker = whichMarker;
		_actionStartPoint.set(_brain.flixelPointer.x - FlxG.camera.scroll.x, _brain.flixelPointer.y - FlxG.camera.scroll.y);
		_actionTargetStartAngle = FlxAngle.angleBetweenPoint(_target, _markers[MARKER_ROTATE], true);
		_actionTargetStartScale.set(_target.scale.x, _target.scale.y);
	}

	/**
	 * Stop any interaction activity that is happening with any marker.
	 */
	function stopAction():Void
	{
		_actionHappening = false;
		_actionMarker = -1;
		_tooltip.setVisible(false);
	}

	function getCursorNameByMarker(marker:Int):String
	{
		return switch (marker)
		{
			case MARKER_ROTATE: CURSOR_ROTATE;
			case MARKER_SCALE_X: CURSOR_SCALE_X;
			case MARKER_SCALE_XY: CURSOR_SCALE_XY;
			case MARKER_SCALE_Y: CURSOR_SCALE_Y;
			case _: "";
		}
	}

	function handleInteractionsWithMarkersUI():Void
	{
		if (_actionHappening)
			// If any action is already happening, e.g. resizing, then any UI interaction
			// with a marker other than the active one is not allowed.
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

	function formatFloat(number:Float):String
	{
		var value = FlxMath.roundDecimal(cast number, FlxG.debugger.precision);
		return Std.string(value);
	}

	function showTooltip(text:String):Void
	{
		if (!_tooltip.visible)
			_tooltip.setVisible(true);

		_tooltip.x = _target.x - FlxG.camera.scroll.x;
		_tooltip.y = _target.y - FlxG.camera.scroll.y;
		_tooltip.setText(text);
	}

	function updateScaleActionDirection():Void
	{
		var deltaX = _mouseCursor.x - _actionStartPoint.x;
		var deltaY = _mouseCursor.y - _actionStartPoint.y;

		_actionScaleDirection.x = deltaX >= 0 ? 1 : -1;
		_actionScaleDirection.y = deltaY >= 0 ? 1 : -1;
	}

	function updateScaleAction():Void
	{
		// Decide if the mouse cursor is moving away from or towards the target,
		// i.e. making the object bigger or smaller.
		updateScaleActionDirection();

		var deltaX = _actionScaleDirection.x * Math.abs(_mouseCursor.x - _actionStartPoint.x) / RESIZE_STEP;
		var deltaY = _actionScaleDirection.y * Math.abs(_mouseCursor.y - _actionStartPoint.y) / RESIZE_STEP;

		if (_actionMarker == MARKER_SCALE_X || _actionMarker == MARKER_SCALE_XY)
			_target.scale.x = _actionTargetStartScale.x + deltaX;
		if (_actionMarker == MARKER_SCALE_XY || _actionMarker == MARKER_SCALE_Y)
			_target.scale.y = _actionTargetStartScale.y + deltaY;

		_target.updateHitbox();
		_target.centerOrigin();

		showTooltip("w: " + formatFloat(_target.width) + "\nh: " + formatFloat(_target.height));
	}

	function updateRotateAction():Void
	{
		_target.angle = FlxAngle.angleBetweenPoint(_target, _brain.flixelPointer, true) - _actionTargetStartAngle;
		showTooltip("deg: " + formatFloat(_target.angle) + "\nrad: " + formatFloat(_target.angle * FlxAngle.TO_RAD));
	}

	function updateAction():Void
	{
		if (!_actionHappening || _actionMarker < 0)
			return;

		if (_actionMarker == MARKER_ROTATE)
			updateRotateAction();
		else
			updateScaleAction();
	}

	function updateMarkersPosition():Void
	{
		var topLeftX = _targetArea.x - OUTLINE_PADDING;
		var topLeftY = _targetArea.y - OUTLINE_PADDING;
		var width = _targetArea.width + OUTLINE_PADDING * 2;
		var height = _targetArea.height + OUTLINE_PADDING * 2;

		_markers[MARKER_ROTATE].set(topLeftX, topLeftY);
		_markers[MARKER_SCALE_X].set(topLeftX + width, topLeftY);
		_markers[MARKER_SCALE_XY].set(topLeftX + width, topLeftY + height);
		_markers[MARKER_SCALE_Y].set(topLeftX, topLeftY + height);

		if (_target.angle != 0)
			updateMarkersRotation(width, height);
	}

	function updateMarkersRotation(outlineWidth:Float, outlineHeight:Float):Void
	{
		var rotationAngleRad = _target.angle * FlxAngle.TO_RAD;
		var originX = _markers[0].x + outlineWidth / 2;
		var originY = _markers[0].y + outlineHeight / 2;
		var cos = FlxMath.fastCos(rotationAngleRad);
		var sin = FlxMath.fastSin(rotationAngleRad);

		for (marker in _markers)
		{
			// From: https://stackoverflow.com/a/2259502/29827
			var rotatedX = (marker.x - originX) * cos - (marker.y - originY) * sin;
			var rotatedY = (marker.x - originX) * sin + (marker.y - originY) * cos;
			marker.set(rotatedX + originX, rotatedY + originY);
		}
	}

	override public function update():Void
	{
		if (!isActive() || _target == null)
			return;

		// Calculate mouse cursor position on the screen (screen space/coordinates)
		_mouseCursor.x = _brain.flixelPointer.x - FlxG.camera.scroll.x;
		_mouseCursor.y = _brain.flixelPointer.y - FlxG.camera.scroll.y;

		updateTargetArea();
		updateMarkersPosition();
		handleInteractionsWithMarkersUI();

		if (_actionHappening)
		{
			updateAction();
			if (_brain.pointerJustReleased)
				stopAction();
		}
	}

	function drawTargetAreaOutline(gfx:Graphics):Void
	{
		gfx.lineStyle(0.9, FlxColor.MAGENTA, 1.0, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);

		gfx.moveTo(_markers[0].x, _markers[0].y);
		for (i in 0..._markers.length)
			gfx.lineTo(_markers[i].x, _markers[i].y);

		gfx.lineTo(_markers[0].x, _markers[0].y);
	}

	function drawMarkers(gfx:Graphics):Void
	{
		gfx.lineStyle(0.9, FlxColor.MAGENTA, 1.0, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
		gfx.beginFill(FlxColor.MAGENTA);
		for (i in 0..._markers.length)
			if (i == MARKER_ROTATE)
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

		if (gfx == null || _target == null || !isActive())
			return;

		drawTargetAreaOutline(gfx);
		drawMarkers(gfx);

		// Draw the debug info to the main camera buffer.
		if (FlxG.renderBlit)
			FlxG.camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}

	override public function activate():Void
	{
		_target = null;

		if (_brain.selectedItems.length == 0)
			return;

		for (member in _brain.selectedItems)
		{
			if (member != null && member.scrollFactor != null && member.isOnScreen())
			{
				// Allow only a single element to be worked on. Working with multiple
				// elements at once requires some further thoughts and love.
				_target = cast member;
				break;
			}
		}

		_brain.shouldDrawItemsSelection = false;
	}

	override public function deactivate():Void
	{
		_brain.shouldDrawItemsSelection = true;
	}
}
