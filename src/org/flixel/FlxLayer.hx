package org.flixel;

import nme.Assets;
import nme.display.BitmapData;
import nme.display.BlendMode;
import nme.display.Graphics;
import nme.display.Tilesheet;
import org.flixel.FlxBasic;
import org.flixel.system.layer.Atlas;
import org.flixel.system.layer.Node;
#if (cpp || neko)
import org.flixel.system.layer.TileSheetData;
#end

class FlxLayer
{
	/**
	 * Storage for all created layers in current state
	 */
	private static var _layerCache:Hash<FlxLayer> = new Hash<FlxLayer>();
	
	private var _atlas:Atlas;
	private var _tileSheet:Tilesheet;
	/**
	 * Number of objects on this layer
	 */
	private var _numObjects:Int;
	
	/**
	 * Drawing flags, used for tilesheet rendering
	 */
	public var flags:Int;
	/**
	 * Layer blending flag.
	 */
	private var _blend:Int;
	/**
	 * draw data for tilesheet rendering
	 */
	public var drawData:Array<Array<Float>>;
	/**
	 * position offsets in drawData arrays. I use them for little optimization
	 */
	public var positionData:Array<Int>;
	/**
	 * Layer antialiasing
	 */
	public var antialiasing:Bool;
	/**
	 * Bool flag to track if the layer is on state. Please, do not modify it's value.
	 */
	public var onStage:Bool;
	
	// TODO: Maybe we need variable (array or list) to track objects on layer
	
	/**
	 * Constructot
	 * @param	Name	layer name. Need to be unique.
	 */
	public function new(Name:String)
	{
		_numObjects = 0;
		drawData = [];
		positionData = [];
		antialiasing = false;
		
		onStage = false;
		
		_layerCache.set(Name, this);
		isColored = false;
		_blend = Tilesheet.TILE_BLEND_NORMAL;
	}
	
	/**
	 * Updates whole atlas' bitmapdata. this could be very slow, so use it if you really need it.
	 */
	public function redrawAtlas():Void
	{
		_atlas.redrawAll();
	}
	
	/**
	 * Updates atlas' bitmapdata. Call it after changin' sprite's graphic
	 * @param	node	Node with changed bitmapdata
	 */
	public function redrawNode(node:Node):Void
	{
		_atlas.redrawNode(node);
	}
	
	public var isColored(default, set_isColored):Bool;
	
	private function set_isColored(value:Bool):Bool
	{
		isColored = value;
		updateFlags();
		return value;
	}
	
	/**
	 * Updates drawing flags
	 */
	private function updateFlags():Void
	{
		#if (cpp || neko)
		flags = Graphics.TILE_TRANS_2x2 | Graphics.TILE_ALPHA;
		if (isColored)
		{
			flags |= Graphics.TILE_RGB;
		}
		#end
	}
	
	/**
	 * Destroys layer (clean memory)
	 * @param	total	set it to true if you want to destroy layer's atlas. But be carefull, since many layers can use same atlas.
	 */
	public function destroy(total:Bool = false):Void 
	{
		if (total && _atlas != null)
		{
			_atlas.destroy();
		}
		
		_atlas = null;
		_tileSheet = null;
		drawData = null;
		positionData = null;
		onStage = false;
	}
	
	/**
	 * Adds object to this layer. May remove it if object was on another layer. Tries to add object's bitmapdata on layer's atlas.
	 * Important note: You will still need to add an object not only in the layer, but in the state using state's add() method
	 * @param	Object	object to add.
	 * @return	added object. May return null if object can't be added on this layer.
	 */
	public function add(Object:FlxBasic):FlxBasic
	{
		#if (cpp || neko)
		if (_atlas == null)
		{
			var key:String = Object.bitmapDataKey;
			var bm:BitmapData = FlxG._cache.get(Object.bitmapDataKey);
			if (bm == null) return null;
			atlas = Atlas.getAtlas(key, bm);
		}
		
		if (Std.is(Object, FlxGroup))
		{
			var grp:FlxGroup = cast(Object, FlxGroup);
			for (basic in grp.members)
			{
				if (basic != null)
				{
					add(basic);
				}
			}
			
			Object.layer = this;
		}
		else if (Std.is(Object, FlxText))
		{
			// FlxText objects can't be added to particular layer
			return Object;
		}
		else
		{
			addObjectToLayer(Object);
		}
		#end
		return Object;
	}
	
