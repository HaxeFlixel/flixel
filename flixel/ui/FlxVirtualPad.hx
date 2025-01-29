package flixel.ui;

import flixel.ui.FlxAnalog;
import flixel.FlxG;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxSpriteContainer;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;

/**
 * A gamepad which contains 4 directional buttons and 4 action buttons.
 * It's easy to set the callbacks and to customize the layout.
 *
 * @author Ka Wing Chin
 */
class FlxVirtualPad extends FlxSpriteContainer
{
	/**
	 * Group of directions buttons.
	 */
	public final dPad:Null<FlxVirtualDPadButtons>;
	
	/**
	 * Group of action buttons.
	 */
	public final actions:FlxVirtualActionButtons;
	
	/**
	 * An Analog directional input
	 */
	public final stick:Null<FlxVirtualStick>;
	
	@:deprecated("buttonA is deprecated, use getButton(A), instead")
	public var buttonA(get, never):Null<FlxVirtualPadButton>;
	inline function get_buttonA() return actions.getButton(A);
	
	@:deprecated("buttonB is deprecated, use getButton(B), instead")
	public var buttonB(get, never):Null<FlxVirtualPadButton>;
	inline function get_buttonB() return actions.getButton(B);
	
	@:deprecated("buttonC is deprecated, use getButton(C), instead")
	public var buttonC(get, never):Null<FlxVirtualPadButton>;
	inline function get_buttonC() return actions.getButton(C);
	
	@:deprecated("buttonY is deprecated, use getButton(Y), instead")
	public var buttonY(get, never):Null<FlxVirtualPadButton>;
	inline function get_buttonY() return actions.getButton(Y);
	
	@:deprecated("buttonX is deprecated, use getButton(X), instead")
	public var buttonX(get, never):Null<FlxVirtualPadButton>;
	inline function get_buttonX() return actions.getButton(X);
	
	@:deprecated("buttonLeft is deprecated, use getButton(LEFT), instead")
	public var buttonLeft(get, never):Null<FlxVirtualPadButton>;
	inline function get_buttonLeft() return dPad.getButton(LEFT);
	
	@:deprecated("buttonUp is deprecated, use getButton(UP), instead")
	public var buttonUp(get, never):Null<FlxVirtualPadButton>;
	inline function get_buttonUp() return dPad.getButton(UP);
	
	@:deprecated("buttonRight is deprecated, use getButton(RIGHT), instead")
	public var buttonRight(get, never):Null<FlxVirtualPadButton>;
	inline function get_buttonRight() return dPad.getButton(RIGHT);
	
	@:deprecated("buttonDown is deprecated, use getButton(DOWN), instead")
	public var buttonDown(get, never):Null<FlxVirtualPadButton>;
	inline function get_buttonDown() return dPad.getButton(DOWN);
	
	/**
	 * Create a gamepad which contains 4 directional buttons and 4 action buttons.
	 *
	 * @param   DPadMode     The D-Pad mode. `FULL` for example.
	 * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	 */
	public function new(dPadMode = FlxDPadMode.FULL, actionMode = FlxActionMode.A_B_C)
	{
		super();
		scrollFactor.set();
		
		add(actions = new FlxVirtualActionButtons(0, 0, actionMode));
		actions.x = FlxG.width - actions.width;
		
		switch dPadMode
		{
			case ANALOG:
				add(stick = new FlxVirtualStick());
				stick.y = height - stick.height;
			default:
				add(dPad = new FlxVirtualDPadButtons(0, 0, dPadMode));
				dPad.y = height - dPad.height;
		}
		actions.y = height - actions.height;
		
		y = FlxG.height - height;
		
		#if FLX_DEBUG
		this.ignoreDrawDebug = true;
		#end
	}
	
	public function getButton(id:FlxVirtualInputID)
	{
		return switch id
		{
			case A | B | C | X | Y: actions.getButton(id);
			case UP | DOWN | LEFT | RIGHT if (dPad == null): null;
			case UP | DOWN | LEFT | RIGHT: dPad.getButton(id);
			case STICK: null;
		}
	}
}

