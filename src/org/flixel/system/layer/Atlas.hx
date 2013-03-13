package org.flixel.system.layer;

import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.FlxG;
import org.flixel.system.layer.TileSheetData;

/**
 * Atlas class
 * @author Zaphod
 */
class Atlas
{
	/**
	 * Storate for all created atlases in current state
	 */
	private static var _atlasCache:Hash<Atlas> = new Hash<Atlas>();
	
	public var tempStorage:Array<TempAtlasObj>;
	
	/**
	 * Root node of atlas
	 */
	public var root:Node;
	
	/**
	 * Name of the atlas. Don't change it manually!!!
	 */
	public var name:String;
	
	public var nodes:Hash<Node>;
	public var atlasBitmapData:BitmapData;
	
	/**
	 * Offsets between nodes in atlas
	 */
	public var borderX:Int;
	public var borderY:Int;
	
	#if !flash
	public var _tileSheetData:TileSheetData;
	#end
	
	/**
	 * Bool flag for internal use.
	 */
	private var _fromBitmapData:Bool;
	
	/**
	 * Atlas constructor
	 * @param	width		atlas width
	 * @param	height		atlas height
	 * @param	borderX		horizontal distance between nodes
	 * @param	borderY		vertical distance between nodes
	 */
	public function new(name:String, width:Int, height:Int, borderX:Int = 1, borderY:Int = 1, bitmapData:BitmapData = null) 
	{
		nodes = new Hash<Node>();
		this.name = name;
		
		if (bitmapData == null)
		{
			root = new Node(this, new Rectangle(0, 0, width, height));
			atlasBitmapData = new BitmapData(width, height, true, FlxG.TRANSPARENT);
			_fromBitmapData = false;
		}
		else
		{
			root = new Node(this, bitmapData.rect, bitmapData, name);
			atlasBitmapData = bitmapData;
			nodes.set(name, root);
			_fromBitmapData = true;
		}
		
		this.borderX = borderX;
		this.borderY = borderY;
		
		#if !flash
		_tileSheetData = createTileSheetData (atlasBitmapData);
		#end
		
		_atlasCache.set(name, this);
	}

#if !flash
  /**
   * Creates TileSheetData for BitmapData.
   * @param bitmapData    BitmapData for that TileSheetData will be created
   * @return TileSheetData
   */
  public function createTileSheetData (bitmapData : BitmapData) : TileSheetData
  {
    return TileSheetData.addTileSheet (bitmapData);
  }
#end

  /**
   * Returns true if atlas for key is already exist.
   * @param key   atlas' key (name)
   * @return true if atlas already in cache
   */
  public static function isExists (key : String) : Bool
  {
    return _atlasCache.exists (key);
  }
	
	/**
	 * Gets atlas from cache or creates new one.
	 * @param	Key			atlas' key (name)
	 * @param	BmData		atlas' bitmapdata
	 * @return	atlas from cache
	 */
	public static function getAtlas(Key:String, BmData:BitmapData, Unique:Bool = false):Atlas
	{
		var alreadyExist:Bool = isExists(Key);
		
		if (!Unique && alreadyExist)
		{
			return _atlasCache.get(Key);
		}
		
		var AtlasKey:String = Key;
		if (Unique && alreadyExist)
		{
			AtlasKey = getUniqueKey(Key);
		}
		
		var atlas:Atlas = new Atlas(AtlasKey, BmData.width, BmData.height, 1, 1, BmData);
		return atlas;
	}
	
	public static function getUniqueKey(Key:String):String
	{
		if (!_atlasCache.exists(Key)) return Key;
		
		var AtlasKey:String = Key;
		var i:Int = 1;
		while (_atlasCache.exists(Key + i))
		{
			i++;
		}
		AtlasKey = Key + i;
		return AtlasKey;
	}
	
	/**
	 * Removes atlas from cache
	 * @param	atlas	Atlas to remove
	 * @param	destroy	if you set this param to true then atlas will be destroyed. Be carefull with it.
	 */
	public static function removeAtlas(atlas:Atlas, destroy:Bool = false):Void
	{
		var currAtlas:Atlas;
		for (key in _atlasCache.keys())
		{
			currAtlas = _atlasCache.get(key);
			if (currAtlas == atlas)
			{
				_atlasCache.remove(key);
				if (destroy) atlas.destroy();
				return;
			}
		}
	}
	
