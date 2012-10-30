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
	
	public function getLayerAt(index:Int):FlxLayer
	{
		if (index < 0 || index > getMaxIndex())
		{
			return null;
		}
		return _layers[index];
	}
	
	public function getLayerIndex(layer:FlxLayer):Int
	{
		if (layer == null || !layer.onStage)	return -1; 
		return FlxU.ArrayIndexOf(_layers, layer);
	}
	
	public function getMaxIndex():Int
	{
		return (_layers.length - 1);
	}
	
	public function addLayerAt(layer:FlxLayer, index:Int):Void
	{
		var layerIndex:Int = getLayerIndex(layer);
		if (layerIndex == index)
		{
			return;
		}
		
		var maxIndex:Int = getMaxIndex();
		if (layerIndex >= 0)
		{
			removeLayer(layer);
			if (index > maxIndex)
			{
				addLayer(layer);
				return;
			}
		}
		else if (index > maxIndex)
		{
			addLayer(layer);
			return;
		}
		
		if (index < 0)
		{
			index = 0;
		}
		
		_layers.insert(index, layer);
		layer.onStage = true;
	}
	
	public function removeLayerAt(index:Int):Void
	{
		var layer:FlxLayer = getLayerAt(index);
		if (layer != null)
		{
			removeLayer(layer);
		}
	}
	
	public function swapLayers(layer1:FlxLayer, layer2:FlxLayer):Void
	{
		if (layer1 == layer2) return;
		var id1:Int = FlxU.ArrayIndexOf(_layers, layer1);
		var id2:Int = FlxU.ArrayIndexOf(_layers, layer2);
		if (id1 < 0 || id2 < 0) return;
		
		swapLayersAt(id1, id2);
	}
	
	public function swapLayersAt(id1:Int, id2:Int):Void
	{
		var numLayers:Int = _layers.length;
		if (id1 < 0 || id2 < 0 || id1 == id2 || id1 >= numLayers || id2 >= numLayers) return;
		var tempLayer:FlxLayer = _layers[id1];
		_layers[id1] = _layers[id2];
		_layers[id2] = tempLayer;
	}
	
	public function addLayer(Layer:FlxLayer):FlxLayer
	{
		#if (cpp || neko)
		if (!Layer.onStage)
		{
			_layers.push(Layer);
			Layer.onStage = true;
		}
		#end
		return Layer;
	}
	
	public function removeLayer(Layer:FlxLayer):FlxLayer
	{
		#if (cpp || neko)
		var pos:Int = FlxU.ArrayIndexOf(_layers, Layer);
		if (pos >= 0)
		{
			_layers.splice(pos, 1);
			Layer.onStage = false;
		}
		#end
		return Layer;
	}
	
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