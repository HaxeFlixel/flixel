package org.flixel;

import nme.display.BitmapData;
import org.flixel.system.layer.Atlas;
import org.flixel.system.layer.DrawStackItem;
import org.flixel.system.layer.TileSheetData;

/**
 * This is the basic game "state" object - e.g. in a simple game
 * you might have a menu state and a play state.
 * It is for all intents and purpose a fancy FlxGroup.
 * And really, it's not even that fancy.
 */
class FlxState extends FlxGroup
{
	public function new()
	{
		super();
	}
	
	/**
	 * This function is called after the game engine successfully switches states.
	 * Override this function, NOT the constructor, to initialize or set up your game state.
	 * We do NOT recommend overriding the constructor, unless you want some crazy unpredictable things to happen!
	 */
	public function create():Void { }
	
	/**
	 * Gets the atlas for specified key from bitmap cache in FlxG. Creates new atlas for it if there wasn't such a atlas 
	 * @param	KeyInBitmapCache	key from bitmap cache in FlxG
	 * @return	required atlas
	 */
	public function getAtlasFor(KeyInBitmapCache:String):Atlas
	{
		#if !flash
		var bm:BitmapData = FlxG._cache.get(KeyInBitmapCache);
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
		#end
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
		return new Atlas(key, atlasWidth, atlasHeight);
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
	
	/**
	 * This function is inlined because it never gets called on FlxState objects.
	 * Put your code in the update() function.
	 */
	override public inline function preUpdate():Void {}
	/**
	 * This function is inlined because it never gets called on FlxState objects.
	 * Put your code in the update() function.
	 */
	override public inline function postUpdate():Void {}
}