	/**
	 * Clears atlas cache. Please don't use it if you don't know what are you doing.
	 */
	public static function clearAtlasCache():Void
	{
		var atlas:Atlas;
		for (key in _atlasCache.keys())
		{
			atlas = _atlasCache.get(key);
			_atlasCache.remove(key);
			atlas.destroy();
		}
	}
	
	/**
	 * This method could optimize atlas after adding new nodes with addNode() method.
	 * Don't use it!!!
	 */
	public function rebuildAtlas():Void
	{
		createQueue();
		for (node in nodes)
		{
			addToQueue(node.item, node.key);
		}
		
		clear();
		generateAtlasFromQueue();
	}
	
	/**
	 * This method will update atlas bitmapData 
	 * so it will show changes in node's bitmapDatas
	 */
	public function redrawNode(node:Node):Void
	{
		if (hasNodeWithName(node.key) && atlasBitmapData != node.item)
		{
			atlasBitmapData.fillRect(node.rect, FlxG.TRANSPARENT);
			atlasBitmapData.copyPixels(node.item, node.rect, node.point);
		}
	}
	
	/**
	 * Redraws all nodes on atlasBitmapData
	 */
	public function redrawAll():Void
	{
		atlasBitmapData.fillRect(atlasBitmapData.rect, FlxG.TRANSPARENT);
		
		for (node in nodes)
		{
			atlasBitmapData.copyPixels(node.item, node.rect, node.point);
		}
	}
	
	/**
	 * Resizes atlas to new dimensions. Don't use it
	 */
	public function resize(newWidth:Int, newHeight:Int):Void
	{
		root.rect.width = newWidth;
		root.rect.height = newHeight;
		atlasBitmapData.dispose();
		atlasBitmapData = new BitmapData(newWidth, newHeight, true, FlxG.TRANSPARENT);
		rebuildAtlas();
	}
	
	/**
	 * Simply adds new node to atlas.
	 * @param	data	image to hold
	 * @param	key		image name
	 * @return			added node
	 */
	public function addNode(data:BitmapData, key:String):Node
	{
		if (hasNodeWithName(key) == true)
		{
			return nodes.get(key);
		}
		
		if (root.canPlace(data.width, data.height) == false)
		{
			return null;
		}
		
		var insertWidth:Int = (data.width == width) ? data.width : data.width + borderX;
		var insertHeight:Int = (data.height == height) ? data.height : data.height + borderY;
		
		var nodeToInsert:Node = findNodeToInsert(insertWidth, insertHeight);
		if (nodeToInsert != null)
		{
			var firstChild:Node;
			var secondChild:Node;
			var firstGrandChild:Node;
			var secondGrandChild:Node;
			
			var dw:Int = nodeToInsert.width - insertWidth;
			var dh:Int = nodeToInsert.height - insertHeight;
			
			if (dw > dh) // divide horizontally
			{
				firstChild = new Node(this, new Rectangle(nodeToInsert.x, nodeToInsert.y, insertWidth, nodeToInsert.height));
				secondChild = new Node(this, new Rectangle(nodeToInsert.x + insertWidth, nodeToInsert.y, nodeToInsert.width - insertWidth, nodeToInsert.height));
				
				firstGrandChild = new Node(this, new Rectangle(firstChild.x, firstChild.y, insertWidth, insertHeight), data, key);
				secondGrandChild = new Node(this, new Rectangle(firstChild.x, firstChild.y + insertHeight, insertWidth, firstChild.height - insertHeight));
			}
			else // divide vertically
			{
				firstChild = new Node(this, new Rectangle(nodeToInsert.x, nodeToInsert.y, nodeToInsert.width, insertHeight));
				secondChild = new Node(this, new Rectangle(nodeToInsert.x, nodeToInsert.y + insertHeight, nodeToInsert.width, nodeToInsert.height - insertHeight));
				
				firstGrandChild = new Node(this, new Rectangle(firstChild.x, firstChild.y, insertWidth, insertHeight), data, key);
				secondGrandChild = new Node(this, new Rectangle(firstChild.x + insertWidth, firstChild.y, firstChild.width - insertWidth, insertHeight));
			}
			
			firstChild.left = firstGrandChild;
			firstChild.right = secondGrandChild;
			
			nodeToInsert.left = firstChild;
			nodeToInsert.right = secondChild;
			
			atlasBitmapData.copyPixels(data, data.rect, firstGrandChild.point);
			
			nodes.set(key, firstGrandChild);
			
			return firstGrandChild;
		}
		
		return null;
	}
	
