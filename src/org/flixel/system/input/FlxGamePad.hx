package org.flixel.system.input;

import org.flixel.FlxSprite;
import org.flixel.FlxAssets;
import org.flixel.FlxG;
import org.flixel.FlxButton;
import org.flixel.FlxTypedGroup;

/**
 * A gamepad which contains 4 directional buttons and 4 action buttons.
 * It's easy to set the callbacks and to customize the layout.
 * 
 * @author Ka Wing Chin
 */
class FlxGamePad extends FlxTypedGroup<FlxButton>
{	
	// Button A
	public var buttonA:FlxButton;
	// Button B
	public var buttonB:FlxButton;
	// Button C
	public var buttonC:FlxButton;
	// Button Y
	public var buttonY:FlxButton;
	// Button X
	public var buttonX:FlxButton;
	// Button LEFT DIRECTION
	public var buttonLeft:FlxButton;
	// Button UP DIRECTION
	public var buttonUp:FlxButton;
	// Button RIGHT DIRECTION
	public var buttonRight:FlxButton;
	// BUTTON DOWN DIRECTION
	public var buttonDown:FlxButton;
	
	// Don't use any button.
	public static inline var NONE:Int = 0;
	// Use the set of 4 directions or A, B, X, and Y.
	public static inline var FULL:Int = 1;
	// Use UP and DOWN direction buttons.
	public static inline var UP_DOWN:Int = 2;
	// Use LEFT and RIGHT direction buttons.
	public static inline var LEFT_RIGHT:Int = 3;
	// Use UP, LEFT and RIGHT direction buttons.
	public static inline var UP_LEFT_RIGHT:Int = 4;
	// Use only A button. 
	public static inline var A:Int = 5;
	// Use A and B button.
	public static inline var A_B:Int = 6;
	// Use A, B and C button.
	public static inline var A_B_C:Int = 7;
	
	// Group of directions buttons.
	public var dPad:FlxTypedGroup<FlxButton>;
	// Group of action buttons.
	public var actions:FlxTypedGroup<FlxButton>;
	
	/**
	 * Constructor
	 * @param DPad		The D-Pad mode. FlxGamePad.FULL for example.
	 * @param Action	The action buttons mode. FlxGamePad.A_B_C for example.
	 */
	public function new(DPad:Int, Action:Int)
	{	
		super();
		
		dPad = new FlxTypedGroup<FlxButton>();
		actions = new FlxTypedGroup<FlxButton>();
		
		switch (DPad)
		{
			case FULL:
				dPad.add(add(buttonUp = createButton(35, FlxG.height - 116, 44, 45, FlxAssets.imgButtonUp)));	
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 81, 44, 45, FlxAssets.imgButtonLeft)));
				dPad.add(add(buttonRight = createButton(69, FlxG.height - 81, 44, 45, FlxAssets.imgButtonRight)));	
				dPad.add(add(buttonDown = createButton(35, FlxG.height - 45, 44, 45, FlxAssets.imgButtonDown)));
			case UP_DOWN:
				dPad.add(add(buttonUp = createButton(0, FlxG.height - 85, 44, 45, FlxAssets.imgButtonUp)));
				dPad.add(add(buttonDown = createButton(0, FlxG.height - 45, 44, 45, FlxAssets.imgButtonDown)));
			case LEFT_RIGHT:
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 45, 44, 45, FlxAssets.imgButtonLeft)));
				dPad.add(add(buttonRight = createButton(42, FlxG.height - 45, 44, 45, FlxAssets.imgButtonRight)));
			case UP_LEFT_RIGHT:
				dPad.add(add(buttonUp = createButton(35, FlxG.height - 81, 44, 45, FlxAssets.imgButtonUp)));
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 45, 44, 45, FlxAssets.imgButtonLeft)));
				dPad.add(add(buttonRight = createButton(69, FlxG.height - 45, 44, 45, FlxAssets.imgButtonRight)));
		}
		
		switch (Action)
		{
			case FULL:
				actions.add(add(buttonY = createButton(FlxG.width - 86, FlxG.height - 85, 44, 45, FlxAssets.imgButtonY)));	
				actions.add(add(buttonX = createButton(FlxG.width - 44, FlxG.height - 85, 44, 45, FlxAssets.imgButtonX)));		
				actions.add(add(buttonB = createButton(FlxG.width - 86, FlxG.height - 45, 44, 45, FlxAssets.imgButtonB)));		
				actions.add(add(buttonA = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, FlxAssets.imgButtonA)));
			case A:
				actions.add(add(buttonA = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, FlxAssets.imgButtonA)));
			case A_B:
				actions.add(add(buttonA = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, FlxAssets.imgButtonA)));
				actions.add(add(buttonB = createButton(FlxG.width - 86, FlxG.height - 45, 44, 45, FlxAssets.imgButtonB)));		
			case A_B_C:
				actions.add(add(buttonA = createButton(FlxG.width - 128, FlxG.height - 45, 44, 45, FlxAssets.imgButtonA)));				
				actions.add(add(buttonB = createButton(FlxG.width - 86, FlxG.height - 45, 44, 45, FlxAssets.imgButtonB)));		
				actions.add(add(buttonC = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, FlxAssets.imgButtonC)));
		}
		
		alpha = 1.0;
	}
	
	override public function destroy():Void
	{		
		super.destroy();
		if(dPad != null)
		{
			dPad.destroy();
		}
		if(actions != null)
		{
			actions.destroy();
		}
		dPad = actions = null;
		buttonA = buttonB = buttonC = buttonY = buttonX = null;
		buttonLeft = buttonUp = buttonDown = buttonRight = null;
	}
	
	/**
	 * Creates a button
	 * @param X			The x-position of the button.
	 * @param Y			The y-position of the button.
	 * @param Width		The width of the button.
	 * @param Height	The height of the button.
	 * @param Image		The image of the button. It must contains 3 frames (NORMAL, HIGHLIGHT, PRESSED).
	 * @param Callback	The callback for the button.
	 * @return			The button.
	 */
	public function createButton(X:Float, Y:Float, Width:Int, Height:Int, Image:String, OnClick:Void->Void = null):FlxButton
	{
		var button:FlxButton = new FlxButton(X, Y);
		button.loadGraphic(Image, true, false, Width, Height);
		button.solid = false;
		button.immovable = true;
		button.scrollFactor.x = button.scrollFactor.y = 0;

		#if !FLX_NO_DEBUG
		button.ignoreDrawDebug = true;
		#end
		
		if (OnClick != null)
		{
			button.onDown = OnClick;
		}
		return button;
	}	
	
	public var alpha(default, set_alpha):Float;
	
	/**
	 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of the gamepad.
	 * @param Alpha
	 */
	private function set_alpha(Alpha:Float):Float
	{
		alpha = Alpha;
		for (i in 0...members.length)
		{
			members[i].alpha = Alpha;
		}
		return Alpha;
	}
}
