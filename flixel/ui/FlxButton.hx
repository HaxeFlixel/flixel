package flixel.ui;

import openfl.events.MouseEvent;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.atlas.FlxNode;
import flixel.graphics.frames.FlxTileFrames;
import flixel.input.FlxInput;
import flixel.input.FlxPointer;
import flixel.input.IFlxInput;
import flixel.input.mouse.FlxMouseButton;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxDestroyUtil;
#if FLX_TOUCH
import flixel.input.touch.FlxTouch;
#end

/**
 * A simple button class that calls a function when clicked by the mouse.
 */
class FlxButton extends FlxTypedButton<FlxText>
{
	/**
	 * Used with public variable status, means not highlighted or pressed.
	 */
	public static inline var NORMAL:Int = 0;

	/**
	 * Used with public variable status, means highlighted (usually from mouse over).
	 */
	public static inline var HIGHLIGHT:Int = 1;

	/**
	 * Used with public variable status, means pressed (usually from mouse click).
	 */
	public static inline var PRESSED:Int = 2;

	/**
	 * Shortcut to setting label.text
	 */
	public var text(get, set):String;

	/**
	 * Creates a new `FlxButton` object with a gray background
	 * and a callback function on the UI thread.
	 *
	 * @param   X         The x position of the button.
	 * @param   Y         The y position of the button.
	 * @param   Text      The text that you want to appear on the button.
	 * @param   OnClick   The function to call whenever the button is clicked.
	 */
	public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void)
	{
		super(X, Y, OnClick);

		for (point in labelOffsets)
			point.set(point.x, point.y + 3);

		initLabel(Text);
	}

	/**
	 * Updates the size of the text field to match the button.
	 */
	override function resetHelpers():Void
	{
		super.resetHelpers();

		if (label != null)
		{
			label.fieldWidth = label.frameWidth = Std.int(width);
			label.size = label.size; // Calls set_size(), don't remove!
		}
	}

	inline function initLabel(Text:String):Void
	{
		if (Text != null)
		{
			label = new FlxText(x + labelOffsets[NORMAL].x, y + labelOffsets[NORMAL].y, 80, Text);
			label.setFormat(null, 8, 0x333333, "center");
			label.alpha = labelAlphas[status];
			label.drawFrame(true);
		}
	}

	inline function get_text():String
	{
		return (label != null) ? label.text : null;
	}

	inline function set_text(Text:String):String
	{
		if (label == null)
		{
			initLabel(Text);
		}
		else
		{
			label.text = Text;
		}
		return Text;
	}
}

/**
 * A simple button class that calls a function when clicked by the mouse.
 */
#if !display
@:generic
#end
class FlxTypedButton<T:FlxSprite> extends FlxSprite implements IFlxInput
{
	/**
	 * The label that appears on the button. Can be any `FlxSprite`.
	 */
	public var label(default, set):T;

	/**
	 * What offsets the `label` should have for each status.
	 */
	public var labelOffsets:Array<FlxPoint> = [FlxPoint.get(), FlxPoint.get(), FlxPoint.get(0, 1)];

	/**
	 * What alpha value the label should have for each status. Default is `[0.8, 1.0, 0.5]`.
	 * Multiplied with the button's `alpha`.
	 */
	public var labelAlphas:Array<Float> = [0.8, 1.0, 0.5];

	/**
	 * What animation should be played for each status.
	 * Default is ["normal", "highlight", "pressed"].
	 */
	public var statusAnimations:Array<String> = ["normal", "highlight", "pressed"];

	/**
	 * Whether you can press the button simply by releasing the touch / mouse button over it (default).
	 * If false, the input has to be pressed while hovering over the button.
	 */
	public var allowSwiping:Bool = true;

	#if FLX_MOUSE
	/**
	 * Which mouse buttons can trigger the button - by default only the left mouse button.
	 */
	public var mouseButtons:Array<FlxMouseButtonID> = [FlxMouseButtonID.LEFT];
	#end

	/**
	 * Maximum distance a pointer can move to still trigger event handlers.
	 * If it moves beyond this limit, onOut is triggered.
	 * Defaults to `Math.POSITIVE_INFINITY` (i.e. no limit).
	 */
	public var maxInputMovement:Float = Math.POSITIVE_INFINITY;

