package flixel.plugin.photonstorm;

#if !FLX_NO_MOUSE
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.util.FlxPoint;
import flixel.util.FlxRect;
import flixel.util.FlxMath;

/**
 * FlxMouseControl
 * 
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/
class FlxMouseControl extends FlxBasic
{
	/**
	 * Use with <code>sort()</code> to sort in ascending order.
	 */
	inline static public var ASCENDING:Int = -1;
	/**
	 * Use with <code>sort()</code> to sort in descending order.
	 */
	inline static public var DESCENDING:Int = 1;
	/**
	 * The value that the FlxExtendedSprites are sorted by before deciding which is "on-top" for click select
	 */
	static public var sortIndex:String = "y";
	/**
	 * The sorting order. If the sortIndex is "y" and the order is ASCENDING then a sprite with a Y value of 200 would be "on-top" of one with a Y value of 100.
	 */
	static public var sortOrder:Int = ASCENDING;
	/**
	 * Is the mouse currently dragging a sprite? If you have just clicked but NOT yet moved the mouse then this might return false.
	 */
	static public var isDragging:Bool = false;
	/**
	 * The FlxExtendedSprite that is currently being dragged, if any.
	 */
	static public var dragTarget:FlxExtendedSprite;
	static public var clickTarget:FlxExtendedSprite;
	/**
	 * The speed the mouse is moving on the X axis in pixels per frame
	 */
	static public var speedX:Int;
	/**
	 * The speed the mouse is moving on the Y axis in pixels per frame
	 */
	static public var speedY:Int;
	/**
	 * The mouse can be set to only be active within a specific FlxRect region of the game world.
	 * If outside this FlxRect no clicks, drags or throws will be processed.
	 * If the mouse leaves this region while still dragging then the sprite is automatically dropped and its release handler is called.
	 * Set the FlxRect to null to disable the zone.
	 */
	static public var mouseZone:FlxRect;
	/**
	 * Instead of using a mouseZone (which is calculated in world coordinates) you can limit the mouse to the FlxG.camera.deadzone area instead.
	 * If set to true the mouse will use the camera deadzone. If false (or the deadzone is null) no check will take place.
	 * Note that this takes priority over the mouseZone above. If the mouseZone and deadzone are set, the deadzone is used.
	 */
	static public var linkToDeadZone:Bool = false;
	
	/**
	 * The FlxExtendedSprite that currently has the mouse button pressed on it
	 */
	static private var _clickStack:Array<FlxExtendedSprite> = new Array<FlxExtendedSprite>();
	static private var _clickCoords:FlxPoint;
	static private var _hasClickTarget:Bool = false;
	
	static private var _oldX:Int = 0;
	static private var _oldY:Int = 0;
	
	/**
	 * Adds the given FlxExtendedSprite to the stack of potential sprites that were clicked, the stack is then sorted and the final sprite is selected from that
	 * 
	 * @param	Item	The FlxExtendedSprite that was clicked by the mouse
	 */
	static public function addToStack(Item:FlxExtendedSprite):Void
	{
		if (mouseZone != null)
		{
			if (FlxMath.pointInFlxRect(Math.floor(FlxG.mouse.x), Math.floor(FlxG.mouse.y), mouseZone) == true)
			{
				_clickStack.push(Item);
			}
		}
		else
		{
			_clickStack.push(Item);
		}
	}
	
	/**
	 * Main Update Loop - checks mouse status and updates FlxExtendedSprites accordingly
	 */
	override public function update():Void
	{
		// Update mouse speed
		speedX = FlxG.mouse.screenX - _oldX;
		speedY = FlxG.mouse.screenY - _oldY;
		
		_oldX = FlxG.mouse.screenX;
		_oldY = FlxG.mouse.screenY;
		
		// Is the mouse currently pressed down on a target?
		if (_hasClickTarget)
		{
			if (FlxG.mouse.pressed())
			{
				// Has the mouse moved? If so then we're candidate for a drag
				if (isDragging == false && clickTarget.draggable == true && (_clickCoords.x != FlxG.mouse.x || _clickCoords.y != FlxG.mouse.y))
				{
					// Drag on
					isDragging = true;
					
					dragTarget = clickTarget;
					
					dragTarget.startDrag();
				}
			}
			else
			{
				releaseMouse();
			}
			
			if (linkToDeadZone == true)
			{
				if (FlxMath.mouseInFlxRect(false, FlxG.camera.deadzone) == false)
				{
					releaseMouse();
				}
			}
			else if (FlxMath.mouseInFlxRect(true, mouseZone) == false)
			{
				// Is a mouse zone enabled? In which case check if we're still in it
				releaseMouse();
			}
		}
		else
		{
			// If you are wondering how the brand new array can have anything in it by now, it's because FlxExtendedSprite
			// adds itself to the clickStack
			if (FlxG.mouse.pressed() && _clickStack.length > 0)
			{
				assignClickedSprite();
			}
		}
	}
	
	/**
	 * Internal function used to release the click / drag targets and reset the mouse state
	 */
	private function releaseMouse():Void
	{
		//	Mouse is no longer down, so tell the click target it's free - this will also stop dragging if happening
		clickTarget.mouseReleasedHandler();
		
		_hasClickTarget = false;
		clickTarget = null;
		
		isDragging = false;
		dragTarget = null;
	}
	
	/**
	 * Once the clickStack is created this sorts it and then picks the sprite with the highest priority (based on sortIndex and sortOrder)
	 */
	private function assignClickedSprite():Void
	{
		//	If there is more than one potential target then sort them
		if (_clickStack.length > 1)
		{
			_clickStack.sort(sortHandler);
		}
		
		clickTarget = _clickStack.pop();
		
		_clickCoords = clickTarget.point;
		
		_hasClickTarget = true;
		
		clickTarget.mousePressedHandler();
		
		_clickStack = [];
	}
	
	/**
	 * Helper function for the sort process.
	 * 
	 * @param 	Item1	The first object being sorted.
	 * @param	Item2	The second object being sorted.
	 * 
	 * @return	An integer value: -1 (item1 before item2), 0 (same), or 1 (item1 after item2)
	 */
	private function sortHandler(Item1:FlxExtendedSprite, Item2:FlxExtendedSprite):Int
	{
		var prop1 = Reflect.getProperty(Item1, sortIndex);
		var prop2 = Reflect.getProperty(Item2, sortIndex);
		
		if (prop1 < prop2)
		{
			return sortOrder;
		}
		else if (prop1 > prop2)
		{
			return - sortOrder;
		}
		
		return 0;
	}
	
	/**
	 * Removes all references to any click / drag targets and resets this class
	 */
	public static function clear():Void
	{
		_hasClickTarget = false;
		
		if (clickTarget != null)
		{
			clickTarget.mouseReleasedHandler();
		}
		
		clickTarget = null;
		
		isDragging = false;
		
		if (dragTarget != null)
		{
			dragTarget.stopDrag();
		}
		
		speedX = 0;
		speedY = 0;
		dragTarget = null;
		mouseZone = null;
		linkToDeadZone = false;
	}
	
	/**
	 * Runs when this plugin is destroyed
	 */
	override public function destroy():Void
	{
		clear();
	}
}
#end