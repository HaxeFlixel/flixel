package flixel.ui;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets;

/**
 * A gamepad which contains 4 directional buttons and 4 action buttons.
 * It's easy to set the callbacks and to customize the layout.
 * 
 * @author Ka Wing Chin
 */
class FlxVirtualPad extends FlxSpriteGroup
{	
	/**
	 * Button A
	 */
	public var buttonA:FlxButton;
	/**
	 *  Button B
	 */
	public var buttonB:FlxButton;
	/**
	 * Button C
	 */ 
	public var buttonC:FlxButton;
	/**
	 * Button Y
	 */ 
	public var buttonY:FlxButton;
	/**
	 * Button X
	 */ 
	public var buttonX:FlxButton;
	/**
	 * Button LEFT DIRECTION
	 */
	public var buttonLeft:FlxButton;
	/**
	 * Button UP DIRECTION
	 */ 
	public var buttonUp:FlxButton;
	/**
	 * Button RIGHT DIRECTION
	 */ 
	public var buttonRight:FlxButton;
	/**
	 * BUTTON DOWN DIRECTION 
	 */
	public var buttonDown:FlxButton;
	/**
	 * Group of directions buttons.
	 */ 
	public var dPad:FlxSpriteGroup;
	/**
	 * Group of action buttons.
	 */ 
	public var actions:FlxSpriteGroup;
	
	/**
	 * Create a gamepad which contains 4 directional buttons and 4 action buttons.
	 * 
	 * @param 	DPadMode	The D-Pad mode. FULL for example.
	 * @param 	ActionMode	The action buttons mode. A_B_C for example.
	 */
	public function new(?DPad:DPadMode, ?Action:ActionMode)
	{	
		super();
		scrollFactor.set();
		
		if (DPad == null) {
			DPad = FULL;
		}
		if (Action == null) {
			Action = A_B_C;
		}
		
		dPad = new FlxSpriteGroup();
		dPad.scrollFactor.set();
		
		actions = new FlxSpriteGroup();
		actions.scrollFactor.set();
		
		switch (DPad)
		{
			case UP_DOWN:
				dPad.add(add(buttonUp = createButton(0, FlxG.height - 85, 44, 45, FlxAssets.IMG_BUTTON_UP)));
				dPad.add(add(buttonDown = createButton(0, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_DOWN)));
			case LEFT_RIGHT:
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_LEFT)));
				dPad.add(add(buttonRight = createButton(42, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_RIGHT)));
			case UP_LEFT_RIGHT:
				dPad.add(add(buttonUp = createButton(35, FlxG.height - 81, 44, 45, FlxAssets.IMG_BUTTON_UP)));
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_LEFT)));
				dPad.add(add(buttonRight = createButton(69, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_RIGHT)));
			case FULL:
				dPad.add(add(buttonUp = createButton(35, FlxG.height - 116, 44, 45, FlxAssets.IMG_BUTTON_UP)));	
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 81, 44, 45, FlxAssets.IMG_BUTTON_LEFT)));
				dPad.add(add(buttonRight = createButton(69, FlxG.height - 81, 44, 45, FlxAssets.IMG_BUTTON_RIGHT)));	
				dPad.add(add(buttonDown = createButton(35, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_DOWN)));
			case NONE: // do nothing
		}
		
		switch (Action)
		{
			case A:
				actions.add(add(buttonA = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_A)));
			case A_B:
				actions.add(add(buttonA = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_A)));
				actions.add(add(buttonB = createButton(FlxG.width - 86, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_B)));
			case A_B_C:
				actions.add(add(buttonA = createButton(FlxG.width - 128, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_A)));
				actions.add(add(buttonB = createButton(FlxG.width - 86, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_B)));
				actions.add(add(buttonC = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_C)));
			case A_B_X_Y:
				actions.add(add(buttonY = createButton(FlxG.width - 86, FlxG.height - 85, 44, 45, FlxAssets.IMG_BUTTON_Y)));
				actions.add(add(buttonX = createButton(FlxG.width - 44, FlxG.height - 85, 44, 45, FlxAssets.IMG_BUTTON_X)));
				actions.add(add(buttonB = createButton(FlxG.width - 86, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_B)));
				actions.add(add(buttonA = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_A)));
			case NONE: // do nothing
		}
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		dPad = FlxG.safeDestroy(dPad);
		actions = FlxG.safeDestroy(actions);
		
		dPad = null;
		actions = null;
		buttonA = null;
		buttonB = null;
		buttonC = null;
		buttonY = null;
		buttonX = null;
		buttonLeft = null;
		buttonUp = null;
		buttonDown = null;
		buttonRight = null;
	}
	
	/**
	 * Creates a button
	 * 
	 * @param 	X			The x-position of the button.
	 * @param 	Y			The y-position of the button.
	 * @param 	Width		The width of the button.
	 * @param 	Height		The height of the button.
	 * @param 	Image		The image of the button. It must contains 3 frames (NORMAL, HIGHLIGHT, PRESSED).
	 * @param 	Callback	The callback for the button.
	 * @return	The button
	 */
	public function createButton(X:Float, Y:Float, Width:Int, Height:Int, Image:String, ?OnClick:Void->Void):FlxButton
	{
		var button:FlxButton = new FlxButton(X, Y);
		button.loadGraphic(Image, true, false, Width, Height);
		button.solid = false;
		button.immovable = true;
		button.scrollFactor.set();
		
		#if !FLX_NO_DEBUG
		button.ignoreDrawDebug = true;
		#end
		
		if (OnClick != null)
		{
			button.onDown.callback = OnClick;
		}
		
		return button;
	}
}

enum DPadMode {
	NONE;
	UP_DOWN;
	LEFT_RIGHT;
	UP_LEFT_RIGHT;
	FULL;
}

enum ActionMode {
	NONE;
	A;
	A_B;
	A_B_C;
	A_B_X_Y;
}