package flixel.atlas;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.util.FlxColor;
import flixel.atlas.FlxNode;
import flixel.system.FlxAssets;

/**
 * Atlas class
 * @author Zaphod
 */
class FlxAtlas
{	
	/**
	 * Root node of atlas
	 */
	public var root:FlxNode;
	
	public var nodes:Map<String, FlxNode>;
	public var atlasBitmapData:BitmapData;
	
	/**
	 * Offsets between nodes in atlas
	 */
	public var borderX:Int;
	public var borderY:Int;
	
	private var _tempStorage:Array<TempAtlasObj>;
	
	/**
	 * Atlas constructor
	 * @param	width		atlas width
	 * @param	height		atlas height
	 * @param	borderX		horizontal distance between nodes
	 * @param	borderY		vertical distance between nodes
	 */
	public function new(width:Int, height:Int, borderX:Int = 1, borderY:Int = 1) 
	{
		nodes = new Map<String, FlxNode>();
		
		root = new FlxNode(new Rectangle(0, 0, width, height));
		atlasBitmapData = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
		
		this.borderX = borderX;
		this.borderY = borderY;
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
	public function redrawNode(node:FlxNode):Void
	{
		if (hasNodeWithName(node.key) && atlasBitmapData != node.item)
		{
			atlasBitmapData.fillRect(node.rect, FlxColor.TRANSPARENT);
			atlasBitmapData.copyPixels(node.item, node.rect, node.point);
		}
	}
	
	/**
	 * Redraws all nodes on atlasBitmapData
	 */
	public function redrawAll():Void
	{
		atlasBitmapData.fillRect(atlasBitmapData.rect, FlxColor.TRANSPARENT);
		
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
		atlasBitmapData = new BitmapData(newWidth, newHeight, true, FlxColor.TRANSPARENT);
		rebuildAtlas();
	}
	
	/**
	 * Simply adds new node to atlas.
	 * @param	data	image to store
	 * @param	key		image name
	 * @return			added node
	 */
	public function addNode(Graphic:Dynamic, Key:String = null):FlxNode
	{
		var isClass:Bool = true;
		var isBitmapData:Bool = true;
		if (Std.is(Graphic, Class))
		{
			isClass = true;
			isBitmapData = false;
		}
		else if (Std.is(Graphic, BitmapData) && Key != null)
		{
			isClass = false;
			isBitmapData = true;
		}
		else if (Std.is(Graphic, String))
		{
			isClass = false;
			isBitmapData = false;
		}
		else
		{
			return null;
		}
		
		var key:String = Key;
		var data:BitmapData = null;
		if (isClass)
		{
			key = Type.getClassName(cast(Graphic, Class<Dynamic>));
			data = Type.createInstance(cast(Graphic, Class<Dynamic>), []).bitmapData;
		}
		else if (isBitmapData)
		{
			key = Key;
			data = cast Graphic;
		}
		else
		{
			key = Graphic;
			data = FlxAssets.getBitmapData(Graphic);
		}
		
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
		
		var nodeToInsert:FlxNode = findNodeToInsert(insertWidth, insertHeight);
		if (nodeToInsert != null)
		{
			var firstChild:FlxNode;
			var secondChild:FlxNode;
			var firstGrandChild:FlxNode;
			var secondGrandChild:FlxNode;
			
			var dw:Int = nodeToInsert.width - insertWidth;
			var dh:Int = nodeToInsert.height - insertHeight;
			
			if (dw > dh) // divide horizontally
			{
				firstChild = new FlxNode(new Rectangle(nodeToInsert.x, nodeToInsert.y, insertWidth, nodeToInsert.height));
				secondChild = new FlxNode(new Rectangle(nodeToInsert.x + insertWidth, nodeToInsert.y, nodeToInsert.width - insertWidth, nodeToInsert.height));
				
				firstGrandChild = new FlxNode(new Rectangle(firstChild.x, firstChild.y, insertWidth, insertHeight), data, key);
				secondGrandChild = new FlxNode(new Rectangle(firstChild.x, firstChild.y + insertHeight, insertWidth, firstChild.height - insertHeight));
			}
			else // divide vertically
			{
				firstChild = new FlxNode(new Rectangle(nodeToInsert.x, nodeToInsert.y, nodeToInsert.width, insertHeight));
				secondChild = new FlxNode(new Rectangle(nodeToInsert.x, nodeToInsert.y + insertHeight, nodeToInsert.width, nodeToInsert.height - insertHeight));
				
				firstGrandChild = new FlxNode(new Rectangle(firstChild.x, firstChild.y, insertWidth, insertHeight), data, key);
				secondGrandChild = new FlxNode(new Rectangle(firstChild.x + insertWidth, firstChild.y, firstChild.width - insertWidth, insertHeight));
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
	public function getNodeByKey(key:String):FlxNode
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
	public function getNodeByBitmap(bitmap:BitmapData):FlxNode
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
		
		var node:FlxNode;
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
		_tempStorage = new Array<TempAtlasObj>();
	}
	
	/**
	 * Adds new object to queue for later creation of new node
	 * @param	data	bitmapData to hold
	 * @param	key		"name" of bitmapData
	 */
	public function addToQueue(data:BitmapData, key:String):Void
	{
		if (_tempStorage == null)
		{
			_tempStorage = new Array<TempAtlasObj>();
		}
		
		_tempStorage.push({bmd: data, keyStr: key});
	}
	
	/**
	 * Adds all objects in "queue" to existing atlas. Doesn't erase any node
	 */
	public function generateAtlasFromQueue():Void
	{
		if (_tempStorage != null)
		{
			var bitmaps:Array<BitmapData> = new Array<BitmapData>();
			var keys:Array<String> = new Array<String>();
			for (obj in _tempStorage)
			{
				bitmaps.push(obj.bmd);
				keys.push(obj.keyStr);
			}
			addNodes(bitmaps, keys);
			_tempStorage = null;
		}
	}
	
	/**
	 * Destroys atlas. Use only if you want to clear memory and don't need this atlas anymore
	 */
	public function destroy():Void
	{
		_tempStorage = null;
		deleteSubtree(root);
		root = null;
		if (atlasBitmapData != null)	
		{
			atlasBitmapData.dispose();
		}
		atlasBitmapData = null;
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
		
		root = new FlxNode(new Rectangle(0, 0, rootWidth, rootHeight));
		atlasBitmapData.fillRect(root.rect, FlxColor.TRANSPARENT);
		nodes = new Map<String, FlxNode>();
	}
	
	/**
	 * Gets cloned atlas.
	 * @return	atlas clone
	 */
	public function clone():FlxAtlas
	{
		var cloneAtlas:FlxAtlas = new FlxAtlas(this.width, this.height, this.borderX, this.borderY);
		cloneAtlas.createQueue();
		for (node in nodes)
		{
			cloneAtlas.addToQueue(node.item, node.key);
		}
		cloneAtlas.generateAtlasFromQueue();
		return cloneAtlas;
	}
	
	private function deleteSubtree(node:FlxNode):Void
	{
		if (node != null)
		{
			if (node.left != null) deleteSubtree(node.left);
			if (node.right != null) deleteSubtree(node.right);
			node.destroy();
		}
	}
	
	// Internal iteration method
	private function findNodeToInsert(insertWidth:Int, insertHeight:Int):FlxNode
	{
		// Node stack
		var stack:Array<FlxNode> = new Array<FlxNode>();
		// Current node
		var current:FlxNode = root;
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