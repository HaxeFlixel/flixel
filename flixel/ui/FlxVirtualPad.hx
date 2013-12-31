package flixel.ui;

import flixel.FlxG;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxAssets;

/**
 * A gamepad which contains 4 directional buttons and 4 action buttons.
 * It's easy to set the callbacks and to customize the layout.
 * 
 * @author Ka Wing Chin
 */
class FlxVirtualPad extends FlxTypedGroup<FlxButton>
{	
	/**
	 * Don't use any directional button.
	 */ 
	inline static public var DPAD_NONE:Int = 0;
	/**
	 * Use the UP and DOWN directional buttons.
	 */ 
	inline static public var DPAD_UP_DOWN:Int = 1;
	/**
	 * Use the LEFT and RIGHT directional buttons.
	 */ 
	inline static public var DPAD_LEFT_RIGHT:Int = 2;
	/**
	 * Use the UP, LEFT and RIGHT directional buttons.
	 */
	inline static public var DPAD_UP_LEFT_RIGHT:Int = 3;
	/**
	 * Use all of 4 directional buttons.
	 */ 
	inline static public var DPAD_FULL:Int = 4;
	
	/**
	 * Don't use any action buttons.
	 */ 
	inline static public var ACTION_NONE:Int = 0;
	/**
	 * Use the A button only. 
	 */ 
	inline static public var ACTION_A:Int = 1;
	/**
	 * Use the A and B buttons.
	 */ 
	inline static public var ACTION_A_B:Int = 2;
	/**
	 * Use the A, B and C buttons.
	 */
	inline static public var ACTION_A_B_C:Int = 3;
	/**
	 * Use the A, B, X and Y buttons.
	 */
	inline static public var ACTION_A_B_X_Y:Int = 4;
	
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
	public var dPad:FlxTypedGroup<FlxButton>;
	/**
	 * Group of action buttons.
	 */ 
	public var actions:FlxTypedGroup<FlxButton>;
	
	/**
	 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of the gamepad.
	 */
	public var alpha(default, set):Float;
	
	/**
	 * Create a gamepad which contains 4 directional buttons and 4 action buttons.
	 * 
	 * @param 	DPadMode	The D-Pad mode. FlxGamePad.DPAD_FULL for example.
	 * @param 	ActionMode	The action buttons mode. FlxGamePad.ACTION_A_B_C for example.
	 */
	public function new(DPadMode:Int = DPAD_FULL, ActionMode:Int = ACTION_A_B_C)
	{	
		super();
		
		dPad = new FlxTypedGroup<FlxButton>();
		actions = new FlxTypedGroup<FlxButton>();
		
		switch (DPadMode)
		{
			case DPAD_UP_DOWN:
				dPad.add(add(buttonUp = createButton(0, FlxG.height - 85, 44, 45, FlxAssets.IMG_BUTTON_UP)));
				dPad.add(add(buttonDown = createButton(0, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_DOWN)));
			case DPAD_LEFT_RIGHT:
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_LEFT)));
				dPad.add(add(buttonRight = createButton(42, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_RIGHT)));
			case DPAD_UP_LEFT_RIGHT:
				dPad.add(add(buttonUp = createButton(35, FlxG.height - 81, 44, 45, FlxAssets.IMG_BUTTON_UP)));
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_LEFT)));
				dPad.add(add(buttonRight = createButton(69, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_RIGHT)));
			case DPAD_FULL:
				dPad.add(add(buttonUp = createButton(35, FlxG.height - 116, 44, 45, FlxAssets.IMG_BUTTON_UP)));	
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 81, 44, 45, FlxAssets.IMG_BUTTON_LEFT)));
				dPad.add(add(buttonRight = createButton(69, FlxG.height - 81, 44, 45, FlxAssets.IMG_BUTTON_RIGHT)));	
				dPad.add(add(buttonDown = createButton(35, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_DOWN)));
		}
		
		switch (ActionMode)
		{
			case ACTION_A:
				actions.add(add(buttonA = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_A)));
			case ACTION_A_B:
				actions.add(add(buttonA = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_A)));
				actions.add(add(buttonB = createButton(FlxG.width - 86, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_B)));
			case ACTION_A_B_C:
				actions.add(add(buttonA = createButton(FlxG.width - 128, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_A)));
				actions.add(add(buttonB = createButton(FlxG.width - 86, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_B)));
				actions.add(add(buttonC = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_C)));
			case ACTION_A_B_X_Y:
				actions.add(add(buttonY = createButton(FlxG.width - 86, FlxG.height - 85, 44, 45, FlxAssets.IMG_BUTTON_Y)));
				actions.add(add(buttonX = createButton(FlxG.width - 44, FlxG.height - 85, 44, 45, FlxAssets.IMG_BUTTON_X)));
				actions.add(add(buttonB = createButton(FlxG.width - 86, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_B)));
				actions.add(add(buttonA = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, FlxAssets.IMG_BUTTON_A)));
		}
		
		alpha = 1;
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		if (dPad != null)
		{
			dPad.destroy();
		}
		
		if (actions != null)
		{
			actions.destroy();
		}
		
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
	public function createButton(X:Float, Y:Float, Width:Int, Height:Int, Image:String, ?OnClick:Dynamic->Void):FlxButton
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
	
	private function set_alpha(Alpha:Float):Float
	{
		alpha = Alpha;
		
		for (member in members)
		{
			if (member != null)
			{
				member.alpha = Alpha;
			}
		}
		
		return Alpha;
	}
}