	/**
	 * Total width of atlas
	 */
	public var width(get_width, null):Int;
	
	private function get_width():Int
	{
		return root.width;
	}
	
	/**
	 * Total height of atlas
	 */
	public var height(get_height, null):Int;
	
	private function get_height():Int
	{
		return root.height;
	}
	
	/**
	 * Checks if atlas already contains node with the same name
	 * @param	nodeName	node name to check
	 * @return				true if atlas already contains node with the name
	 */
	public function hasNodeWithName(nodeName:String):Bool
	{
		return nodes.exists(nodeName);
	}
	
	/**
	 * Gets node by it's name
	 * @param	key		node name to search
	 * @return	node with searched name. Null if atlas doesn't contain node with a such name
	 */
	public function getNodeByKey(key:String):Node
	{
		if (hasNodeWithName(key) == true)
		{
			return nodes.get(key);
		}
		
		return null;
	}
	
	/**
	 * Get's node by bitmapData
	 * @param	bitmap	bitmapdata to search
	 * @return			node with searched bitmapData. Null if atlas doesn't contain node with a such bitmapData
	 */
	public function getNodeByBitmap(bitmap:BitmapData):Node
	{
		for (node in nodes)
		{
			if (node.item == bitmap)
			{
				return node;
			}
		}
		
		return null;
	}
	
	/**
	 * Optimized version of method for adding multiple nodes to atlas. Uses less atlas' area
	 * @param	bitmaps		BitmapData's to insert
	 * @param	keys		Names of these bitmapData's
	 * @return				true if ALL nodes were added successfully.
	 */
	public function addNodes(bitmaps:Array<BitmapData>, keys:Array<String>):Bool
	{
		var numKeys:Int = keys.length;
		var numBitmaps:Int = bitmaps.length;
		
		if (numBitmaps != numKeys)
		{
			return false;
		}
		
		var sortedBitmaps:Array<BitmapData> = bitmaps.slice(0, bitmaps.length);
		sortedBitmaps.sort(bitmapSorter);
		
		var node:Node;
		var result:Bool = true;
		var index:Int;
		for (i in 0...(numBitmaps))
		{
			index = indexOf(bitmaps, sortedBitmaps[i]);
			node = addNode(sortedBitmaps[i], keys[index]);
			if (node == null)
			{
				result = false;
			}
		}
		
		return result;
	}
	
	private function indexOf(bitmaps:Array<BitmapData>, bmd:BitmapData):Int
	{
		for (i in 0...(bitmaps.length))
		{
			if (bitmaps[i] == bmd)
			{
				return i;
			}
		}
		
		return -1;
	}
	
	private function bitmapSorter(bmd1:BitmapData, bmd2:BitmapData):Int
	{
		if (bmd2.width == bmd1.width)
		{
			if (bmd2.height == bmd1.height)
			{
				return 0;
			}
			else if (bmd2.height > bmd1.height)
			{
				return 1;
			}
			else
			{
				return -1;
			}
		}
		
		if (bmd2.width > bmd1.width)
		{
			return 1;
		}
		
		return -1;
	}
	
	/**
	 * Creates new "queue" for adding new nodes
	 */
	public function createQueue():Void
	{
		tempStorage = new Array<TempAtlasObj>();
	}
	
	/**
	 * Adds new object to queue for later creation of new node
	 * @param	data	bitmapData to hold
	 * @param	key		"name" of bitmapData
	 */
	public function addToQueue(data:BitmapData, key:String):Void
	{
		if (tempStorage == null)
		{
			tempStorage = new Array<TempAtlasObj>();
		}
		
		tempStorage.push({bmd: data, keyStr: key});
	}
	