class FlxVirtualPadButtons extends FlxTypedSpriteContainer<FlxVirtualPadButton>
{
	final buttons = new Map<FlxVirtualInputID, FlxVirtualPadButton>();
	
	public function new (x = 0.0, y = 0.0)
	{
		super(x, y);
		scrollFactor.set();
		
		#if FLX_DEBUG
		this.ignoreDrawDebug = true;
		#end
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		buttons.clear();
	}
	
	public function addButton(x = 0.0, y = 0.0, id, ?onClick)
	{
		return buttons[id] = add(new FlxVirtualPadButton(x, y, id, onClick));
	}
	
	public function getButton(id)
	{
		return buttons[id];
	}
}

class FlxVirtualDPadButtons extends FlxVirtualPadButtons
{
	public function new (x = 0.0, y = 0.0, mode:FlxDPadMode)
	{
		super(x, y);
		switch (mode)
		{
			case UP_DOWN:
				addButton( 0,  0, UP   );
				addButton( 0, 40, DOWN );
			case LEFT_RIGHT:
				addButton( 0,  0, LEFT );
				addButton(42,  0, RIGHT);
			case UP_LEFT_RIGHT:
				addButton(35,  0, UP   );
				addButton( 0, 36, LEFT );
				addButton(69, 36, RIGHT);
			case FULL:
				addButton(35,  0, UP   );
				addButton( 0, 35, LEFT );
				addButton(69, 35, RIGHT);
				addButton(35, 71, DOWN );
			case ANALOG: throw "Unexpected mode: ANALOG";
			case NONE: // do nothing
		}
	}
}

class FlxVirtualActionButtons extends FlxVirtualPadButtons
{
	public function new (x = 0.0, y = 0.0, mode:FlxActionMode)
	{
		super(x, y);
		switch (mode)
		{
			case A:
				addButton( 0,  0, A);
			case A_B:
				addButton(42,  0, A);
				addButton( 0,  0, B);
			case A_B_C:
				addButton( 0,  0, A);
				addButton(42,  0, B);
				addButton(84,  0, C);
			case A_B_X_Y:
				addButton( 0,  0, Y);
				addButton(42,  0, X);
				addButton( 0, 40, B);
				addButton(42, 40, A);
			case NONE: // do nothing
		}
	}
}

@:forward
abstract FlxVirtualPadButton(FlxButton) to FlxButton
{
	public function new(x = 0.0, y = 0.0, id:FlxVirtualInputID, ?onClick)
	{
		this = new FlxButton(x, y, null, onClick);
		this.frames = id.getFrames();
		this.resetSizeFromFrame();
		this.moves = true;

		#if FLX_DEBUG
		this.ignoreDrawDebug = true;
		#end
	}
}

enum FlxDPadMode
{
	NONE;
	UP_DOWN;
	LEFT_RIGHT;
	UP_LEFT_RIGHT;
	FULL;
	ANALOG;
}

enum FlxActionMode
{
	NONE;
	A;
	A_B;
	A_B_C;
	A_B_X_Y;
}

@:using(flixel.ui.FlxVirtualPad.FlxVirtualInputIDTools)
enum FlxVirtualInputID
{
    UP;
    DOWN;
    LEFT;
    RIGHT;
    A;
    B;
    C;
    X;
    Y;
    STICK;
}

private class FlxVirtualInputIDTools
{
	public static function getFrames(id:FlxVirtualInputID)
	{
		final name = switch id
		{
			case UP: "up";
			case DOWN: "down";
			case LEFT: "left";
			case RIGHT: "right";
			case A: "a";
			case B: "b";
			case C: "c";
			case X: "x";
			case Y: "y";
			case STICK: "stick";
		}
		
		final frame = FlxAssets.getVirtualInputFrames().getByName(name);
		return FlxTileFrames.fromFrame(frame, FlxPoint.get(44, 45));
	}
}