/**
 * FlxControl
 * -- Part of the Flixel Power Tools set
 * 
 * v1.1 Fixed and added documentation
 * v1.0 First release
 * 
 * @version 1.1 - July 21st 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm 
{
	import flash.utils.Dictionary;
	import org.flixel.*;

	public class FlxControl extends FlxBasic
	{
		//	Quick references
		public static var player1:FlxControlHandler;
		public static var player2:FlxControlHandler;
		public static var player3:FlxControlHandler;
		public static var player4:FlxControlHandler;
		
		//	Additional control handlers
		private static var members:Dictionary = new Dictionary(true);
		
		public function FlxControl() 
		{
		}
		
		/**
		 * Creates a new FlxControlHandler. You can have as many FlxControlHandlers as you like, but you usually only have one per player. The first handler you make
		 * will be assigned to the FlxControl.player1 var. The 2nd to FlxControl.player2 and so on for player3 and player4. Beyond this you need to keep a reference to the
		 * handler yourself.
		 * 
		 * @param	source			The FlxSprite you want this class to control. It can only control one FlxSprite at once.
		 * @param	movementType	Set to either MOVEMENT_INSTANT or MOVEMENT_ACCELERATES
		 * @param	stoppingType	Set to STOPPING_INSTANT, STOPPING_DECELERATES or STOPPING_NEVER
		 * @param	updateFacing	If true it sets the FlxSprite.facing value to the direction pressed (default false)
		 * @param	enableArrowKeys	If true it will enable all arrow keys (default) - see setCursorControl for more fine-grained control
		 * 
		 * @return	The new FlxControlHandler
		 */
		public static function create(source:FlxSprite, movementType:int, stoppingType:int, player:int = 1, updateFacing:Boolean = false, enableArrowKeys:Boolean = true):FlxControlHandler
		{
			var result:FlxControlHandler;
			
			if (player == 1)
			{
				player1 = new FlxControlHandler(source, movementType, stoppingType, updateFacing, enableArrowKeys);
				members[player1] = player1;
				result = player1;
			}
			else if (player == 2)
			{
				player2 = new FlxControlHandler(source, movementType, stoppingType, updateFacing, enableArrowKeys);
				members[player2] = player2;
				result = player2;
			}
			else if (player == 3)
			{
				player3 = new FlxControlHandler(source, movementType, stoppingType, updateFacing, enableArrowKeys);
				members[player3] = player3;
				result = player3;
			}
			else if (player == 4)
			{
				player4 = new FlxControlHandler(source, movementType, stoppingType, updateFacing, enableArrowKeys);
				members[player4] = player4;
				result = player4;
			}
			else
			{
				var newControlHandler:FlxControlHandler = new FlxControlHandler(source, movementType, stoppingType, updateFacing, enableArrowKeys);
				members[newControlHandler] = newControlHandler;
				result = newControlHandler;
			}
			
			return result;
		}
		
		/**
		 * Removes an FlxControlHandler 
		 * 
		 * @param	source	The FlxControlHandler to delete
		 * @return	Boolean	true if the FlxControlHandler was removed, otherwise false.
		 */
		public static function remove(source:FlxControlHandler):Boolean
		{
			if (members[source])
			{
				delete members[source];
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Removes all FlxControlHandlers.<br />
		 * This is called automatically if this plugin is ever destroyed.
		 */
		public static function clear():void
		{
			for each (var handler:FlxControlHandler in members)
			{
				delete members[handler];
			}
		}
		
		/**
		 * Starts updating the given FlxControlHandler, enabling keyboard actions for it. If no FlxControlHandler is given it starts updating all FlxControlHandlers currently added.<br />
		 * Updating is enabled by default, but this can be used to re-start it if you have stopped it via stop().<br />
		 * 
		 * @param	source	The FlxControlHandler to start updating on. If left as null it will start updating all handlers.
		 */
		public static function start(source:FlxControlHandler = null):void
		{
			if (source)
			{
				members[source].enabled = true;
			}
			else
			{
				for each (var handler:FlxControlHandler in members)
				{
					handler.enabled = true;
				}
			}
		}
		
		/**
		 * Stops updating the given FlxControlHandler. If no FlxControlHandler is given it stops updating all FlxControlHandlers currently added.<br />
		 * Updating is enabled by default, but this can be used to stop it, for example if you paused your game (see start() to restart it again).<br />
		 * 
		 * @param	source	The FlxControlHandler to stop updating. If left as null it will stop updating all handlers.
		 */
		public static function stop(source:FlxControlHandler = null):void
		{
			if (source)
			{
				members[source].enabled = false;
			}
			else
			{
				for each (var handler:FlxControlHandler in members)
				{
					handler.enabled = false;
				}
			}
		}
		
		/**
		 * Runs update on all currently active FlxControlHandlers
		 */
		override public function draw():void
		{
			for each (var handler:FlxControlHandler in members)
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
		override public function destroy():void
		{
			clear();
		}
		
	}

}