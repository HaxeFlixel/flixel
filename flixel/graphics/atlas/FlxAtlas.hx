package flixel.graphics.atlas;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxRect;
import flixel.util.FlxBitmapDataUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.system.frontEnds.BitmapFrontEnd;

// TODO: generate json file for atlas

/**
 * Class for packing multiple images in big one and generating frame data for each of them 
 * so you can easily load regions of atlas in sprites and tilemaps as a source of graphic
 */
class FlxAtlas implements IFlxDestroyable
{	
	/**
	 * Root node of atlas
	 */
	public var root(default, null):FlxNode;
	
	/**
	 * Name of this atlas, used as a key in bitmap cache
	 */
	public var name(default, null):String;
	
	public var nodes(default, null):Map<String, FlxNode>;
	
	/**
	 * BitmapData of this atlas, combines all images in big one
	 */
	public var bitmapData(get, set):BitmapData;
	
	/**
	 * Offsets between nodes
	 */
	public var border(default, null):Int = 1;
	
	/**
	 * Total width of atlas
	 */
	public var width(default, null):Int = 1; // TODO: add getter
	/**
	 * Total height of atlas
	 */
	public var height(default, null):Int = 1; // TODO: add getter
	
	/**
	 * Whether the size of this atlas should be the power of 2 or not.
	 */
	public var powerOf2(default, set):Bool = false;
	
	private var _bitmapData:BitmapData;
	
	/**
	 * Internal storage for building atlas from queue
	 */
	private var _tempStorage:Array<TempAtlasObj>;
	
	/**
	 * Atlas constructor
	 * @param	name		the name of this atlas. It will be used for caching bitmapdata of this atlas.
	 * @param	powerOf2	whether the size of this atlas should be the power of 2 or not.
	 * @param	border		gap between nodes to insert.
	 */
	public function new(name:String, powerOf2:Bool = false, border:Int = 1) 
	{
		nodes = new Map<String, FlxNode>();
		this.name = name;
		
		root = new FlxNode(new FlxRect(0, 0, width, height), this);
		this.powerOf2 = powerOf2;
		this.border = border;
	}
	
	/**
	 * Simply adds new node to atlas.
	 * @param	Graphic	Image to store. Could be BitmapData, String (key from OpenFl asset cache) or Class<Dynamic>.
	 * @param	Key		Image name, optional. You can ommit it if you pass String or Class<Dynamic> as Graphic source
	 * @return			Newly created and added node, or null if there is no place for it.
	 */
	public function addNode(Graphic:FlxGraphicSource, ?Key:String):FlxNode
	{
		var key:String = FlxAssets.resolveKey(Graphic, Key);
		
		if (key == null) 
			return null;
		
		if (hasNodeWithName(key) == true)
			return nodes.get(key);
		
		var data:BitmapData = FlxAssets.resolveBitmapData(Graphic);
		
		if (data == null)	
			return null;
		
		// TODO: place node in root...
		if (root.left == null || root.right == null)
			return increaseAtlas(data, key);
		
		var insertWidth:Int = data.width + border;
		var insertHeight:Int = data.height + border;
		
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
				firstChild = new FlxNode(new FlxRect(nodeToInsert.x, nodeToInsert.y, insertWidth, nodeToInsert.height), this);
				secondChild = new FlxNode(new FlxRect(nodeToInsert.x + insertWidth, nodeToInsert.y, nodeToInsert.width - insertWidth, nodeToInsert.height), this);
				
				firstGrandChild = new FlxNode(new FlxRect(firstChild.x, firstChild.y, insertWidth, insertHeight), this, true, key);
				secondGrandChild = new FlxNode(new FlxRect(firstChild.x, firstChild.y + insertHeight, insertWidth, firstChild.height - insertHeight), this);
			}
			else // divide vertically
			{
				firstChild = new FlxNode(new FlxRect(nodeToInsert.x, nodeToInsert.y, nodeToInsert.width, insertHeight), this);
				secondChild = new FlxNode(new FlxRect(nodeToInsert.x, nodeToInsert.y + insertHeight, nodeToInsert.width, nodeToInsert.height - insertHeight), this);
				
				firstGrandChild = new FlxNode(new FlxRect(firstChild.x, firstChild.y, insertWidth, insertHeight), this, true, key);
				secondGrandChild = new FlxNode(new FlxRect(firstChild.x + insertWidth, firstChild.y, firstChild.width - insertWidth, insertHeight), this);
			}
			
			firstChild.left = firstGrandChild;
			firstChild.right = secondGrandChild;
			