	/**
	 * Shows the current state of the button, either `FlxButton.NORMAL`,
	 * `FlxButton.HIGHLIGHT` or `FlxButton.PRESSED`.
	 */
	public var status(default, set):Int;

	/**
	 * The properties of this button's `onUp` event (callback function, sound).
	 */
	public var onUp(default, null):FlxButtonEvent;

	/**
	 * The properties of this button's `onDown` event (callback function, sound).
	 */
	public var onDown(default, null):FlxButtonEvent;

	/**
	 * The properties of this button's `onOver` event (callback function, sound).
	 */
	public var onOver(default, null):FlxButtonEvent;

	/**
	 * The properties of this button's `onOut` event (callback function, sound).
	 */
	public var onOut(default, null):FlxButtonEvent;

	public var justReleased(get, never):Bool;
	public var released(get, never):Bool;
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;

	/**
	 * We cast label to a `FlxSprite` for internal operations to avoid Dynamic casts in C++
	 */
	var _spriteLabel:FlxSprite;

	/** 
	 * We don't need an ID here, so let's just use `Int` as the type.
	 */
	var input:FlxInput<Int>;

	/**
	 * The input currently pressing this button, if none, it's `null`. Needed to check for its release.
	 */
	var currentInput:IFlxInput;

	var lastStatus = -1;

	/**
	 * Creates a new `FlxTypedButton` object with a gray background.
	 *
	 * @param   X         The x position of the button.
	 * @param   Y         The y position of the button.
	 * @param   OnClick   The function to call whenever the button is clicked.
	 */
	public function new(X:Float = 0, Y:Float = 0, ?OnClick:Void->Void)
	{
		super(X, Y);

		loadDefaultGraphic();

		onUp = new FlxButtonEvent(OnClick);
		onDown = new FlxButtonEvent();
		onOver = new FlxButtonEvent();
		onOut = new FlxButtonEvent();

		status = FlxButton.NORMAL;

		// Since this is a UI element, the default scrollFactor is (0, 0)
		scrollFactor.set();

		#if FLX_MOUSE
		FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, onUpEventListener);
		#end

		#if FLX_NO_MOUSE // no need for highlight frame without mouse input
		statusAnimations[FlxButton.HIGHLIGHT] = "normal";
		labelAlphas[FlxButton.HIGHLIGHT] = 1;
		#end

