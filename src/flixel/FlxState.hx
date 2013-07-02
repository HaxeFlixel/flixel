package flixel;

import flash.display.BitmapData;
import flixel.system.layer.Atlas;
import flixel.group.FlxGroup;

/**
 * This is the basic game "state" object - e.g. in a simple game
 * you might have a menu state and a play state.
 * It is for all intents and purpose a fancy FlxGroup.
 * And really, it's not even that fancy.
 */
class FlxState extends FlxGroup
{
	/**
	* Determines whether or not this state is updated even when it is not the active state. For
	* example, if you have your game state first, and then you push a menu state on top of it,
	* if this is set to true, the game state would continue to update in the background. By default
	* this is false, so background states will be "paused" when they are not active.
	*
	* @default false
	*/
	public var persistantUpdate:Bool;
	
	/**
	* Determines whether or not this state is updated even when it is not the active state. For
	* example, if you have your game state first, and then yuo push a menu state on top of it,
	* if this is set to true, the game state would continue to be drawn behind the pause state.
	* By default this is true, so background states will continue to be drawn behind the current
	* state. If background states are not visible when you have a different state on top, you should
	* set this to false for improved performance.
	*
	* @default true
	*/
	public var persistantDraw:Bool;
	
	private var _subState:FlxSubState;
	/**
	 * Current substate.
	 * Substates also can have substates
	 */
	public var subState(get_subState, null):FlxSubState;
	
	private function get_subState():FlxSubState 
	{
		return _subState;
	}
	
	/**
	 * Background color of this state
	 */
	private var _bgColor:Int;
	public var bgColor(get_bgColor, set_bgColor):Int;
	
	private function get_bgColor():Int 
	{
		return FlxG.cameras.bgColor;
	}
	
	private function set_bgColor(value:Int):Int 
	{
		return FlxG.cameras.bgColor = value;
	}
	
	private var _useMouse:Bool = false;
	
	/**
	 * Whether to show mouse pointer or not
	 */
	public var useMouse(get_useMouse, set_useMouse):Bool;
	private function get_useMouse():Bool { return _useMouse; }
	private function set_useMouse(value:Bool):Bool
	{
		_useMouse = value;
		this.updateMouseVisibility();
		return value;
	}
	private function updateMouseVisibility():Void
	{
	#if !FLX_NO_MOUSE
		#if mobile
		FlxG.mouse.hide();
		#else
		if (_useMouse) { FlxG.mouse.show(); }
		else { FlxG.mouse.hide(); }
		#end
	#end
	}
	
	/**
	 * State constructor
	 */
	public function new()
	{
		super();
		
		persistantUpdate = false;
		persistantDraw = true;
		#if !FLX_NO_MOUSE
		this.useMouse = FlxG.mouse.visible;
		#end
	}
	
	/**
	 * This function is called after the game engine successfully switches states.
	 * Override this function, NOT the constructor, to initialize or set up your game state.
	 * We do NOT recommend overriding the constructor, unless you want some crazy unpredictable things to happen!
	 */
	public function create():Void { }
	
	override public function draw():Void
	{
		if (persistantDraw || _subState == null)
		{
			super.draw();
		}
		
		if (_subState != null)
		{
			_subState.draw();
		}
	}
	
#if !FLX_NO_DEBUG
	override public function drawDebug():Void
	{
		if (persistantDraw || _subState == null)
		{
			super.drawDebug();
		}
		
		if (_subState != null)
		{
			_subState.drawDebug();
		}
	}
#end
	
	public function tryUpdate():Void
	{
		if (persistantUpdate || _subState == null)
		{
			update();
		}
		
		if (_subState != null)
		{
			_subState.tryUpdate();
		}
	}
	
	/**
	 * Manually close the sub-state
	*/
	public function closeSubState(destroy:Bool = true):Void
	{
		this.setSubState(null, null, destroy);
	}
	
	/**
	 * Set substate for this state
	 * @param	requestedState		substate to add
	 * @param	closeCallback		close callback function, which will be called after closing requestedState
	 * @param	destroyPrevious		whether to destroy previuos substate (if there is one) or not
	 */
	public function setSubState(requestedState:FlxSubState, closeCallback:Void->Void = null, destroyPrevious:Bool = true):Void
	{
		if (_subState == requestedState)	return;

		//Destroy the old state (if there is an old state)
		if(_subState != null)
		{
			_subState.close(destroyPrevious);
		}

		//Finally assign and create the new state (or set it to null)
		_subState = requestedState;

		if (_subState != null)
		{
			//WARNING: What if the state has already been created?
			// I'm just copying the code from "FlxGame::switchState" which doesn't check for already craeted states. :/
			_subState._parentState = this;
			
			_subState.closeCallback = closeCallback;

			//Reset the input so things like "justPressed" won't interfere
			if (!persistantUpdate) 
			{ 
				FlxG.resetInput();
			}
			
			if (!_subState.initialized)
			{
				_subState.initialize();
				_subState.create();
			}
		}
	}
	
	/**
	 * Helper method for closing substate
	 * @param	destroy		whether to destroy current substate (by default) or leave it as is, so closed substate can be reused many times
	 */
	private function subStateCloseHandler(destroy:Bool = true):Void
	{
		if (_subState.closeCallback != null)
		{
			_subState.closeCallback();
		}
		
		if (destroy)
		{
			_subState.destroy();
		}
		_subState = null;
		
		this.updateMouseVisibility();
	}

	override public function destroy():Void
	{
		if (_subState != null)	
			this.closeSubState();
			
		super.destroy();
	}
	
	/**
	 * Gets the atlas for specified key from bitmap cache in FlxG. Creates new atlas for it if there wasn't such a atlas 
	 * @param	KeyInBitmapCache	key from bitmap cache in FlxG
	 * @return	required atlas
	 */
	public function getAtlasFor(KeyInBitmapCache:String):Atlas
	{
		var bm:BitmapData = FlxG.bitmap._cache.get(KeyInBitmapCache);
		if (bm != null)
		{
			var tempAtlas:Atlas = Atlas.getAtlas(KeyInBitmapCache, bm);
			return tempAtlas;
		}
		else
		{
			#if !FLX_NO_DEBUG
			throw "There isn't bitmapdata in cache with key: " + KeyInBitmapCache;
			#end
		}
		
		return null;
	}
	
	/**
	 * Creates and adds new atlas to atlas cache, so it can be drawn
	 * @param	atlasName		name of atlas to be created 
	 * @param	atlasWidth		width of atlas
	 * @param	atlasHeight		height of atlas
	 * @return					new empty atlas object
	 */
	public function createAtlas(atlasName:String, atlasWidth:Int, atlasHeight:Int):Atlas
	{
		var key:String = Atlas.getUniqueKey(atlasName);
		return Atlas.getAtlas(key, null, false, atlasWidth, atlasHeight);
	}
	
	/**
	 * Removes atlas from cache.
	 * @param	atlas		atlas to remove
	 * @param	destroy		if true then atlas will be completely destroyed also (be carefull with this parameter)
	 */
	public function removeAtlas(atlas:Atlas, destroy:Bool = false):Void
	{
		Atlas.removeAtlas(atlas, destroy);
	}
	
	/**
	 * This method is called after application losts its focus.
	 * Can be useful if you using third part libraries, such as tweening engines.
	 * Override it in subclasses
	 */
	public function onFocusLost():Void
	{
		
	}
	
	/**
	 * This method is called after application gets focus.
	 * Can be useful if you using third part libraries, such as tweening engines.
	 * Override it in subclasses
	 */
	public function onFocus():Void
	{
		
	}
}