	/**
	 * Adds all objects in "queue" to existing atlas. Doesn't erase any node
	 */
	public function generateAtlasFromQueue():Void
	{
		if (tempStorage != null)
		{
			var bitmaps:Array<BitmapData> = new Array<BitmapData>();
			var keys:Array<String> = new Array<String>();
			for (obj in tempStorage)
			{
				bitmaps.push(obj.bmd);
				keys.push(obj.keyStr);
			}
			addNodes(bitmaps, keys);
			tempStorage = null;
		}
	}
	
	/**
	 * Destroys atlas. Use only if you want to clear memory and don't need this atlas anymore
	 */
	public function destroy():Void
	{
		tempStorage = null;
		deleteSubtree(root);
		root = null;
		if (!_fromBitmapData && atlasBitmapData != null)	
		{
			atlasBitmapData.dispose();
		}
		atlasBitmapData = null;
		#if !flash
		_tileSheetData = null;
		#end
		nodes = null;
	}
	
	/**
	 * Clears all data in atlas. Use it when you want reuse this atlas
	 */
	public function clear():Void
	{
		var rootWidth:Int = root.width;
		var rootHeight:Int = root.height;
		deleteSubtree(root);
		
		root = new Node(this, new Rectangle(0, 0, rootWidth, rootHeight));
		atlasBitmapData.fillRect(root.rect, FlxG.TRANSPARENT);
		nodes = new Hash<Node>();
	}
	
	/**
	 * This method is used by FlxText objects only.
	 * @param	bmd		updated FlxText's bitmapdata
	 */
	public function clearAndFillWith(bmd:BitmapData):Node
	{
		deleteSubtree(root);
		nodes = new Hash<Node>();
		#if !flash
		TileSheetData.removeTileSheet(_tileSheetData);
		#end
		if (!_fromBitmapData)
		{
			atlasBitmapData.dispose();
		}
		root = new Node(this, bmd.rect, bmd, name);
		atlasBitmapData = bmd;
		nodes.set(name, root);
		_fromBitmapData = true;
		#if !flash
		_tileSheetData = TileSheetData.addTileSheet(atlasBitmapData);
		#end
		return root;
	}
	
	/**
	 * Gets cloned atlas.
	 * @param	cloneName	the name of new atlas
	 * @return	atlas clone
	 */
	public function clone(cloneName:String):Atlas
	{
		if (_fromBitmapData)
		{
			return null;
		}
		
		var atlasKey:String = getUniqueKey(cloneName);
		var cloneAtlas:Atlas = new Atlas(cloneName, this.width, this.height, this.borderX, this.borderY);
		cloneAtlas.createQueue();
		for (node in nodes)
		{
			cloneAtlas.addToQueue(node.item, node.key);
		}
		cloneAtlas.generateAtlasFromQueue();
		return cloneAtlas;
	}
	
	private function deleteSubtree(node:Node):Void
	{
		if (node != null)
		{
			if (node.left != null) deleteSubtree(node.left);
			if (node.right != null) deleteSubtree(node.right);
			node.destroy();
		}
	}
	
	// Inner iteration method
	private function findNodeToInsert(insertWidth:Int, insertHeight:Int):Node
	{
		// Node stack
		var stack:Array<Node> = new Array<Node>();
		// Current node
		var current:Node = root;
		// Main loop
		while (true)
		{
			// Look into current node
			if (current.isEmpty && current.canPlace(insertWidth, insertHeight))
			{
				return current;
			}
			// Move to next node
			if (current.right != null && current.right.canPlace(insertWidth, insertHeight) && current.left != null && current.left.canPlace(insertWidth, insertHeight))
			{
				stack.push(current.right);
				current = current.left;
			}
			else if (current.left != null && current.left.canPlace(insertWidth, insertHeight))
			{
				current = current.left;
			}
			else if (current.right != null && current.right.canPlace(insertWidth, insertHeight))
			{
				current = current.right;
			}
			else
			{
				if (stack.length > 0)
				{
					// Trying to get next node from the stack
					current = stack.pop();
				}
				else
				{
					// Stack is empty. End of loop
					return null;
				}
			}
		}
		
		return null;
	}
	
}

typedef TempAtlasObj = {
	public var bmd:BitmapData;
	public var keyStr:String;
}