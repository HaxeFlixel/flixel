package flixel.graphics.atlas;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.util.FlxBitmapDataUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.system.frontEnds.BitmapFrontEnd;
import openfl.geom.Matrix;

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
	public var width(get, null):Int;
	/**
	 * Total height of atlas
	 */
	public var height(get, null):Int;
	
	public var maxWidth(default, set):Int = 0;
	
	public var maxHeight(default, set):Int = 0;
	
	public var rotate(default, null):Bool = false;
	
	/**
	 * Whether the size of this atlas should be the power of 2 or not.
	 */
	public var powerOfTwo(default, null):Bool = false; // TODO: add setter for this property
	
	private var _bitmapData:BitmapData;
	
	/**
	 * Internal storage for building atlas from queue
	 */
	private var _tempStorage:Array<TempAtlasObj>;
	
	/**
	 * Atlas constructor
	 * @param	name		the name of this atlas. It will be used for caching bitmapdata of this atlas.
	 * @param	powerOfTwo	whether the size of this atlas should be the power of 2 or not.
	 * @param	border		gap between nodes to insert.
	 * @param	rotate		whether to rotate added images for less atlas size
	 * @param	maxWidth	max width of atlas
	 * @param	maxHeight	max height of atlas
	 */
	public function new(name:String, powerOfTwo:Bool = false, border:Int = 1, rotate:Bool = false, maxWidth:Int = 0, maxHeight:Int = 0)
	{
		nodes = new Map<String, FlxNode>();
		this.name = name;
		
		root = new FlxNode(new FlxRect(0, 0, 1, 1), this);
		this.powerOfTwo = powerOfTwo;
		this.border = border;
		this.maxWidth = maxWidth;
		this.maxHeight = maxHeight;
		this.rotate = rotate;
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
		
		// check if we can add nodes right into root
		if (root.left == null)
			return insertFirstNodeInRoot(data, key);
		
		if (root.right == null)
		{
			return expand(data, key);
		}
		
		// try to find enough empty space in atlas
		var inserted:FlxNode = tryInsert(data, key);
		if (inserted != null)
			return inserted;
		
		// if there is no empty space we need to wrap existing nodes and add new one on the right...
		wrapRoot();
		return expand(data, key);
	}
	
	private function wrapRoot():Void
	{
		var temp:FlxNode = root;
		root = new FlxNode(new FlxRect(0, 0, temp.width, temp.height), this);
		root.left = temp;
	}
	
	private function tryInsert(data:BitmapData, key:String):FlxNode
	{
		var insertWidth:Int = data.width + border;
		var insertHeight:Int = data.height + border;
		
		var rotateNode:Bool = false;
		var nodeToInsert:FlxNode = findNodeToInsert(insertWidth, insertHeight);
		
		if (nodeToInsert == null && rotate)
		{
			nodeToInsert = findNodeToInsert(insertHeight, insertWidth);
			rotateNode = true;
			var temp:Int = insertWidth;
			insertWidth = insertHeight;
			insertHeight = temp;
		}
		
		if (nodeToInsert != null)
		{
			var horizontally:Bool = needToDivideHorizontally(nodeToInsert, insertWidth, insertHeight);
			return divideNode(nodeToInsert, insertWidth, insertHeight, horizontally, data, key, rotateNode);
		}
		
		return null;
	}
	
	private function needToDivideHorizontally(nodeToDivide:FlxNode, insertWidth:Int, insertHeight:Int):Bool
	{
		var dw:Int = nodeToDivide.width - insertWidth;
		var dh:Int = nodeToDivide.height - insertHeight;
		
		return (dw > dh); // divide horizontally if true, vertically if false
	}
	
	private function divideNode(nodeToDivide:FlxNode, insertWidth:Int, insertHeight:Int, divideHorizontally:Bool, firstGrandChildData:BitmapData = null, firstGrandChildKey:String = null, firstGrandChildRotated:Bool = false):FlxNode
	{
		if (nodeToDivide != null)
		{
			var firstChild:FlxNode = null;
			var secondChild:FlxNode = null;
			var firstGrandChild:FlxNode = null;
			var secondGrandChild:FlxNode = null;
			var firstGrandChildFilled:Bool = (firstGrandChildKey != null);
			
			if (divideHorizontally) // divide horizontally
			{
				firstChild = new FlxNode(new FlxRect(nodeToDivide.x, nodeToDivide.y, insertWidth, nodeToDivide.height), this);
				
				if (nodeToDivide.width - insertWidth > 0)
				{
					secondChild = new FlxNode(new FlxRect(nodeToDivide.x + insertWidth, nodeToDivide.y, nodeToDivide.width - insertWidth, nodeToDivide.height), this);
				}
				
				firstGrandChild = new FlxNode(new FlxRect(firstChild.x, firstChild.y, insertWidth, insertHeight), this, firstGrandChildFilled, firstGrandChildKey, firstGrandChildRotated);
				
				if (firstChild.height - insertHeight > 0)
				{
					secondGrandChild = new FlxNode(new FlxRect(firstChild.x, firstChild.y + insertHeight, insertWidth, firstChild.height - insertHeight), this);
				}
				
			}
			else // divide vertically
			{
				firstChild = new FlxNode(new FlxRect(nodeToDivide.x, nodeToDivide.y, nodeToDivide.width, insertHeight), this);
				
				if (nodeToDivide.height - insertHeight > 0)
				{
					secondChild = new FlxNode(new FlxRect(nodeToDivide.x, nodeToDivide.y + insertHeight, nodeToDivide.width, nodeToDivide.height - insertHeight), this);
				}
				
				firstGrandChild = new FlxNode(new FlxRect(firstChild.x, firstChild.y, insertWidth, insertHeight), this, firstGrandChildFilled, firstGrandChildKey, firstGrandChildRotated);
				
				if (firstChild.width - insertWidth > 0)
				{
					secondGrandChild = new FlxNode(new FlxRect(firstChild.x + insertWidth, firstChild.y, firstChild.width - insertWidth, insertHeight), this);
				}
			}
			
			firstChild.left = firstGrandChild;
			firstChild.right = secondGrandChild;
			
			nodeToDivide.left = firstChild;
			nodeToDivide.right = secondChild;
			
			// bake data in atlas
			if (firstGrandChildKey != null && firstGrandChildData != null)
			{
				expandBitmapData();
				
				if (firstGrandChildRotated)
				{
					var matrix:Matrix = FlxMatrix.matrix;
					matrix.identity();
					matrix.rotate(Math.PI / 2);
					matrix.translate(firstGrandChildData.height + firstGrandChild.x, firstGrandChild.y);
					_bitmapData.draw(firstGrandChildData, matrix);
				}
				else
				{
					var point:Point = FlxPoint.point;
					point.setTo(firstGrandChild.x, firstGrandChild.y);
					_bitmapData.copyPixels(firstGrandChildData, firstGrandChildData.rect, point);
				}
				
				addNodeToAtlasFrames(firstGrandChild);
				nodes.set(firstGrandChildKey, firstGrandChild);
			}
			
			return firstGrandChild;
		}
		
		return null;
	}
	
	private function insertFirstNodeInRoot(data:BitmapData, key:String):FlxNode
	{
		if (root.left == null)
		{
			var insertWidth:Int = data.width + border;
			var insertHeight:Int = data.height + border;
			
			var rootWidth:Int = insertWidth;
			var rootHeight:Int = insertHeight;
			
			if (powerOfTwo)
			{
				rootWidth = getNextPowerOf2(rootWidth);
				rootHeight = getNextPowerOf2(rootHeight);
			}
			
			if ((maxWidth > 0 && rootWidth > maxWidth) || (maxHeight > 0 && rootHeight > maxHeight))
			{
				// TODO: throw error with info (here and in other places where we can return null)...
				throw "Can't insert node " + key + " with the size of (" + data.width + "; " + data.height + ") in atlas " + name + " with the max size of (" + maxWidth + "; " + maxHeight + ") and powerOfTwo: " + powerOfTwo;
				return null;
			}
			
			root.width = rootWidth;
			root.height = rootHeight;
			
			var horizontally:Bool = needToDivideHorizontally(root, insertWidth, insertHeight);
			return divideNode(root, insertWidth, insertHeight, horizontally, data, key);
		}
		
		return null;
	}
	
	private function expand(data:BitmapData, key:String):FlxNode
	{
		if (root.right == null)
		{
			var insertWidth:Int = data.width + border;
			var insertHeight:Int = data.height + border;
			
			// helpers for makinkg decision on how to insert new node
			var addRightWidth:Int = root.width + insertWidth;
			var addRightHeight:Int = Std.int(Math.max(root.height, insertHeight));
			
			var addBottomWidth:Int = Std.int(Math.max(root.width, insertWidth));
			var addBottomHeight:Int = root.height + insertHeight;
			
			var addRightWidthRotate:Int = rotate ? (root.width + insertHeight) : addRightWidth;
			var addRightHeightRotate:Int = rotate ? Std.int(Math.max(root.height, insertWidth)) : addRightHeight;
			
			var addBottomWidthRotate:Int = rotate ? Std.int(Math.max(root.width, insertHeight)) : addBottomWidth;
			var addBottomHeightRotate:Int = rotate ? (root.height + insertWidth) : addBottomHeight;
			
			if (powerOfTwo)
			{
				addRightWidth = getNextPowerOf2(addRightWidth);
				addRightHeight = getNextPowerOf2(addRightHeight);
				addBottomWidth = getNextPowerOf2(addBottomWidth);
				addBottomHeight = getNextPowerOf2(addBottomHeight);
				
				addRightWidthRotate = rotate ? getNextPowerOf2(addRightWidthRotate) : addRightWidth;
				addRightHeightRotate = rotate ? getNextPowerOf2(addRightHeightRotate) : addRightHeight;
				addBottomWidthRotate = rotate ? getNextPowerOf2(addBottomWidthRotate) : addBottomWidth;
				addBottomHeightRotate = rotate ? getNextPowerOf2(addBottomHeightRotate) : addBottomHeight;
			}
			
			// checks for the max size
			var canExpandRight:Bool = true;
			var canExpandBottom:Bool = true;
			
			var canExpandRightRotate:Bool = rotate;
			var canExpandBottomRotate:Bool = rotate;
			
			if ((maxWidth > 0 && addRightWidth > maxWidth) || (maxHeight > 0 && addRightHeight > maxHeight))
				canExpandRight = false;
			
			if ((maxWidth > 0 && addBottomWidth > maxWidth) || (maxHeight > 0 && addBottomHeight > maxHeight))
				canExpandBottom = false;
			
			if ((maxWidth > 0 && addRightWidthRotate > maxWidth) || (maxHeight > 0 && addRightHeightRotate > maxHeight))
				canExpandRightRotate = false;
			
			if ((maxWidth > 0 && addBottomWidthRotate > maxWidth) || (maxHeight > 0 && addBottomHeightRotate > maxHeight))
				canExpandBottomRotate = false;
			
			if (canExpandRight == false && canExpandBottom == false && canExpandRightRotate == false && canExpandBottomRotate == false)
				return null; // can't expand in any direction
			
			// calculate area of result atlas for various cases
			// the case with less area will be chosen
			var addRightArea:Int = addRightWidth * addRightHeight;
			var addBottomArea:Int = addBottomWidth * addBottomHeight;
			
			var addRightAreaRotate:Int = addRightWidthRotate * addRightHeightRotate;
			var addBottomAreaRotate:Int = addBottomWidthRotate * addBottomHeightRotate;	
			
			var rotateRight:Bool = false;
			var rotateBottom:Bool = false;
			var rotateNode:Bool = false;
			
			if ((canExpandRight && canExpandRightRotate && addRightArea > addRightAreaRotate) || (!canExpandRight && canExpandRightRotate))
			{
				addRightArea = addBottomAreaRotate;
				addRightWidth = addRightWidthRotate;
				addRightHeight = addRightHeightRotate;
				canExpandRight = true;
				rotateRight = true;
			}
			
			if ((canExpandBottom && canExpandBottomRotate && addBottomArea > addBottomAreaRotate) || (!canExpandRight && canExpandBottomRotate))
			{
				addBottomArea = addBottomAreaRotate;
				addBottomWidth = addBottomWidthRotate;
				addBottomHeight = addBottomHeightRotate;
				canExpandBottom = true;
				rotateBottom = true;
			}
			
			if (!canExpandRight && canExpandBottom)
			{
				addRightArea = addBottomArea + 1; // can't expand to the right
				rotateNode = rotateRight;
			}
			else if (canExpandRight && !canExpandBottom)
			{
				addBottomArea = addRightArea + 1; // can't expand to the bottom
				rotateNode = rotateBottom;
			}
			
			var dataNode:FlxNode = null;
			var temp:FlxNode = root;
			var insertNodeWidth:Int = insertWidth;
			var insertNodeHeight:Int = insertHeight;
			
			// decide how to insert new node
			if (addBottomArea >= addRightArea) // add node to the right
			{
				if (rotateRight)
				{
					insertNodeWidth = insertHeight;
					insertNodeHeight = insertWidth;
				}
				
				root = new FlxNode(new FlxRect(0, 0, temp.width + insertNodeWidth, Math.max(temp.height, insertNodeHeight)), this);
				divideNode(root, temp.width, temp.height, true);
				root.left.left = temp;
				dataNode = divideNode(root.right, insertNodeWidth, insertNodeHeight, true, data, key, rotateRight);
				
				if (addRightWidth > root.width || addRightHeight > root.height)
				{
					temp = root;
					root = new FlxNode(new FlxRect(0, 0, addRightWidth, addRightHeight), this);
					divideNode(root, temp.width, temp.height, needToDivideHorizontally(root, temp.width, temp.height));
					root.left.left = temp;
				}
			}
			else // add node at the bottom
			{
				if (rotateBottom)
				{
					insertNodeWidth = insertHeight;
					insertNodeHeight = insertWidth;
				}
				
				root = new FlxNode(new FlxRect(0, 0, Math.max(temp.width, insertNodeWidth), temp.height + insertNodeHeight), this);
				divideNode(root, temp.width, temp.height, false);
				root.left.left = temp;
				dataNode = divideNode(root.right, insertNodeWidth, insertNodeHeight, true, data, key, rotateBottom);
				
				if (addBottomWidth > root.width || addBottomHeight > root.height)
				{
					temp = root;
					root = new FlxNode(new FlxRect(0, 0, addBottomWidth, addBottomHeight), this);
					divideNode(root, temp.width, temp.height, needToDivideHorizontally(root, temp.width, temp.height));
					root.left.left = temp;
				}
			}
			
			return dataNode;
		}
		
		return null;
	}
	
	private function expandBitmapData():Void
	{
		if (_bitmapData != null && _bitmapData.width == root.width && _bitmapData.height == root.height)
		{
			return;
		}
		
		var newBitmapData:BitmapData = new BitmapData(root.width, root.height, true, FlxColor.TRANSPARENT);
		if (_bitmapData != null)
		{
			var point:Point = FlxPoint.point;
			point.setTo(0, 0);
			newBitmapData.copyPixels(_bitmapData, _bitmapData.rect, point);
		}
		
		_bitmapData = FlxDestroyUtil.dispose(_bitmapData);
		bitmapData = newBitmapData;
	}
	
	private function getNextPowerOf2(number:Float):Int
	{
		var powerFloat:Float = Math.log(number) / Math.log(2);
		var powerInt:Float = Std.int(powerFloat);
		
		if (powerFloat - powerInt == 0)
			return Std.int(number);
		
		return Std.int(Math.pow(2, powerInt + 1));
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
		{
			graphic.atlasFrames = new FlxAtlasFrames(graphic);
			atlasFrames = graphic.atlasFrames;
		}
		
		for (node in nodes)
			addNodeToAtlasFrames(node);
		
		return graphic.atlasFrames;
	}
	
	private function addNodeToAtlasFrames(node:FlxNode):Void
	{
		var graphic:FlxGraphic = FlxG.bitmap.get(name);
		if (graphic == null || graphic.atlasFrames == null || node == null)
			return;
		
		var atlasFrames:FlxAtlasFrames = graphic.atlasFrames;
		
		if (node.filled && !atlasFrames.framesHash.exists(node.key))
		{
			var frame:FlxRect = new FlxRect(node.x, node.y, node.width - border, node.height - border);
			var sourceSize:FlxPoint = node.rotated ? FlxPoint.get(node.height - border, node.width - border) : FlxPoint.get(node.width - border, node.height - border);
			var offset:FlxPoint = FlxPoint.get(0, 0);
			var angle:FlxFrameAngle = node.rotated ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;
			atlasFrames.addAtlasFrame(frame, sourceSize, offset, node.key, angle);
		}
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
		FlxG.bitmap.removeIfNoUse(FlxG.bitmap.get(name));
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
		deleteSubtree(root);
		root = new FlxNode(new FlxRect(0, 0, 1, 1), this);
		FlxG.bitmap.removeByKey(name);
		_bitmapData = null;
		nodes = new Map<String, FlxNode>();
	}
	
	/**
	 * Returns atlas data in Spritesheet packer format, where each image represented by line:
	 * "imageName = image.x image.y image.width image.height"
	 */
	// TODO: reimplement it, since spritesheetpacker doesn't support image rotation
	public function getSpriteSheetPackerData():String
	{
		var data:String = "";
		for (node in nodes)
		{
			data += node.key + " = " + node.x + " " + node.y + " " + node.contentWidth + " " + node.contentHeight + "\n";
		}
		return data;
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
	
	private function get_bitmapData():BitmapData
	{
		return _bitmapData;
	}
	
	private function set_bitmapData(value:BitmapData):BitmapData
	{
		if (value != null)
		{
			// update graphic bitmapData
			var graphic:FlxGraphic = FlxG.bitmap.get(name);
			if (graphic != null)
			{
				graphic.bitmap = value;
			}
		}
		
		return _bitmapData = value;
	}
	
	private function set_maxWidth(value:Int):Int
	{
		maxWidth = (value > maxWidth) ? value : maxWidth;
		return maxWidth;
	}
	
	private function set_maxHeight(value:Int):Int
	{
		maxHeight = (value > maxHeight) ? value : maxHeight;
		return maxHeight;
	}
}

typedef TempAtlasObj = {
	public var bmd:BitmapData;
	public var keyStr:String;
}