	private function addObjectToLayer(Object:FlxBasic):FlxBasic
	{
		#if (cpp || neko)
		var objLayer:FlxLayer = Object.layer;
		if (objLayer != this)	
		{
			if (objLayer != null)
			{
				objLayer.remove(Object);
			}
			_numObjects++;
			Object.layer = this;
		}
		#end
		return Object;
	}
	
	/**
	 * Removes object from this layer
	 * @param	Object	object to remove
	 * @return	removed object
	 */
	public function remove(Object:FlxBasic):FlxBasic
	{
		#if (cpp || neko)
		if (Object.layer == this)	
		{
			if (Std.is(Object, FlxGroup))
			{
				var grp:FlxGroup = cast(Object, FlxGroup);
				for (basic in grp.members)
				{
					if (basic != null)
					{
						remove(basic);
					}
				}
				
				Object.layer = null;
			}
			else
			{
				removeObjectFromLayer(Object);
			}
		}
		#end
		return Object;
	}
	
	private function removeObjectFromLayer(Object:FlxBasic):FlxBasic
	{
		#if (cpp || neko)
		Object.layer = null;
		#end
		_numObjects--;
		return Object;
	}
	
	/**
	 * Adds image to layer's atlas.
	 */
	public function addImage(Image:Dynamic, Key:String = null, Unique:Bool = false):Node
	{
		var bd:BitmapData = null;
		var key:String = null;
		if (Std.is(Image, Class))
		{
			bd = Type.createInstance(cast(Image, Class<Dynamic>), []).bitmapData;
			key = Type.getClassName(cast(Image, Class<Dynamic>));
		}
		else if (Std.is(Image, BitmapData) && Key != null)
		{
			bd = Image;
			key = Key;
		}
		else if (Std.is(Image, String))
		{
			bd = Assets.getBitmapData(Image);
			key = Image;
		}
		else
		{
			return null;
		}
		
		if (Unique && hasImage(key))
		{
			var inc:Int = 0;
			var ukey:String;
			do
			{
				ukey = key + inc++;
			} while (hasImage(ukey));
			key = ukey;
		}
		
		if (hasImage(key))
		{
			return _atlas.getNodeByKey(key);
		}
		
		return _atlas.addNode(bd, key);
	}
	
	public function hasImage(Key:String):Bool
	{
		return _atlas.hasNodeWithName(Key);
	}
	
	#if (cpp || neko)
	public function render(numCameras:Int):Void
	{
		var cameraGraphics:Graphics;
		var data:Array<Float>;
		var dataLen:Int;
		var position:Int;
		var camera:FlxCamera;
		var tempFlags:Int;
		for (i in 0...(numCameras))
		{
			tempFlags = flags;
			
			data = drawData[i];
			dataLen = data.length;
			position = positionData[i];
			
			if (position > 0)
			{
				if (dataLen != position)
				{
					data.splice(position, (dataLen - position));
				}
				
				camera = FlxG.cameras[i];
				
				if (!camera.visible || !camera.exists)
				{
					continue;
				}
				
				if (camera.isColored() && !isColored)
				{
					tempFlags |= Graphics.TILE_RGB;
				}
				tempFlags |= _blend;
				cameraGraphics = camera._canvas.graphics;
				_tileSheet.drawTiles(cameraGraphics, data, (antialiasing || camera.antialiasing), tempFlags);
				TileSheetData._DRAWCALLS++;
			}
		}
	}
	
	public function clearDrawData(numCameras:Int):Void
	{
		var numPositions:Int = positionData.length;
		for (i in 0...(numPositions))
		{
			positionData[i] = 0;
		}
		
		if (numPositions < numCameras)
		{
			var diff:Int = numCameras - numPositions;
			for (i in 0...(diff))
			{
				drawData.push(new Array<Float>());
				positionData.push(0);
			}
		}
	}
	#end
	
	/**
	 * Layer's atlas. You can't change layer's atlas if layer contains any object already.
	 */
	public var atlas(get_atlas, set_atlas):Atlas;
	/**
	 * Layer's blendMode. It supports only NORMAL and ADD modes currently
	 */
	public var blend(get_blend, set_blend):BlendMode;
	
	private function get_blend():BlendMode 
	{
		var mode:BlendMode = BlendMode.NORMAL;
		#if (cpp || neko)
		switch (_blend)
		{
			case Tilesheet.TILE_BLEND_ADD:
				mode = BlendMode.ADD;
		}
		#end
		return mode;
	}
	
	private function set_blend(value:BlendMode):BlendMode 
	{
		#if (cpp || neko)
		if (value != null)
		{
			switch (value)
			{
				case BlendMode.ADD:
					_blend = Tilesheet.TILE_BLEND_ADD;
				default:
					_blend = Tilesheet.TILE_BLEND_NORMAL;
			}
		}
		#end
		return value;
	}
	
