/**
 * FlxButtonPlus
 * -- Part of the Flixel Power Tools set
 * 
 * v1.4 Added scrollFactor to button and swapped to using mouseInFlxRect so buttons in scrolling worlds work
 * v1.3 Updated gradient colour values to include alpha
 * v1.2 Updated for the Flixel 2.5 Plugin system
 * 
 * @version 1.4 - July 28th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm
{
	import flash.events.MouseEvent;
	
	import org.flixel.*;
	
	/**
	 * A simple button class that calls a function when clicked by the mouse.
	 */
	public class FlxButtonPlus extends FlxGroup
	{
		static public var NORMAL:uint = 0;
		static public var HIGHLIGHT:uint = 1;
		static public var PRESSED:uint = 2;
		
		/**
		 * Set this to true if you want this button to function even while the game is paused.
		 */
		public var pauseProof:Boolean;
		/**
		 * Shows the current state of the button.
		 */
		protected var _status:uint;
		/**
		 * This function is called when the button is clicked.
		 */
		protected var _onClick:Function;
		/**
		 * Tracks whether or not the button is currently pressed.
		 */
		protected var _pressed:Boolean;
		/**
		 * Whether or not the button has initialized itself yet.
		 */
		protected var _initialized:Boolean;
		
		
		
		//	Flixel Power Tools Modification from here down
		
		public var buttonNormal:FlxExtendedSprite;
		public var buttonHighlight:FlxExtendedSprite;
		
		public var textNormal:FlxText;
		public var textHighlight:FlxText;
		
		/**
		 * The parameters passed to the _onClick function when the button is clicked
		 */
		private var onClickParams:Array;
		
		/**
		 * This function is called when the button is hovered over
		 */
		private var enterCallback:Function;
		
		/**
		 * The parameters passed to the enterCallback function when the button is hovered over
		 */
		private var enterCallbackParams:Array;
		
		/**
		 * This function is called when the mouse leaves a hovered button (but didn't click)
		 */
		private var leaveCallback:Function;
		
		/**
		 * The parameters passed to the leaveCallback function when the hovered button is left
		 */
		private var leaveCallbackParams:Array;
		
		/**
		 * The 1px thick border color that is drawn around this button
		 */
		public var borderColor:uint = 0xffffffff;
		
		/**
		 * The color gradient of the button in its in-active (not hovered over) state
		 */
		public var offColor:Array = [0xff008000, 0xff00FF00];
		
		/**
		 * The color gradient of the button in its hovered state
		 */
		public var onColor:Array = [0xff800000, 0xffff0000];
		
		private var _x:int;
		private var _y:int;
		public var width:int;
		public var height:int;
		
		/**
		 * Creates a new <code>FlxButton</code> object with a gray background
		 * and a callback function on the UI thread.
		 * 
		 * @param	X			The X position of the button.
		 * @param	Y			The Y position of the button.
		 * @param	Callback	The function to call whenever the button is clicked.
		 * @param	Params		An optional array of parameters that will be passed to the Callback function
		 * @param	Label		Text to display on the button
		 * @param	Width		The width of the button.
		 * @param	Height		The height of the button.
		 */
		public function FlxButtonPlus(X:int, Y:int, Callback:Function, Params:Array = null, Label:String = null, Width:int = 100, Height:int = 20):void
		{
			super(4);
			
			_x = X;
			_y = Y;
			width = Width;
			height = Height;
			_onClick = Callback;
			
			buttonNormal = new FlxExtendedSprite(X, Y);
			buttonNormal.makeGraphic(Width, Height, borderColor);
			buttonNormal.stamp(FlxGradient.createGradientFlxSprite(Width - 2, Height - 2, offColor), 1, 1);
			buttonNormal.solid = false;
			buttonNormal.scrollFactor.x = 0;
			buttonNormal.scrollFactor.y = 0;
			
			buttonHighlight = new FlxExtendedSprite(X, Y);
			buttonHighlight.makeGraphic(Width, Height, borderColor);
			buttonHighlight.stamp(FlxGradient.createGradientFlxSprite(Width - 2, Height - 2, onColor), 1, 1);
			buttonHighlight.solid = false;
			buttonHighlight.visible = false;
			buttonHighlight.scrollFactor.x = 0;
			buttonHighlight.scrollFactor.y = 0;
			
			
			add(buttonNormal);
			add(buttonHighlight);
			
			if (Label != null)
			{
				textNormal = new FlxText(X, Y + 3, Width, Label);
				textNormal.setFormat(null, 8, 0xffffffff, "center", 0xff000000);
				
				textHighlight = new FlxText(X, Y + 3, Width, Label);
				textHighlight.setFormat(null, 8, 0xffffffff, "center", 0xff000000);
				
				add(textNormal);
				add(textHighlight);
			}

			_status = NORMAL;
			_pressed = false;
			_initialized = false;
			pauseProof = false;
			
			if (Params)
			{
				onClickParams = Params;
			}
		}
		
		public function set x(newX:int):void
		{
			_x = newX;
			
			buttonNormal.x = _x;
			buttonHighlight.x = _x;
			
			if (textNormal)
			{
				textNormal.x = _x;
				textHighlight.x = _x;
			}
		}
		
		public function get x():int
		{
			return _x;
		}
		
		public function set y(newY:int):void
		{
			_y = newY;
			
			buttonNormal.y = _y;
			buttonHighlight.y = _y;
			
			if (textNormal)
			{
				textNormal.y = _y;
				textHighlight.y = _y;
			}
		}
		
		public function get y():int
		{
			return _y;
		}
		
		override public function preUpdate():void
		{
			super.preUpdate();
			
			if (!_initialized)
			{
				if(FlxG.stage != null)
				{
					FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					_initialized = true;
				}
			}
		}
		
		/**
		 * If you wish to replace the two buttons (normal and hovered-over) with FlxSprites, then pass them here.<br />
		 * Note: The pixel data is extract from the passed FlxSprites and assigned locally, it doesn't actually use the sprites<br />
		 * or keep a reference to them.
		 * 
		 * @param	normal		The FlxSprite to use when the button is in-active (not hovered over)
		 * @param	highlight	The FlxSprite to use when the button is hovered-over by the mouse
		 */
		public function loadGraphic(normal:FlxSprite, highlight:FlxSprite):void
		{
			buttonNormal.pixels = normal.pixels;
			buttonHighlight.pixels = highlight.pixels;
			
			width = buttonNormal.width;
			height = buttonNormal.height;

			if (_pressed)
			{
				buttonNormal.visible = false;
			}
			else
			{
				buttonHighlight.visible = false;
			}
		}
		
		/**
		 * Called by the game loop automatically, handles mouseover and click detection.
		 */
		override public function update():void
		{
			updateButton(); //Basic button logic
		}
		
		/**
		 * Basic button update logic
		 */
		protected function updateButton():void
		{
			var prevStatus:uint = _status;
			
			if (FlxG.mouse.visible)
			{
				if (buttonNormal.cameras == null)
				{
					buttonNormal.cameras = FlxG.cameras;
				}
				
				var c:FlxCamera;
				var i:uint = 0;
				var l:uint = buttonNormal.cameras.length;
				var offAll:Boolean = true;
				
				while(i < l)
				{
					c = buttonNormal.cameras[i++] as FlxCamera;
					
					if (FlxMath.mouseInFlxRect(false, buttonNormal.rect))
					{
						offAll = false;
						
						if (FlxG.mouse.justPressed())
						{
							_status = PRESSED;
						}
						
						if (_status == NORMAL)
						{
							_status = HIGHLIGHT;
						}
					}
				}
				
				if (offAll)
				{
					_status = NORMAL;
				}
			}
			
			if (_status != prevStatus)
			{
				if (_status == NORMAL)
				{
					buttonNormal.visible = true;
					buttonHighlight.visible = false;
					
					if (textNormal)
					{
						textNormal.visible = true;
						textHighlight.visible = false;
					}
					
					if (leaveCallback is Function)
					{
						leaveCallback.apply(null, leaveCallbackParams);
					}
				}
				else if (_status == HIGHLIGHT)
				{
					buttonNormal.visible = false;
					buttonHighlight.visible = true;
					
					if (textNormal)
					{
						textNormal.visible = false;
						textHighlight.visible = true;
					}
					
					if (enterCallback is Function)
					{
						enterCallback.apply(null, enterCallbackParams);
					}
				}
			}
		}
		
		override public function draw():void
		{
			super.draw();
		}
		
		/**
		 * Called by the game state when state is changed (if this object belongs to the state)
		 */
		override public function destroy():void
		{
			if (FlxG.stage != null)
			{
				FlxG.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
			
			if (buttonNormal != null)
			{
				buttonNormal.destroy();
				buttonNormal = null;
			}
			
			if (buttonHighlight != null)
			{
				buttonHighlight.destroy();
				buttonHighlight = null;
			}
			
			if (textNormal != null)
			{
				textNormal.destroy();
				textNormal = null;
			}
			
			if (textHighlight != null)
			{
				textHighlight.destroy();
				textHighlight = null;
			}
			
			_onClick = null;
			enterCallback = null;
			leaveCallback = null;
			
			super.destroy();
		}
		
		/**
		 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxU.openURL()</code>).
		 */
		protected function onMouseUp(event:MouseEvent):void
		{
			if (exists && visible && active && (_status == PRESSED) && (_onClick != null) && (pauseProof || !FlxG.paused))
			{
				_onClick.apply(null, onClickParams);
			}
		}
		
		/**
		 * If you want to change the color of this button in its in-active (not hovered over) state, then pass a new array of color values
		 * 
		 * @param	colors
		 */
		public function updateInactiveButtonColors(colors:Array):void
		{
			offColor = colors;
			
			buttonNormal.stamp(FlxGradient.createGradientFlxSprite(width - 2, height - 2, offColor), 1, 1);
		}
		
		/**
		 * If you want to change the color of this button in its active (hovered over) state, then pass a new array of color values
		 * 
		 * @param	colors
		 */
		public function updateActiveButtonColors(colors:Array):void
		{
			onColor = colors;
			
			buttonHighlight.stamp(FlxGradient.createGradientFlxSprite(width - 2, height - 2, onColor), 1, 1);
		}
		
		/**
		 * If this button has text, set this to change the value
		 */
		public function set text(value:String):void
		{
			if (textNormal && textNormal.text != value)
			{
				textNormal.text = value;
				textHighlight.text = value;
			}
		}
		
		/**
		 * Center this button (on the X axis) Uses FlxG.width / 2 - button width / 2 to achieve this.<br />
		 * Doesn't take into consideration scrolling
		 */
		public function screenCenter():void
		{
			buttonNormal.x = (FlxG.width / 2) - (width / 2);
			buttonHighlight.x = (FlxG.width / 2) - (width / 2);
			
			if (textNormal)
			{
				textNormal.x = buttonNormal.x;
				textHighlight.x = buttonHighlight.x;
			}
		}
		
		/**
		 * Sets a callback function for when this button is rolled-over with the mouse
		 * 
		 * @param	callback	The function to call, will be called once when the mouse enters
		 * @param	params		An optional array of parameters to pass to the function
		 */
		public function setMouseOverCallback(callback:Function, params:Array = null):void
		{
			enterCallback = callback;
			
			enterCallbackParams = params;
		}
		
		/**
		 * Sets a callback function for when the mouse rolls-out of this button
		 * 
		 * @param	callback	The function to call, will be called once when the mouse leaves the button
		 * @param	params		An optional array of parameters to pass to the function
		 */
		public function setMouseOutCallback(callback:Function, params:Array = null):void
		{
			leaveCallback = callback;
			
			leaveCallbackParams = params;
		}
		
	}
}
