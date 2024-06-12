package flixel.text;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.text.internal.FlxBaseTextInput;
import flixel.input.FlxPointer;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

/**
 * An extension of `FlxText` that allows the text to be selected and modified by the user.
 * 
 * @author Starmapo
 */
class FlxInputText extends FlxBaseInputText
{
	#if FLX_POINTER_INPUT
	/**
	 * Specifies whether the text object responds to double-presses.
	 */
	public var doublePressEnabled:Bool = true;
	#end

	#if FLX_MOUSE
	/**
	 * A Boolean value that indicates whether this text object is scrolled when the user rolls the mouse wheel on it.
	 */
	public var mouseWheelEnabled:Bool = true;
	#end

	#if FLX_POINTER_INPUT
	/**
	 * Specifies whether the text object responds to pointer (mouse & touch) input. Disabling this will also prevent the mouse wheel from
	 * affecting this text object.
	 */
	public var pointerEnabled:Bool = true;
	#end

	/**
	 * Helper variable for knowing if focus has been gained this frame through code.
	 */
	var _justGainedFocus:Bool = false;

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (_justGainedFocus)
		{
			_justGainedFocus = false;
		}
	}

	/**
	 * Updates all input for this text object.
	 */
	override function updateInput(elapsed:Float):Void
	{
		#if FLX_POINTER_INPUT
		var input = updateMouseInput(elapsed);

		if (!input)
		{
			input = updateTouchInput(elapsed);
		}
		#end
	}

	/**
	 * Checks for pointer overlap in a specific camera.
	 * @param pointer The pointer to check for overlap.
	 * @param camera The camera to check for overlap.
	 * @return A Boolean value indicating whether an overlap was detected.
	 */
	function checkPointerOverlap(pointer:FlxPointer, camera:FlxCamera):Bool
	{
		return overlapsPoint(pointer.getWorldPosition(camera, _point), true, camera);
	}

	/**
	 * Calculates a pointer's position relative to this text object.
	 * @param pointer The pointer to calculate the position from.
	 * @param camera Specify the camera you want. If `null`, `FlxG.camera` is used.
	 * @param point The optional output `FlxPoint` to be returned, if `null`, a new one is created.
	 * @return The mouse's relative position.
	 */
	function getPointerPosition(pointer:FlxPointer, ?camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (point == null)
		{
			point = FlxPoint.get();
		}

		pointer.getScreenPosition(camera, point);

		final position = getScreenPosition(FlxPoint.weak(), camera);
		point.subtractPoint(position);

		return point;
	}

	#if FLX_POINTER_INPUT
	/**
	 * Updates mouse input for this text object.
	 * @return A Boolean value indicating whether mouse input was detected.
	 */
	function updateMouseInput(elapsed:Float):Bool
	{
		var input = false;

		#if FLX_MOUSE
		if (!pointerEnabled)
		{
			return input;
		}

		var overlap = false;
		for (camera in cameras)
		{
			if (checkPointerOverlap(FlxG.mouse, camera))
			{
				currentCamera = camera;
				overlap = true;
				break;
			}
		}

		final mousePos = getPointerPosition(FlxG.mouse, currentCamera);

		if (FlxG.mouse.justPressed)
		{
			if (overlap)
			{
				onDownHandler(mousePos.x, mousePos.y);

				input = true;
			}
			else if ((selectable || type == INPUT) && !_justGainedFocus)
			{
				focus = false;
			}
		}

		if (overlap && FlxG.mouse.wheel != 0)
		{
			onMouseWheelHandler();
			input = true;
		}

		if (_down)
		{
			updateDrag(elapsed, mousePos.x, mousePos.y);

			if (FlxG.mouse.justReleased)
			{
				onUpHandler(mousePos.x, mousePos.y);

				if (doublePressEnabled)
				{
					checkDoublePress();
				}
			}

			input = true;
		}

		mousePos.put();
		#end

		return input;
	}

	/**
	 * Updates touch input for this text object.
	 * @return A Boolean value indicating whether touch input was detected.
	 */
	function updateTouchInput(elapsed:Float):Bool
	{
		var input = false;

		#if FLX_TOUCH
		if (!pointerEnabled)
		{
			return input;
		}

		var touch:FlxTouch = null;
		var overlap = false;
		for (camera in cameras)
		{
			for (t in FlxG.touches.list)
			{
				if (checkPointerOverlap(t, camera))
				{
					touch = t;
					currentCamera = camera;
					overlap = true;
					break;
				}
			}
		}

		if (touch == null)
		{
			return input;
		}

		final touchPos = getPointerPosition(touch, currentCamera);

		if (touch.justPressed)
		{
			if (overlap)
			{
				onDownHandler(touchPos.x, touchPos.y);

				input = true;
			}
			else if ((selectable || type == INPUT) && !_justGainedFocus)
			{
				focus = false;
			}
		}

		if (_down)
		{
			updateDrag(elapsed, touchPos.x, touchPos.y);

			if (touch.justReleased)
			{
				onUpHandler(touchPos.x, touchPos.y);

				if (doublePressEnabled)
				{
					checkDoublePress();
				}
			}

			input = true;
		}

		touchPos.put();
		#end

		return input;
	}
	#end

	#if FLX_MOUSE
	/**
	 * This function handles when the mouse wheel is rolled.
	 */
	function onMouseWheelHandler():Void
	{
		if (mouseWheelEnabled)
		{
			scrollV = Std.int(Math.min(scrollV - FlxG.mouse.wheel, maxScrollV));
		}
	}
	#end

	override function set_focus(value:Bool):Bool
	{
		_justGainedFocus = value;

		return super.set_focus(value);
	}
}