	private function get_atlas():Atlas 
	{
		return _atlas;
	}
	
	private function set_atlas(value:Atlas):Atlas 
	{
		if (_numObjects == 0)
		{
			_atlas = value;
			#if (cpp || neko)
			if (value != null)
			{
				_tileSheet = _atlas._tileSheetData.tileSheet;
			}
			else
			{
				_tileSheet = null;
			}
			#end
		}
		return value;
	}
	
	/**
	 * Creates new layer from specified bitmapdata and stores it in layer cache, or gets cached layer if you don't need unique layer
	 * @param	Key			key to store in layer cache
	 * @param	BmData		bitmapdata for atlas
	 * @param	Unique		set this param to true if you want to be sure in key's uniqueness (plus you should provide unique bitmapdata for totally unique layer and it's atlas)
	 * @return	newly created layer or layer from cache (if Unique is set to false and layer with the same key was found in cache)
	 */
	public static function fromBitmapData(Key:String, BmData:BitmapData, Unique:Bool = false):FlxLayer
	{
		var layer:FlxLayer;
		var alreadyExist:Bool = checkCache(Key);
		if (Unique || alreadyExist == false)
		{
			var LayerKey:String = Key;
			if (Unique && alreadyExist)
			{
				var i:Int = 1;
				while (checkCache(Key + i))
				{
					i++;
				}
				LayerKey = Key + i;
			}
			
			layer = new FlxLayer(LayerKey);
			layer.atlas = Atlas.getAtlas(Key, BmData, Unique);
		}
		else
		{
			layer = _layerCache.get(Key);
		}
		
		return layer;
	}
	
	/**
	 * Creates new layer with atlas from specified Layer and stores it in cache with Key
	 * @param	Layer	layer to copy atlas from
	 * @param	Key		key to store in layer cache
	 * @return	newly created layer
	 */
	public static function fromLayer(Layer:FlxLayer, Key:String):FlxLayer
	{
		var alreadyExist:Bool = checkCache(Key);
		if (alreadyExist)
		{
			var i:Int = 1;
			while (checkCache(Key + i))
			{
				i++;
			}
			Key = Key + i;
		}
		
		var layer:FlxLayer = new FlxLayer(Key);
		layer.atlas = Layer.atlas;
		return new FlxLayer(Key);
	}
	
	/**
	 * Creates empty atlas with specified dimensions
	 * @param	Width	atlas width
	 * @param	Height	atlas height
	 * @param	Key		atlas key (or name)
	 * @return	new empty atlas object
	 */
	public static function createAtlas(Width:Int, Height:Int, Key:String):Atlas
	{
		var AtlasKey:String = Atlas.getUniqueKey(Key);
		return new Atlas(AtlasKey, Width, Height);
	}
	
	/**
	 * Checks if there is layer with Key in layer cache
	 * @param	Key	layer key
	 * @return	true if layer cache contains layer with specified key; false when it doesn't
	 */
	public static function checkCache(Key:String):Bool
	{
		return _layerCache.exists(Key);
	}
	
	/**
	 * Gets the layer from cache
	 * @param	Key	layer key
	 * @return	store layer or null if there isn't layer with such key
	 */
	public static function getLayer(Key:String):FlxLayer
	{
		return _layerCache.get(Key);
	}
	
	/**
	 * Removes layer from cache and destroys it. Or do nothing when layer is on 'stage' or contains objects
	 * @param	Layer	FlxLayer to remove
	 * @param	total	if true then layer's atlas will be destroyed. So keep attention or it can break another layers with the same atlas
	 */
	public static function removeLayerFromCache(Layer:FlxLayer, total:Bool = false):Void
	{
		var layer:FlxLayer;
		var removeKey:String = null;
		for (key in _layerCache.keys())
		{
			layer = _layerCache.get(key);
			if (layer == Layer)
			{
				removeKey = key;
				break;
			}
		}
		
		if (removeKey != null && !Layer.onStage && Layer._numObjects == 0)
		{
			_layerCache.remove(removeKey);
			Layer.destroy(total);
		}
	}
	
	/**
	 * Clears layer cache. You shouldn't call this method, or there will be troubles.
	 */
	public static function clearLayerCache():Void
	{
		var layer:FlxLayer;
		for (key in _layerCache.keys())
		{
			layer = _layerCache.get(key);
			if (layer.onStage || layer.atlas != null) 
			{
				layer.destroy(true);
			}
			_layerCache.remove(key);
		}
	}
}