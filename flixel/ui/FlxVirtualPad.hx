package flixel.ui;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets;

@:bitmap("assets/images/ui/virtualpad/a.png")     private class GraphicA     extends BitmapData {}
@:bitmap("assets/images/ui/virtualpad/b.png")     private class GraphicB     extends BitmapData {}
@:bitmap("assets/images/ui/virtualpad/c.png")     private class GraphicC     extends BitmapData {}
@:bitmap("assets/images/ui/virtualpad/down.png")  private class GraphicDown  extends BitmapData {}
@:bitmap("assets/images/ui/virtualpad/left.png")  private class GraphicLeft  extends BitmapData {}
@:bitmap("assets/images/ui/virtualpad/right.png") private class GraphicRight extends BitmapData {}
@:bitmap("assets/images/ui/virtualpad/up.png")    private class GraphicUp    extends BitmapData {}
@:bitmap("assets/images/ui/virtualpad/x.png")     private class GraphicX     extends BitmapData {}
@:bitmap("assets/images/ui/virtualpad/y.png")     private class GraphicY     extends BitmapData {}

/**
 * A gamepad which contains 4 directional buttons and 4 action buttons.
 * It's easy to set the callbacks and to customize the layout.
 * 
 * @author Ka Wing Chin
 */
class FlxVirtualPad extends FlxSpriteGroup
{	
	public var buttonA:FlxButton;
	public var buttonB:FlxButton;
	public var buttonC:FlxButton;
	public var buttonY:FlxButton;
	public var buttonX:FlxButton;
	public var buttonLeft:FlxButton;
	public var buttonUp:FlxButton;
	public var buttonRight:FlxButton;
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
				dPad.add(add(buttonUp = createButton(0, FlxG.height - 85, 44, 45, GraphicUp)));
				dPad.add(add(buttonDown = createButton(0, FlxG.height - 45, 44, 45, GraphicDown)));
			case LEFT_RIGHT:
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 45, 44, 45, GraphicLeft)));
				dPad.add(add(buttonRight = createButton(42, FlxG.height - 45, 44, 45, GraphicRight)));
			case UP_LEFT_RIGHT:
				dPad.add(add(buttonUp = createButton(35, FlxG.height - 81, 44, 45, GraphicUp)));
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 45, 44, 45, GraphicDown)));
				dPad.add(add(buttonRight = createButton(69, FlxG.height - 45, 44, 45, GraphicRight)));
			case FULL:
				dPad.add(add(buttonUp = createButton(35, FlxG.height - 116, 44, 45, GraphicUp)));	
				dPad.add(add(buttonLeft = createButton(0, FlxG.height - 81, 44, 45, GraphicLeft)));
				dPad.add(add(buttonRight = createButton(69, FlxG.height - 81, 44, 45, GraphicRight)));	
				dPad.add(add(buttonDown = createButton(35, FlxG.height - 45, 44, 45, GraphicDown)));
			case NONE: // do nothing
		}
		
		switch (Action)
		{
			case A:
				actions.add(add(buttonA = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, GraphicA)));
			case A_B:
				actions.add(add(buttonA = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, GraphicA)));
				actions.add(add(buttonB = createButton(FlxG.width - 86, FlxG.height - 45, 44, 45, GraphicB)));
			case A_B_C:
				actions.add(add(buttonA = createButton(FlxG.width - 128, FlxG.height - 45, 44, 45, GraphicA)));
				actions.add(add(buttonB = createButton(FlxG.width - 86, FlxG.height - 45, 44, 45, GraphicB)));
				actions.add(add(buttonC = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, GraphicC)));
			case A_B_X_Y:
				actions.add(add(buttonY = createButton(FlxG.width - 86, FlxG.height - 85, 44, 45, GraphicY)));
				actions.add(add(buttonX = createButton(FlxG.width - 44, FlxG.height - 85, 44, 45, GraphicX)));
				actions.add(add(buttonB = createButton(FlxG.width - 86, FlxG.height - 45, 44, 45, GraphicB)));
				actions.add(add(buttonA = createButton(FlxG.width - 44, FlxG.height - 45, 44, 45, GraphicA)));
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
	 * @param 	X			The x-position of the button.
	 * @param 	Y			The y-position of the button.
	 * @param 	Width		The width of the button.
	 * @param 	Height		The height of the button.
	 * @param 	Image		The image of the button. It must contains 3 frames (NORMAL, HIGHLIGHT, PRESSED).
	 * @param 	Callback	The callback for the button.
	 * @return	The button
	 */
	public function createButton(X:Float, Y:Float, Width:Int, Height:Int, Image:Dynamic, ?OnClick:Void->Void):FlxButton
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