		input = new FlxInput(0);
	}

	override public function graphicLoaded():Void
	{
		super.graphicLoaded();

		setupAnimation("normal", FlxButton.NORMAL);
		setupAnimation("highlight", FlxButton.HIGHLIGHT);
		setupAnimation("pressed", FlxButton.PRESSED);
	}

	function loadDefaultGraphic():Void
	{
		loadGraphic("flixel/images/ui/button.png", true, 80, 20);
	}

	function setupAnimation(animationName:String, frameIndex:Int):Void
	{
		// make sure the animation doesn't contain an invalid frame
		frameIndex = Std.int(Math.min(frameIndex, animation.numFrames - 1));
		animation.add(animationName, [frameIndex]);
	}

	/**
	 * Called by the game state when state is changed (if this object belongs to the state)
	 */
	override public function destroy():Void
	{
		label = FlxDestroyUtil.destroy(label);
		_spriteLabel = null;

		onUp = FlxDestroyUtil.destroy(onUp);
		onDown = FlxDestroyUtil.destroy(onDown);
		onOver = FlxDestroyUtil.destroy(onOver);
		onOut = FlxDestroyUtil.destroy(onOut);

		labelOffsets = FlxDestroyUtil.putArray(labelOffsets);

		labelAlphas = null;
		currentInput = null;
		input = null;

		#if FLX_MOUSE
		FlxG.stage.removeEventListener(MouseEvent.MOUSE_UP, onUpEventListener);
		#end

		super.destroy();
	}

	/**
	 * Called by the game loop automatically, handles mouseover and click detection.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (visible)
		{
			// Update the button, but only if at least either mouse or touches are enabled
			#if FLX_POINTER_INPUT
			updateButton();
			#end

			// Trigger the animation only if the button's input status changes.
			if (lastStatus != status)
			{
				updateStatusAnimation();
				lastStatus = status;
			}
		}

		input.update();
	}

	function updateStatusAnimation():Void
	{
		animation.play(statusAnimations[status]);
	}

	/**
	 * Just draws the button graphic and text label to the screen.
	 */
	override public function draw():Void
	{
		super.draw();

		if (_spriteLabel != null && _spriteLabel.visible)
		{
			_spriteLabel.cameras = cameras;
			_spriteLabel.draw();
		}
	}

	#if FLX_DEBUG
	/**
	 * Helper function to draw the debug graphic for the label as well.
	 */
	override public function drawDebug():Void
	{
		super.drawDebug();

		if (_spriteLabel != null)
		{
			_spriteLabel.drawDebug();
		}
	}
	#end

	/**
	 * Stamps button's graphic and label onto specified atlas object and loads graphic from this atlas.
	 * This method assumes that you're using whole image for button's graphic and image has no spaces between frames.
	 * And it assumes that label is a single frame sprite.
	 *
	 * @param   atlas   Atlas to stamp graphic to.
	 * @return  Whether the button's graphic and label's graphic were stamped on the atlas successfully.
	 */
	public function stampOnAtlas(atlas:FlxAtlas):Bool
	{
		var buttonNode:FlxNode = atlas.addNode(graphic.bitmap, graphic.key);
		var result:Bool = (buttonNode != null);

		if (buttonNode != null)
		{
			var buttonFrames:FlxTileFrames = cast frames;
			var tileSize:FlxPoint = FlxPoint.get(buttonFrames.tileSize.x, buttonFrames.tileSize.y);
			var tileFrames:FlxTileFrames = buttonNode.getTileFrames(tileSize);
			this.frames = tileFrames;
		}

		if (result && label != null)
		{
			var labelNode:FlxNode = atlas.addNode(label.graphic.bitmap, label.graphic.key);
			result = result && (labelNode != null);

			if (labelNode != null)
				label.frames = labelNode.getImageFrame();
		}

		return result;
	}

	/**
	 * Basic button update logic - searches for overlaps with touches and
	 * the mouse cursor and calls `updateStatus()`.
	 */
	function updateButton():Void
	{
		// We're looking for any touch / mouse overlaps with this button
		var overlapFound = checkMouseOverlap();
		if (!overlapFound)
			overlapFound = checkTouchOverlap();

		if (currentInput != null && currentInput.justReleased && overlapFound)
		{
			onUpHandler();
		}

		if (status != FlxButton.NORMAL && (!overlapFound || (currentInput != null && currentInput.justReleased)))
		{
			onOutHandler();
		}
	}

	function checkMouseOverlap():Bool
	{
		var overlap = false;
		#if FLX_MOUSE
		for (camera in cameras)
		{
			for (buttonID in mouseButtons)
			{
				var button = FlxMouseButton.getByID(buttonID);
				if (button != null && checkInput(FlxG.mouse, button, button.justPressedPosition, camera))
				{
					overlap = true;
				}
			}
		}
		#end
		return overlap;
	}

	function checkTouchOverlap():Bool
	{
		var overlap = false;
		#if FLX_TOUCH
		for (camera in cameras)
		{
			for (touch in FlxG.touches.list)
			{
				if (checkInput(touch, touch, touch.justPressedPosition, camera))
				{
					overlap = true;
				}
			}
		}
		#end
		return overlap;
	}

	function checkInput(pointer:FlxPointer, input:IFlxInput, justPressedPosition:FlxPoint, camera:FlxCamera):Bool
	{
		if (maxInputMovement != Math.POSITIVE_INFINITY
			&& justPressedPosition.distanceTo(pointer.getScreenPosition(FlxPoint.weak())) > maxInputMovement
			&& input == currentInput)
		{
			currentInput = null;
		}
		else if (overlapsPoint(pointer.getWorldPosition(camera, _point), true, camera))
		{
			updateStatus(input);
			return true;
		}

		return false;
	}

	/**
	 * Updates the button status by calling the respective event handler function.
	 */
	function updateStatus(input:IFlxInput):Void
	{
		if (input.justPressed)
		{
			currentInput = input;
			onDownHandler();
		}
		else if (status == FlxButton.NORMAL)
		{
			// Allow "swiping" to press a button (dragging it over the button while pressed)
			if (allowSwiping && input.pressed)
			{
				onDownHandler();
			}
			else
			{
				onOverHandler();
			}
		}
	}

	function updateLabelPosition()
	{
		if (_spriteLabel != null) // Label positioning
		{
			_spriteLabel.x = (pixelPerfectPosition ? Math.floor(x) : x) + labelOffsets[status].x;
			_spriteLabel.y = (pixelPerfectPosition ? Math.floor(y) : y) + labelOffsets[status].y;
		}
	}

	function updateLabelAlpha()
	{
		if (_spriteLabel != null && labelAlphas.length > status)
		{
			_spriteLabel.alpha = alpha * labelAlphas[status];
		}
	}

	/**
	 * Using an event listener is necessary for security reasons on flash -
	 * certain things like opening a new window are only allowed when they are user-initiated.
	 */
	#if FLX_MOUSE
	function onUpEventListener(_):Void
	{
		if (visible && exists && active && status == FlxButton.PRESSED)
		{
			onUpHandler();
		}
	}
	#end

	/**
	 * Internal function that handles the onUp event.
	 */
	function onUpHandler():Void
	{
		status = FlxButton.HIGHLIGHT;
		input.release();
		currentInput = null;
		// Order matters here, because onUp.fire() could cause a state change and destroy this object.
		onUp.fire();
	}

	/**
	 * Internal function that handles the onDown event.
	 */
	function onDownHandler():Void
	{
		status = FlxButton.PRESSED;
		input.press();
		// Order matters here, because onDown.fire() could cause a state change and destroy this object.
		onDown.fire();
	}

	/**
	 * Internal function that handles the onOver event.
	 */
	function onOverHandler():Void
	{
		#if FLX_MOUSE
		// If mouse input is not enabled, this button must ignore over actions
		// by remaining in the normal state (until mouse input is re-enabled).
		if (!FlxG.mouse.enabled)
		{
			status = FlxButton.NORMAL;
			return;
		}
		#end
		status = FlxButton.HIGHLIGHT;
		// Order matters here, because onOver.fire() could cause a state change and destroy this object.
		onOver.fire();
	}

	/**
	 * Internal function that handles the onOut event.
	 */
	function onOutHandler():Void
	{
		status = FlxButton.NORMAL;
		input.release();
		// Order matters here, because onOut.fire() could cause a state change and destroy this object.
		onOut.fire();
	}

	function set_label(Value:T):T
	{
		if (Value != null)
		{
			// use the same FlxPoint object for both
			Value.scrollFactor.put();
			Value.scrollFactor = scrollFactor;
		}

		label = Value;
		_spriteLabel = label;

		updateLabelPosition();

		return Value;
	}

	function set_status(Value:Int):Int
	{
		status = Value;
		updateLabelAlpha();
		return status;
	}

	override function set_alpha(Value:Float):Float
	{
		super.set_alpha(Value);
		updateLabelAlpha();
		return alpha;
	}

	override function set_x(Value:Float):Float
	{
		super.set_x(Value);
		updateLabelPosition();
		return x;
	}

	override function set_y(Value:Float):Float
	{
		super.set_y(Value);
		updateLabelPosition();
		return y;
	}

	inline function get_justReleased():Bool
	{
		return input.justReleased;
	}

	inline function get_released():Bool
	{
		return input.released;
	}

	inline function get_pressed():Bool
	{
		return input.pressed;
	}

	inline function get_justPressed():Bool
	{
		return input.justPressed;
	}
}

/** 
 * Helper function for `FlxButton` which handles its events.
 */
private class FlxButtonEvent implements IFlxDestroyable
{
	/**
	 * The callback function to call when this even fires.
	 */
	public var callback:Void->Void;

	#if FLX_SOUND_SYSTEM
	/**
	 * The sound to play when this event fires.
	 */
	public var sound:FlxSound;
	#end

	/**
	 * @param   Callback   The callback function to call when this even fires.
	 * @param   sound      The sound to play when this event fires.
	 */
	public function new(?Callback:Void->Void, ?sound:FlxSound)
	{
		callback = Callback;

		#if FLX_SOUND_SYSTEM
		this.sound = sound;
		#end
	}

	/**
	 * Cleans up memory.
	 */
	public inline function destroy():Void
	{
		callback = null;

		#if FLX_SOUND_SYSTEM
		sound = FlxDestroyUtil.destroy(sound);
		#end
	}

	/**
	 * Fires this event (calls the callback and plays the sound)
	 */
	public inline function fire():Void
	{
		if (callback != null)
			callback();

		#if FLX_SOUND_SYSTEM
		if (sound != null)
			sound.play(true);
		#end
	}
}
