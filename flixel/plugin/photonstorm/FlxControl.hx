package flixel.plugin.photonstorm;

import flixel.FlxBasic;
import flixel.FlxSprite;
import haxe.ds.ObjectMap;

/**
* FlxControl
*
* @link http://www.photonstorm.com
* @author Richard Davey / Photon Storm
*/
class FlxControl extends FlxBasic
{
	//	Quick references
	static public var player1:FlxControlHandler;
	static public var player2:FlxControlHandler;
	static public var player3:FlxControlHandler;
	static public var player4:FlxControlHandler;
	
	//	Additional control handlers
	static private var _members:ObjectMap<FlxControlHandler, FlxControlHandler> = new ObjectMap<FlxControlHandler, FlxControlHandler>();
	
	/**
	 * Creates a new FlxControlHandler. You can have as many FlxControlHandlers as you like, but you usually only have one per player. The first handler you make
	 * will be assigned to the FlxControl.player1 var. The 2nd to FlxControl.player2 and so on for player3 and player4. Beyond this you need to keep a reference to the
	 * handler yourself.
	 * 
	 * @param	Sprite			The FlxSprite you want this class to control. It can only control one FlxSprite at once.
	 * @param	MovementType	Set to either MOVEMENT_INSTANT or MOVEMENT_ACCELERATES
	 * @param	StoppingType	Set to STOPPING_INSTANT, STOPPING_DECELERATES or STOPPING_NEVER
	 * @param	UpdateFacing	If true it sets the FlxSprite.facing value to the direction pressed (default false)
	 * @param	EnableArrowKeys	If true it will enable all arrow keys (default) - see setCursorControl for more fine-grained control
	 * @return	The new FlxControlHandler
	 */
	static public function create(Sprite:FlxSprite, MovementType:Int, StoppingType:Int, Player:Int = 1, UpdateFacing:Bool = false, EnableArrowKeys:Bool = true):FlxControlHandler
	{
		var result:FlxControlHandler;
		
		if (Player == 1)
		{
			player1 = new FlxControlHandler(Sprite, MovementType, StoppingType, UpdateFacing, EnableArrowKeys);
			_members.set(player1, player1);
			result = player1;
		}
		else if (Player == 2)
		{
			player2 = new FlxControlHandler(Sprite, MovementType, StoppingType, UpdateFacing, EnableArrowKeys);
			_members.set(player2, player2);
			result = player2;
		}
		else if (Player == 3)
		{
			player3 = new FlxControlHandler(Sprite, MovementType, StoppingType, UpdateFacing, EnableArrowKeys);
			_members.set(player3, player3);
			result = player3;
		}
		else if (Player == 4)
		{
			player4 = new FlxControlHandler(Sprite, MovementType, StoppingType, UpdateFacing, EnableArrowKeys);
			_members.set(player4, player4);
			result = player4;
		}
		else
		{
			var newControlHandler:FlxControlHandler = new FlxControlHandler(Sprite, MovementType, StoppingType, UpdateFacing, EnableArrowKeys);
			_members.set(newControlHandler, newControlHandler);
			result = newControlHandler;
		}
		
		return result;
	}
	
	/**
	 * Removes a <code>FlxControlHandler</code> 
	 * 
	 * @param	ControlHandler	The <code>FlxControlHandler</code> to delete
	 * @return	Boolean	true if the <code>FlxControlHandler</code> was removed, otherwise false.
	 */
	static public function remove(ControlHandler:FlxControlHandler):Bool
	{
		if (_members.exists(ControlHandler))
		{
			_members.remove(ControlHandler);
			return true;
		}
		
		return false;
	}
	
	/**
	 * Removes all FlxControlHandlers.
	 * This is called automatically if this plugin is ever destroyed.
	 */
	static public function clear():Void
	{
		for (handler in _members)
		{
			_members.remove(handler);
		}
	}
	
	/**
	 * Starts updating the given FlxControlHandler, enabling keyboard actions for it. If no FlxControlHandler is given it starts updating all FlxControlHandlers currently added.
	 * Updating is enabled by default, but this can be used to re-start it if you have stopped it via <code>stop()</code>.
	 * 
	 * @param	ControlHandler	The <code>FlxControlHandler</code> to start updating on. If left as null it will start updating all handlers.
	 */
	static public function start(?ControlHandler:FlxControlHandler):Void
	{
		if (ControlHandler != null)
		{
			_members.get(ControlHandler).enabled = true;
		}
		else
		{
			for (handler in _members)
			{
				handler.enabled = true;
			}
		}
	}
	
	/**
	 * Stops updating the given FlxControlHandler. If no FlxControlHandler is given it stops updating all FlxControlHandlers currently added.
	 * Updating is enabled by default, but this can be used to stop it, for example if you paused your game (see start() to restart it again).
	 * 
	 * @param	ControlHandler	The FlxControlHandler to stop updating. If left as null it will stop updating all handlers.
	 */
	static public function stop(?ControlHandler:FlxControlHandler):Void
	{
		if (ControlHandler != null)
		{
			_members.get(ControlHandler).enabled = false;
		}
		else
		{
			for (handler in _members)
			{
				handler.enabled = false;
			}
		}
	}
	
	/**
	 * Runs update on all currently active FlxControlHandlers
	 */
	override public function update():Void
	{
		for (handler in _members)
		{
			if (handler.enabled == true)
			{
				handler.update();
			}
		}
	}
	
	/**
	 * Runs when this plugin is destroyed
	 */
	override public function destroy():Void
	{
		clear();
	}
}