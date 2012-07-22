package org.flixel.system.tileSheet.atlasgen;

import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;
/**
 * Atlas class
 * @author Zaphod
 */
 
class Atlas
{
	public var tempStorage:Array<TempAtlasObj>;
	
	/**
	 * Root node of atlas
	 */
	public var root:Node;
	
	public var nodes:Hash<Node>;
	public var atlasBitmapData:BitmapData;
	
	public var borderX:Int;
	public var borderY:Int;
	
	/**
	 * Atlas constructor
	 * @param	width		atlas width
	 * @param	height		atlas height
	 * @param	borderX		horizontal distance between nodes
	 * @param	borderY		vertical distance between nodes
	 */
	public function new(width:Int, height:Int, ?borderX:Int = 0, ?borderY:Int = 0) 
	{
		root = new Node(new Rectangle(0, 0, width, height));
		#if !neko
		atlasBitmapData = new BitmapData(width, height, true, 0x00000000);
		#else
		atlasBitmapData = new BitmapData(width, height, true, {rgb: 0x000000, a: 0x00});
		#end
		nodes = new Hash<Node>();
		
		this.borderX = borderX;
		this.borderY = borderY;
	}
	
	/**
	 * This method could optimize atlas after adding new nodes with addNode() method
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
	 * Resizes atlas to new dimensions
	 */
	public function resize(newWidth:Int, newHeight:Int):Void
	{
		root.rect.width = newWidth;
		root.rect.height = newHeight;
		atlasBitmapData.dispose();
		#if !neko
		atlasBitmapData = new BitmapData(newWidth, newHeight, true, 0x00000000);
		#else
		atlasBitmapData = new BitmapData(newWidth, newHeight, true, { rgb: 0x000000, a: 0x00 } );
		#end
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
				firstChild = new Node(new Rectangle(nodeToInsert.x, nodeToInsert.y, insertWidth, nodeToInsert.height));
				secondChild = new Node(new Rectangle(nodeToInsert.x + insertWidth, nodeToInsert.y, nodeToInsert.width - insertWidth, nodeToInsert.height));
				
				firstGrandChild = new Node(new Rectangle(firstChild.x, firstChild.y, insertWidth, insertHeight), data, key);
				secondGrandChild = new Node(new Rectangle(firstChild.x, firstChild.y + insertHeight, insertWidth, firstChild.height - insertHeight));
			}
			else // divide vertically
			{
				firstChild = new Node(new Rectangle(nodeToInsert.x, nodeToInsert.y, nodeToInsert.width, insertHeight));
				secondChild = new Node(new Rectangle(nodeToInsert.x, nodeToInsert.y + insertHeight, nodeToInsert.width, nodeToInsert.height - insertHeight));
				
				firstGrandChild = new Node(new Rectangle(firstChild.x, firstChild.y, insertWidth, insertHeight), data, key);
				secondGrandChild = new Node(new Rectangle(firstChild.x + insertWidth, firstChild.y, firstChild.width - insertWidth, insertHeight));
			}
			
			firstChild.left = firstGrandChild;
			firstChild.right = secondGrandChild;
			
			nodeToInsert.left = firstChild;
			nodeToInsert.right = secondChild;
			
			atlasBitmapData.copyPixels(data, data.rect, new Point(firstGrandChild.x, firstGrandChild.y));
			
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
	
	public function get_height():Int
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
	 * Destroys atlas. Use only if you want to clear memory and don't need that atlas anymore
	 */
	public function destroy():Void
	{
		tempStorage = null;
		
		deleteSubtree(root);
		root = null;
		atlasBitmapData.dispose();
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
		
		root = new Node(new Rectangle(0, 0, rootWidth, rootHeight));
		#if !neko
		atlasBitmapData.fillRect(root.rect, 0x00000000);
		#else
		atlasBitmapData.fillRect(root.rect, { rgb: 0x000000, a: 0x00 } );
		#end
		nodes = new Hash<Node>();
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