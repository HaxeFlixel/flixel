package org.flixel;

import nme.display.BitmapData;
import org.flixel.system.layer.TileSheetData;

/**
 * This is the basic game "state" object - e.g. in a simple game
 * you might have a menu state and a play state.
 * It is for all intents and purpose a fancy FlxGroup.
 * And really, it's not even that fancy.
 */
class FlxState extends FlxGroup
{
	/**
	 * active layers
	 */
	private var _layers:Array<FlxLayer>;
	
	public function new()
	{
		super();
		_layers = [];
	}
	
	override public function destroy():Void
	{
		super.destroy();
		FlxLayer.clearLayerCache();
		for (layer in _layers)
		{
			layer.destroy(true);
		}
		_layers = null;
	}
	
	#if (cpp || neko)
	override public function draw():Void 
	{
		super.draw();
		TileSheetData._DRAWCALLS = 0;
		var numCameras:Int = FlxG.cameras.length;
		for (layer in _layers)
		{
			layer.render(numCameras);
		}
	}
	
	public function clearAllDrawData():Void
	{
		var numCameras:Int = FlxG.cameras.length;
		for (layer in _layers)
		{
			layer.clearDrawData(numCameras);
		}
	}
	#end
	
	/**
	 * This function is called after the game engine successfully switches states.
	 * Override this function, NOT the constructor, to initialize or set up your game state.
	 * We do NOT recommend overriding the constructor, unless you want some crazy unpredictable things to happen!
	 */
	public function create():Void { }
	
	// Layer manipulation methods
	
	/**
	 * Gets the layer at specified index. May return null if index is out of bounds (less than zero of more than maxIndex).
	 */
	public inline function getLayerAt(index:Int):FlxLayer
	{
		if (index < 0 || index > getMaxIndex())
		{
			return null;
		}
		return _layers[index];
	}
	
	/**
	 * Returns layer index. May return -1 if layer isn't on layer stack
	 */
	public function getLayerIndex(layer:FlxLayer):Int
	{
		if (layer == null || !layer.onStage)
			return -1;
		return FlxU.ArrayIndexOf(_layers, layer);
	}
	
	/**
	 * Retutns max index
	 */
	public inline function getMaxIndex():Int
	{
		return (_layers.length - 1);
	}
	
	/**
	 * Adds layer at specified index. Adds it at the top of layer stack if index is more than maxIndex, and at the bottom if index is less than zero.
	 */
	public function addLayerAt(layer:FlxLayer, index:Int):FlxLayer
	{
		var layerIndex:Int = getLayerIndex(layer);
		if (layerIndex == index)
		{
			return layer;
		}
		
		var maxIndex:Int = getMaxIndex();
		if (layerIndex >= 0)
		{
			removeLayer(layer);
			if (index > maxIndex)
			{
				return addLayer(layer);
			}
		}
		else if (index > maxIndex)
		{
			return addLayer(layer);
		}
		
		if (index < 0)
		{
			index = 0;
		}
		
		_layers.insert(index, layer);
		layer.onStage = true;
		return layer;
	}
	
	/**
	 * Removes layer at specified index. May return null if layer wasn't added to state before.
	 */
	public function removeLayerAt(index:Int):FlxLayer
	{
		if (index < 0 || index > getMaxIndex())
			return null;
		
		var Layer = _layers[index];
		if (Layer != null)
		{
			_layers.splice(index, 1);
			Layer.onStage = false;
		}
		return Layer;
	}
	
	/**
	 * Swaps specified layer
	 */
	public function swapLayers(layer1:FlxLayer, layer2:FlxLayer):Void
	{
		if (layer1 == layer2) return;
		var id1:Int = FlxU.ArrayIndexOf(_layers, layer1);
		var id2:Int = FlxU.ArrayIndexOf(_layers, layer2);
		if (id1 < 0 || id2 < 0) return;
		
		swapLayersAt(id1, id2);
	}
	
	/**
	 * Swaps layers at specified indices.
	 */
	public function swapLayersAt(id1:Int, id2:Int):Void
	{
		var numLayers:Int = _layers.length;
		if (id1 < 0 || id2 < 0 || id1 == id2 || id1 >= numLayers || id2 >= numLayers) return;
		var tempLayer:FlxLayer = _layers[id1];
		_layers[id1] = _layers[id2];
		_layers[id2] = tempLayer;
	}
	
	/**
	 * Adds layer at the top of layer stack. May remove layer and add it again to the state if layer was in the state already.
	 * @param	Layer	layer to add
	 * @return	added 	layer
	 */
	public function addLayer(Layer:FlxLayer):FlxLayer
	{
		#if (cpp || neko)
		removeLayer(Layer);
		_layers.push(Layer);
		Layer.onStage = true;
		#end
		return Layer;
	}
	
	/**
	 * Removes layer from state
	 * @param	Layer	layer to remove
	 * @return	removed layer if it was in the state, or null if it wasn't.
	 */
	public function removeLayer(Layer:FlxLayer):FlxLayer
	{
		#if (cpp || neko)
		var index:Int = FlxU.ArrayIndexOf(_layers, Layer);
		return removeLayerAt(index);
		#end
		return null;
	}
	
	/**
	 * Gets the layer for specified key from bitmap cache in FlxG. Creates new layer for it if there wasn't such a layer 
	 * @param	KeyInBitmapCache	key from bitmap cache in FlxG
	 * @return	required layer
	 */
	public function getLayerFor(KeyInBitmapCache:String):FlxLayer
	{
		#if (cpp || neko)
		var layer:FlxLayer = FlxLayer.getLayer(KeyInBitmapCache);
		if (layer != null)
		{
			if (!layer.onStage) addLayer(layer);
			return layer;
		}
		
		var bm:BitmapData = FlxG._cache.get(KeyInBitmapCache);
		if (bm != null)
		{
			return addLayer(FlxLayer.fromBitmapData(KeyInBitmapCache, bm));
		}
		else
		{
			#if debug
			throw "There isn't bitmapdata in cache with key: " + KeyInBitmapCache;
			#end
		}
		#end
		return null;
	}
}