			nodeToInsert.left = firstChild;
			nodeToInsert.right = secondChild;
			
			bitmapData.copyPixels(data, data.rect, firstGrandChild.point);
			
			nodes.set(key, firstGrandChild);
			
			return firstGrandChild;
		}
		
		// TODO: increase the size of atlas
		
		// TODO: continue from here...
		
		return increaseAtlas(data, key, true);
	}
	
	private function increaseAtlas(data:BitmapData, key:String, expand:Bool = false):FlxNode
	{
		var insertWidth:Int = data.width + border;
		var insertHeight:Int = data.height + border;
		
		if (root.left == null)
		{
			root.left = new FlxNode(new FlxRect(0, 0, insertWidth, insertHeight), this, true, key);
			// TODO: call resize here...
			_bitmapData = new BitmapData(insertWidth, insertHeight, true, FlxColor.TRANSPARENT);
			_bitmapData.copyPixels(data, data.rect, root.left.point);
			width = insertWidth;
			height = insertHeight;
			// end of todo
			nodes.set(key, root.left);
			return root.left;
		}
		
		// helpers for makinkg decision on how to insert new node
		var addRightWidth:Int = root.width + insertWidth;
		var addRightHeight:Int = Std.int(Math.max(root.height, insertHeight));
		var addRightArea:Int = addRightWidth * addRightHeight;
		var addBottomWidth:Int = Std.int(Math.max(root.width, insertWidth));
		var addBottomHeight:Int = root.height + insertHeight;
		var addBottomArea:Int = addBottomWidth * addBottomHeight;
		var temp:FlxNode;
		
		if (expand)
		{
			temp = root;
			root = new FlxNode(new FlxRect(0, 0, temp.width, temp.height), this, false);
			root.left = temp;
			root.right = null; // just to be sure :)
		}
		
		if (root.right == null)
		{
			// TODO: check everything here...
			// TODO: remove false from FlxNode constructor calls...
			// TODO: maybe change node's rect constructor argument from Rectangle to FlxRect...
			
			// decide how to insert new node
			if (addBottomArea >= addRightArea)
			{
				// add node to the right
				root.right = new FlxNode(new FlxRect(root.left.width, 0, insertWidth, insertHeight), this, true, key);
				
				width = root.width = addRightWidth; // TODO: remove atlas width
				height = root.height = addRightHeight; // TODO: remove atlas height
				
				// add empty node if there is empty space in atlas
				if (root.right.height > root.left.height)
				{
					temp = root.left;
					root.left = new FlxNode(new FlxRect(0, 0, temp.width, addRightHeight), this, false);
					root.left.left = temp;
					root.left.right = new FlxNode(new FlxRect(0, temp.height, temp.width, addRightHeight - temp.height), this, false);
				}
				else if (root.right.height < root.left.height)
				{
					temp = root.right;
					root.right = new FlxNode(new FlxRect(temp.x, 0, temp.width, addRightHeight), this, false);
					root.right.left = temp;
					root.right.right = new FlxNode(new FlxRect(temp.x, temp.height, temp.width, addRightHeight - temp.height), this, false);
				}
			}
			else
			{
				// add node at the bottom
				root.right = new FlxNode(new FlxRect(0, root.left.height, insertWidth, insertHeight), this, true, key);
				
				width = root.width = addBottomWidth;
				height = root.height = addBottomHeight;
				
				// add empty node if there is empty space in atlas
				if (root.right.width > root.left.width)
				{
					temp = root.left;
					root.left = new FlxNode(new FlxRect(0, 0, addBottomWidth, temp.height), this, false);
					root.left.left = temp;
					root.left.right = new FlxNode(new FlxRect(temp.width, 0, addBottomWidth - temp.width, temp.height), this, false);
				}
				else if (root.right.width < root.left.width)
				{
					temp = root.right;
					root.right = new FlxNode(new FlxRect(0, temp.y, addBottomWidth, addBottomHeight - temp.height), this, false);
					root.right.left = temp;
					root.right.right = new FlxNode(new FlxRect(temp.width, temp.y, addBottomWidth - temp.width, temp.height), this, false);
				}
			}
			
			// TODO: call resize here...
			
			// TODO: check this line...
			_bitmapData.copyPixels(data, data.rect, root.right.point);
			// end of todo...
			
			// TODO: wrap existing nodes and add new one...
			
			nodes.set(key, root.right);
			return root.right;
		}
		
		return null;
	}
	
	/**
	 * Generates new bitmapdata with spaces between tiles, adds this bitmapdata to this atlas, 
	 * generates TileFrames object for added node and returns it. Could be usefull for tilemaps.
	 * 
	 * @param	Graphic			Source image for node, where spaces will be inserted (could be BitmapData, String or Class<Dynamic>).
	 * @param	Key			Optional key for image
	 * @param	tileSize		The size of tile in spritesheet
	 * @param	tileSpacing	Offsets to add in spritesheet between tiles
	 * @param	region			Region of source image to use as a source graphic
	 * @return	Generated TileFrames for added node
	 */
	public function addNodeWithSpacings(Graphic:FlxGraphicSource, ?Key:String, tileSize:FlxPoint, tileSpacing:FlxPoint, region:FlxRect = null):FlxTileFrames
	{
		var key:String = FlxAssets.resolveKey(Graphic, Key);
		
		if (key == null) 
			return null;
		
		key = FlxG.bitmap.getKeyWithSpacings(key, tileSize, tileSpacing, region);
		
		if (hasNodeWithName(key) == true)
			return nodes.get(key).getTileFrames(tileSize, tileSpacing);
		
		var data:BitmapData = FlxAssets.resolveBitmapData(Graphic);
		
		if (data == null) 
			return null;
		
		var nodeData:BitmapData = FlxBitmapDataUtil.addSpacing(data, tileSize, tileSpacing, region);
		var node:FlxNode = addNode(nodeData, key);
		
		if (node == null) 
			return null;
		
		// todo: fix this, since this will throw error
		return node.getTileFrames(tileSize, tileSpacing);
	}
	
	/**
	 * Gets AtlasFrames object for this atlas.
	 * It caches graphic of this atlas and generates AtlasFrames if it is not exist yet.
	 * @return AtlasFrames for this atlas
	 */
	public function getAtlasFrames():FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(this.bitmapData, false, name);
		
		var atlasFrames:FlxAtlasFrames = null;
		if (graphic.atlasFrames == null)
			graphic.atlasFrames = atlasFrames = new FlxAtlasFrames(graphic);
		
		var node:FlxNode;
		for (key in nodes.keys())
		{
			node = nodes.get(key);
			// if the node is filled and AtlasFrames does not contain image of the node, then we should add it
			if (node.filled && !atlasFrames.framesHash.exists(key))
			{
				var frame:FlxRect = new FlxRect(node.x, node.y, node.width - border, node.height - border);
				var sourceSize:FlxPoint = FlxPoint.get(node.width - border, node.height - border);
				var offset:FlxPoint = FlxPoint.get(0, 0);
				
				atlasFrames.addAtlasFrame(frame, sourceSize, offset, node.key, 0); 
			}
		}
		
		return graphic.atlasFrames;
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
	public function getNode(key:String):FlxNode
	{
		return nodes.get(key);
	}
	
	/**
	 * Optimized version of method for adding multiple nodes to atlas. 
	 * Uses less atlas' area (it sorts images by the size before adding them to atlas)
	 * @param	bitmaps		BitmapData's to insert
	 * @param	keys		Names of these bitmapData's
	 * @return				true if ALL nodes were added successfully.
	 */
	public function addNodes(bitmaps:Array<BitmapData>, keys:Array<String>):FlxAtlas
	{
		var numKeys:Int = keys.length;
		var numBitmaps:Int = bitmaps.length;
		
		if (numBitmaps != numKeys)
			return null;
		
		var sortedBitmaps:Array<BitmapData> = bitmaps.slice(0, bitmaps.length);
		sortedBitmaps.sort(bitmapSorter);
		
		var node:FlxNode;
		var result:Bool = true;
		var index:Int;
		for (i in 0...(numBitmaps))
		{
			index = bitmaps.indexOf(sortedBitmaps[i]);
			node = addNode(sortedBitmaps[i], keys[index]);
		}
		
		return this;
	}
	
	/**
	 * Internal method for sorting bitmaps
	 */
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
	 * Creates new "queue" for adding new nodes.
	 * This method should be used with addToQueue() and generateFromQueue() methods:
	 * - first, you create queue, like atlas.createQueue();
	 * - second, you add several bitmaps in queue: atlas.addToQueue(bmd1, "key1").addToQueue(bmd2, "key2");
	 * - third, you actually bake those bitmaps on atlas: atlas.generateFromQueue();
	 */
	public function createQueue():FlxAtlas
	{
		if (_tempStorage != null)	
			_tempStorage = null;
		
		_tempStorage = new Array<TempAtlasObj>();
		return this;
	}
	
	/**
	 * Adds new object to queue for later creation of new node
	 * @param	data	BitmapData to bake on atlas
	 * @param	key		"name" of BitmapData. You'll use it as a key for accessing created node.
	 */
	public function addToQueue(data:BitmapData, key:String):FlxAtlas
	{
		if (_tempStorage == null)
			_tempStorage = new Array<TempAtlasObj>();
		
		_tempStorage.push({ bmd: data, keyStr: key });
		return this;
	}
	
	/**
	 * Adds all objects in "queue" to existing atlas. Doesn't erase any node
	 */
	public function generateFromQueue():FlxAtlas
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
		
		return this;
	}
	
	/**
	 * Destroys atlas. Use only if you want to clear memory and don't need this atlas anymore, 
	 * since it disposes atlasBitmapData and removes it from cache
	 */
	public function destroy():Void
	{
		FlxG.bitmap.remove(name);
		_tempStorage = null;
		deleteSubtree(root);
		root = null;
		_bitmapData = FlxDestroyUtil.dispose(_bitmapData);
		nodes = null;
	}
	
	/**
	 * Clears all data in atlas. Use it when you want reuse this atlas.
	 * WARNING: it will destroy graphic of this image, so you can get null pointer exception if you're using it for your sprites.
	 */
	public function clear():Void
	{
		var rootWidth:Int = root.width;
		var rootHeight:Int = root.height;
		deleteSubtree(root);
		// TODO: change root size (make it 1 by 1 again)
		root = new FlxNode(new FlxRect(0, 0, rootWidth, rootHeight), this);
		bitmapData.fillRect(bitmapData.rect, FlxColor.TRANSPARENT);
		// TODO: destroy graphic and frames
		var graphic:FlxGraphic = FlxG.bitmap.get(name);
		graphic.atlasFrames = FlxDestroyUtil.destroy(graphic.atlasFrames);
		nodes = new Map<String, FlxNode>();
	}
	
	/**
	 * Let you get frame data for this atlas,
	 * but won't let you to add any new image to it.
	 * 
	 * @param	trim	whether to trim this atlas' BitmapData or not.
	 */
	public function finalize(trim:Bool = true):Void
	{
		/*if (trim)
		{
			var contentRect:FlxRect = new FlxRect();
			
			for (node in nodes)
			{
				contentRect.union(node.contentRect);
			}
			
			var finalWidth:Int = Std.int(contentRect.width);
			var finalHeight:Int = Std.int(contentRect.height);
			
			var finalBD:BitmapData = new BitmapData(finalWidth, finalHeight, true, FlxColor.TRANSPARENT);
			finalBD.copyPixels(bitmapData, finalBD.rect, new Point());
			bitmapData.dispose();
			bitmapData = finalBD;
			width = finalWidth;
			height = finalHeight;
		}*/
	}
	
	/**
	 * Calculates bounding rectangle for all nodes in this atlas
	 */
	/*private function getContentRect():FlxRect
	{
		var contentRect:FlxRect = new FlxRect();
		
		for (node in nodes)
			contentRect.union(node.contentRect);
		
		return contentRect;
	}*/
	
	private function updateSize():Void
	{
		// TODO: implement it...
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
		
		var canPlaceRight:Bool = false;
		var canPlaceLeft:Bool = false;
		// Main loop
		while (true)
		{
			// Look into current node
			if (current.isEmpty && current.canPlace(insertWidth, insertHeight))
			{
				return current;
			}
			// Move to next node
			canPlaceRight = (current.right != null && current.right.canPlace(insertWidth, insertHeight));
			canPlaceLeft = (current.left != null && current.left.canPlace(insertWidth, insertHeight));
			if (canPlaceRight && canPlaceLeft)
			{
				stack.push(current.right);
				current = current.left;
			}
			else if (canPlaceLeft)
			{
				current = current.left;
			}
			else if (canPlaceRight)
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
	
	private inline function get_width():Int
	{
		return root.width;
	}
	
	private inline function get_height():Int
	{
		return root.height;
	}
	
	private function set_powerOf2(value:Bool):Bool
	{
		// TODO: implement it...
		
		return value;
	}
	
	private function get_bitmapData():BitmapData
	{
		if (_bitmapData == null)
			_bitmapData = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
			
		return _bitmapData;
	}
	
	private function set_bitmapData(value:BitmapData):BitmapData
	{
		if (value != null)
		{
			// update graphic bitmapData
			var key:String = FlxG.bitmap.findKeyForBitmap(value);
			if (key != null)
			{
				FlxG.bitmap.get(key).bitmap = value;
			}
		}
		
		return _bitmapData = value;
	}
}

typedef TempAtlasObj = {
	public var bmd:BitmapData;
	public var keyStr:String;
}