package flixel.graphics.atlas;

import flash.display.BitmapData;
import flash.geom.Point;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.util.FlxBitmapDataUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.geom.Matrix;

// TODO: rewrite this class again, since it's a total mess again.
// It needs better resize handling.

/**
 * Class for packing multiple images in big one and generating frame data for each of them
 * so you can easily load regions of atlas in sprites and tilemaps as a source of graphic
 */
class FlxAtlas implements IFlxDestroyable
{
	static var point:Point = new Point();
	static var matrix:Matrix = new Matrix();

	/**
	 * Default minimum size for atlases.
	 */
	public static var defaultMinSize:FlxPoint = new FlxPoint(128, 128);

	/**
	 * Default maximum size for atlases.
	 */
	public static var defaultMaxSize:FlxPoint = new FlxPoint(1024, 1024);

	/**
	 * Root node of the atlas.
	 */
	public var root(default, null):FlxNode;

	/**
	 * Name of this atlas, used as a key in the bitmap cache.
	 */
	public var name(default, null):String;

	public var nodes(default, null):Map<String, FlxNode>;

	/**
	 * `BitmapData` of this atlas, combines all images into a big one.
	 */
	public var bitmapData(default, set):BitmapData;

	/**
	 * Graphic for this atlas.
	 */
	public var graphic(get, never):FlxGraphic;

	/**
	 * Whether this atlas should stay in memory after state switch.
	 * Default value if `false`.
	 */
	public var persist(default, set):Bool = false;

	/**
	 * Offsets between nodes.
	 */
	public var border(default, null):Int = 1;

	/**
	 * Total width of the atlas.
	 */
	@:isVar
	public var width(get, set):Int;

	/**
	 * Total height of the atlas.
	 */
	@:isVar
	public var height(get, set):Int;

	/**
	 * Minimum width for this atlas.
	 */
	public var minWidth(default, set):Int = 128;

	/**
	 * Minimum height for this atlas
	 */
	public var minHeight(default, set):Int = 128;

	/**
	 * Maximum width for this atlas.
	 */
	public var maxWidth(default, set):Int = 1024;

	/**
	 * Maximum height for this atlas.
	 */
	public var maxHeight(default, set):Int = 1024;

	/**
	 * Whether to allow image rotation for packing in atlas.
	 */
	public var allowRotation(default, null):Bool = false;

	/**
	 * Whether the size of this atlas should be the power of 2 or not.
	 */
	public var powerOfTwo(default, set):Bool = false;

	var _graphic:FlxGraphic;

	/**
	 * Internal storage for building atlas from queue
	 */
	var _tempStorage:Array<TempAtlasObj>;

	/**
	 * Atlas constructor
	 *
	 * @param   name         The name of this atlas. It will be used for caching `BitmapData` of this atlas.
	 * @param   powerOfTwo   Whether the size of this atlas should be the power of 2 or not.
	 * @param   border       Gap between nodes to insert.
	 * @param   rotate       Whether to rotate added images for less atlas size.
	 * @param   minSize      Min size of atlas.
	 * @param   maxSize      Max size of atlas.
	 */
	public function new(name:String, powerOfTwo:Bool = false, border:Int = 1, rotate:Bool = false, ?minSize:FlxPoint, ?maxSize:FlxPoint)
	{
		nodes = new Map<String, FlxNode>();
		this.name = name;
		this.powerOfTwo = powerOfTwo;
		this.border = border;

		minSize = (minSize != null) ? minSize : defaultMinSize;
		maxSize = (maxSize != null) ? maxSize : defaultMaxSize;

		this.minWidth = Std.int(minSize.x);
		this.minHeight = Std.int(minSize.y);
		this.maxWidth = (maxSize.x > minSize.x) ? Std.int(maxSize.x) : minWidth;
		this.maxHeight = (maxSize.y > minSize.x) ? Std.int(maxSize.y) : minHeight;
		this.allowRotation = rotate;

		initRoot();

		FlxG.signals.preStateCreate.add(onClear);
	}

	function initRoot():Void
	{
		var rootWidth:Int = minWidth;
		var rootHeight:Int = minHeight;

		if (powerOfTwo)
		{
			rootWidth = getNextPowerOfTwo(rootWidth);
			rootHeight = getNextPowerOfTwo(rootHeight);
		}

		root = new FlxNode(FlxRect.get(0, 0, rootWidth, rootHeight), this);
	}

	/**
	 * Adds a new node to the atlas.
	 *
	 * @param   Graphic   Image to store. Could be a `BitmapData`, `String`
	 *                    (key from OpenFL's asset cache) or a `Class<Dynamic>`.
	 * @param   Key       Image name, optional.
	 *                    You can omit it if you pass `String` or `Class<Dynamic>` as a `Graphic` source.
	 * @return  Newly created and added node, or `null` if there is no space for it.
	 */
	public function addNode(Graphic:FlxGraphicSource, ?Key:String):FlxNode
	{
		var key:String = FlxAssets.resolveKey(Graphic, Key);

		if (key == null)
		{
			#if FLX_DEBUG
			throw "addNode can't find the key for specified BitmapData. Please provide not null value as a Key argument.";
			#end
			return null;
		}

		if (hasNodeWithName(key))
			return nodes.get(key);

		var data:BitmapData = FlxAssets.resolveBitmapData(Graphic);

		if (data == null)
		{
			#if FLX_DEBUG
			throw "addNode can't find BitmapData with specified key: " + Graphic + ". Please provide valid value.";
			#end
			return null;
		}

		// check if we can add nodes right into root
		if (root.left == null)
			return insertFirstNodeInRoot(data, key);

		if (root.right == null)
			return expand(data, key);

		// try to find enough empty space in atlas
		var inserted:FlxNode = tryInsert(data, key);
		if (inserted != null)
			return inserted;

		// if there is no empty space we need to wrap existing nodes and add new one on the right...
		wrapRoot();
		return expand(data, key);
	}

	function wrapRoot():Void
	{
		var temp:FlxNode = root;
		root = new FlxNode(FlxRect.get(0, 0, temp.width, temp.height), this);
		root.left = temp;
	}

	function tryInsert(data:BitmapData, key:String):FlxNode
	{
		var insertWidth:Int = data.width + border;
		var insertHeight:Int = data.height + border;

		var rotateNode:Bool = false;
		var nodeToInsert:FlxNode = findNodeToInsert(insertWidth, insertHeight);

		if (allowRotation)
		{
			var nodeToInsertWithRotation = findNodeToInsert(insertHeight, insertWidth);

			if (nodeToInsertWithRotation != null)
			{
				var nodeWithRotationArea:Int = nodeToInsertWithRotation.width * nodeToInsertWithRotation.height;

				if (nodeToInsert == null || (nodeToInsert != null && nodeToInsert.width * nodeToInsert.height > nodeWithRotationArea))
				{
					nodeToInsert = nodeToInsertWithRotation;
					rotateNode = true;
					var temp:Int = insertWidth;
					insertWidth = insertHeight;
					insertHeight = temp;
				}
			}
		}

		if (nodeToInsert != null)
		{
			var horizontally:Bool = needToDivideHorizontally(nodeToInsert, insertWidth, insertHeight);
			return divideNode(nodeToInsert, insertWidth, insertHeight, horizontally, data, key, rotateNode);
		}

		return null;
	}

	function needToDivideHorizontally(nodeToDivide:FlxNode, insertWidth:Int, insertHeight:Int):Bool
	{
		var dw:Int = nodeToDivide.width - insertWidth;
		var dh:Int = nodeToDivide.height - insertHeight;

		return dw > dh; // divide horizontally if true, vertically if false
	}

	function divideNode(nodeToDivide:FlxNode, insertWidth:Int, insertHeight:Int, divideHorizontally:Bool, ?firstGrandChildData:BitmapData,
			?firstGrandChildKey:String, firstGrandChildRotated:Bool = false):FlxNode
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
				firstChild = new FlxNode(FlxRect.get(nodeToDivide.x, nodeToDivide.y, insertWidth, nodeToDivide.height), this);

				if (nodeToDivide.width - insertWidth > 0)
				{
					secondChild = new FlxNode(FlxRect.get(nodeToDivide.x + insertWidth, nodeToDivide.y, nodeToDivide.width - insertWidth,
						nodeToDivide.height), this);
				}

				firstGrandChild = new FlxNode(FlxRect.get(firstChild.x, firstChild.y, insertWidth, insertHeight), this, firstGrandChildFilled,
					firstGrandChildKey, firstGrandChildRotated);

				if (firstChild.height - insertHeight > 0)
				{
					secondGrandChild = new FlxNode(FlxRect.get(firstChild.x, firstChild.y + insertHeight, insertWidth, firstChild.height - insertHeight),
						this);
				}
			}
			else // divide vertically
			{
				firstChild = new FlxNode(FlxRect.get(nodeToDivide.x, nodeToDivide.y, nodeToDivide.width, insertHeight), this);

				if (nodeToDivide.height - insertHeight > 0)
				{
					secondChild = new FlxNode(FlxRect.get(nodeToDivide.x, nodeToDivide.y + insertHeight, nodeToDivide.width,
						nodeToDivide.height - insertHeight), this);
				}

				firstGrandChild = new FlxNode(FlxRect.get(firstChild.x, firstChild.y, insertWidth, insertHeight), this, firstGrandChildFilled,
					firstGrandChildKey, firstGrandChildRotated);

				if (firstChild.width - insertWidth > 0)
				{
					secondGrandChild = new FlxNode(FlxRect.get(firstChild.x + insertWidth, firstChild.y, firstChild.width - insertWidth, insertHeight), this);
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
					matrix.identity();
					matrix.rotate(Math.PI / 2);
					matrix.translate(firstGrandChildData.height + firstGrandChild.x, firstGrandChild.y);
					bitmapData.draw(firstGrandChildData, matrix);
				}
				else
				{
					point.setTo(firstGrandChild.x, firstGrandChild.y);
					bitmapData.copyPixels(firstGrandChildData, firstGrandChildData.rect, point);
				}

				addNodeToAtlasFrames(firstGrandChild);
				nodes.set(firstGrandChildKey, firstGrandChild);
			}

			return firstGrandChild;
		}

		return null;
	}

	function insertFirstNodeInRoot(data:BitmapData, key:String):FlxNode
	{
		if (root.left == null)
		{
			var insertWidth:Int = data.width + border;
			var insertHeight:Int = data.height + border;

			var rootWidth:Int = insertWidth;
			var rootHeight:Int = insertHeight;

			if (powerOfTwo)
			{
				rootWidth = getNextPowerOfTwo(rootWidth);
				rootHeight = getNextPowerOfTwo(rootHeight);
			}

			rootWidth = (minWidth > rootWidth) ? minWidth : rootWidth;
			rootHeight = (minHeight > rootHeight) ? minHeight : rootHeight;

			if (powerOfTwo)
			{
				rootWidth = getNextPowerOfTwo(rootWidth);
				rootHeight = getNextPowerOfTwo(rootHeight);
			}

			if ((maxWidth > 0 && rootWidth > maxWidth) || (maxHeight > 0 && rootHeight > maxHeight))
			{
				#if FLX_DEBUG
				throw "Can't insert node " + key + " with the size of (" + data.width + "; " + data.height + ") in atlas " + name
					+ " with the max size of (" + maxWidth + "; " + maxHeight + ") and powerOfTwo: " + powerOfTwo;
				#end
				return null;
			}

			root.width = rootWidth;
			root.height = rootHeight;

			var horizontally:Bool = needToDivideHorizontally(root, insertWidth, insertHeight);
			return divideNode(root, insertWidth, insertHeight, horizontally, data, key);
		}

		return null;
	}

	function expand(data:BitmapData, key:String):FlxNode
	{
		if (root.right == null)
		{
			var insertWidth:Int = data.width + border;
			var insertHeight:Int = data.height + border;

			// helpers for making decision on how to insert new node
			var addRightWidth:Int = root.width + insertWidth;
			var addRightHeight:Int = Std.int(Math.max(root.height, insertHeight));

			var addBottomWidth:Int = Std.int(Math.max(root.width, insertWidth));
			var addBottomHeight:Int = root.height + insertHeight;

			var addRightWidthRotate:Int = addRightWidth;
			var addRightHeightRotate:Int = addRightHeight;

			var addBottomWidthRotate:Int = addBottomWidth;
			var addBottomHeightRotate:Int = addBottomHeight;

			if (allowRotation)
			{
				addRightWidthRotate = root.width + insertHeight;
				addRightHeightRotate = Std.int(Math.max(root.height, insertWidth));

				addBottomWidthRotate = Std.int(Math.max(root.width, insertHeight));
				addBottomHeightRotate = root.height + insertWidth;
			}

			if (powerOfTwo)
			{
				addRightWidthRotate = addRightWidth = getNextPowerOfTwo(addRightWidth);
				addRightHeightRotate = addRightHeight = getNextPowerOfTwo(addRightHeight);
				addBottomWidthRotate = addBottomWidth = getNextPowerOfTwo(addBottomWidth);
				addBottomHeightRotate = addBottomHeight = getNextPowerOfTwo(addBottomHeight);

				if (allowRotation)
				{
					addRightWidthRotate = getNextPowerOfTwo(addRightWidthRotate);
					addRightHeightRotate = getNextPowerOfTwo(addRightHeightRotate);
					addBottomWidthRotate = getNextPowerOfTwo(addBottomWidthRotate);
					addBottomHeightRotate = getNextPowerOfTwo(addBottomHeightRotate);
				}
			}

			// checks for the max size
			var canExpandRight:Bool = true;
			var canExpandBottom:Bool = true;

			var canExpandRightRotate:Bool = allowRotation;
			var canExpandBottomRotate:Bool = allowRotation;

			if ((maxWidth > 0 && addRightWidth > maxWidth) || (maxHeight > 0 && addRightHeight > maxHeight))
				canExpandRight = false;

			if ((maxWidth > 0 && addBottomWidth > maxWidth) || (maxHeight > 0 && addBottomHeight > maxHeight))
				canExpandBottom = false;

			if ((maxWidth > 0 && addRightWidthRotate > maxWidth) || (maxHeight > 0 && addRightHeightRotate > maxHeight))
				canExpandRightRotate = false;

			if ((maxWidth > 0 && addBottomWidthRotate > maxWidth) || (maxHeight > 0 && addBottomHeightRotate > maxHeight))
				canExpandBottomRotate = false;

			if (!canExpandRight && !canExpandBottom && !canExpandRightRotate && !canExpandBottomRotate)
			{
				#if FLX_DEBUG
				throw "Can't insert node " + key + " with the size of (" + data.width + "; " + data.height + ") in atlas " + name
					+ " with the max size of (" + maxWidth + "; " + maxHeight + ") and powerOfTwo: " + powerOfTwo;
				#end
				return null; // can't expand in any direction
			}

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

			if ((canExpandBottom && canExpandBottomRotate && addBottomArea > addBottomAreaRotate)
				|| (!canExpandBottom && canExpandBottomRotate))
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

				expandRoot(temp.width + insertNodeWidth, Math.max(temp.height, insertNodeHeight), true);
				dataNode = divideNode(root.right, insertNodeWidth, insertNodeHeight, true, data, key, rotateRight);
				expandRoot(addRightWidth, addRightHeight, false, true);
			}
			else // add node at the bottom
			{
				if (rotateBottom)
				{
					insertNodeWidth = insertHeight;
					insertNodeHeight = insertWidth;
				}

				expandRoot(Math.max(temp.width, insertNodeWidth), temp.height + insertNodeHeight, false);
				dataNode = divideNode(root.right, insertNodeWidth, insertNodeHeight, true, data, key, rotateBottom);
				expandRoot(addBottomWidth, addBottomHeight, false, true);
			}

			return dataNode;
		}

		return null;
	}

	function expandRoot(newWidth:Float, newHeight:Float, divideHorizontally:Bool, decideHowToDivide:Bool = false):Void
	{
		if (newWidth > root.width || newHeight > root.height)
		{
			var temp:FlxNode = root;
			root = new FlxNode(FlxRect.get(0, 0, newWidth, newHeight), this);

			divideHorizontally = decideHowToDivide ? needToDivideHorizontally(root, temp.width, temp.height) : divideHorizontally;

			divideNode(root, temp.width, temp.height, divideHorizontally);
			root.left.left = temp;
		}
	}

	function expandBitmapData():Void
	{
		if (bitmapData != null && bitmapData.width == root.width && bitmapData.height == root.height)
		{
			return;
		}

		var newBitmapData:BitmapData = new BitmapData(root.width, root.height, true, FlxColor.TRANSPARENT);
		if (bitmapData != null)
		{
			point.setTo(0, 0);
			newBitmapData.copyPixels(bitmapData, bitmapData.rect, point);
		}

		bitmapData = FlxDestroyUtil.dispose(bitmapData);
		bitmapData = newBitmapData;
	}

	function getNextPowerOfTwo(number:Float):Int
	{
		var n:Int = Std.int(number);
		if (n > 0 && (n & (n - 1)) == 0) // see: http://goo.gl/D9kPj
			return n;

		var result:Int = 1;
		while (result < n)
			result <<= 1;
		return result;
	}

	/**
	 * Generates a new `BitmapData` with spaces between tiles, adds this `BitmapData` to this atlas,
	 * generates a `FlxTileFrames` object for the added node and returns it. Can be useful for tilemaps.
	 *
	 * @param   Graphic        Source image for node, where spaces will be inserted
	 *                        (could be a `BitmapData`, `String` or `Class<Dynamic>`).
	 * @param   Key           Optional key for image
	 * @param   tileSize      The size of tile in spritesheet
	 * @param   tileSpacing   Offsets to add in spritesheet between tiles
	 * @param   tileBorder    Border to add around tiles (helps to avoid "tearing" problem)
	 * @param   region        Region of source image to use as a source graphic
	 * @return  Generated `FlxTileFrames` for the added node
	 */
	public function addNodeWithSpacesAndBorders(Graphic:FlxGraphicSource, ?Key:String, tileSize:FlxPoint, tileSpacing:FlxPoint, ?tileBorder:FlxPoint,
			?region:FlxRect):FlxTileFrames
	{
		var key:String = FlxAssets.resolveKey(Graphic, Key);

		if (key == null)
		{
			#if FLX_DEBUG
			throw "addNodeWithSpacings can't find the key for specified BitmapData." + " Please provide not null value as a Key argument.";
			#end
			return null;
		}

		key = FlxG.bitmap.getKeyWithSpacesAndBorders(key, tileSize, tileSpacing, tileBorder, region);

		if (hasNodeWithName(key))
			return nodes.get(key).getTileFrames(tileSize, tileSpacing, tileBorder);

		var data:BitmapData = FlxAssets.resolveBitmapData(Graphic);

		if (data == null)
		{
			#if FLX_DEBUG
			throw "addNodeWithSpacings can't find BitmapData with specified key: " + Graphic + ". Please provide valid value.";
			#end
			return null;
		}

		var nodeData = FlxBitmapDataUtil.addSpacesAndBorders(data, tileSize, tileSpacing, tileBorder, region);
		var node:FlxNode = addNode(nodeData, key);

		if (node == null)
		{
			#if FLX_DEBUG
			throw "addNodeWithSpacings can't insert provided image: " + Graphic + ") in atlas. It's probably too big.";
			#end
			return null;
		}

		if (tileBorder != null)
			tileSize.add(2 * tileBorder.x, 2 * tileBorder.y);

		return node.getTileFrames(tileSize, tileSpacing, tileBorder);
	}

	/**
	 * Gets the `FlxAtlasFrames` object for this atlas.
	 * It caches graphic of this atlas and generates `FlxAtlasFrames` if it doesn't exist yet.
	 *
	 * @return `FlxAtlasFrames` for this atlas
	 */
	public function getAtlasFrames():FlxAtlasFrames
	{
		var graph:FlxGraphic = this.graphic;

		var atlasFrames:FlxAtlasFrames = graph.atlasFrames;
		if (graph.atlasFrames == null)
		{
			atlasFrames = new FlxAtlasFrames(graph);
		}

		for (node in nodes)
			addNodeToAtlasFrames(node);

		return atlasFrames;
	}

	function addNodeToAtlasFrames(node:FlxNode):Void
	{
		if (_graphic == null || _graphic.atlasFrames == null || node == null)
			return;

		var atlasFrames:FlxAtlasFrames = _graphic.atlasFrames;

		if (node.filled && !atlasFrames.framesHash.exists(node.key))
		{
			var frame:FlxRect = FlxRect.get(node.x, node.y, node.width - border, node.height - border);
			var sourceSize:FlxPoint = node.rotated ? FlxPoint.get(node.height - border,
				node.width - border) : FlxPoint.get(node.width - border, node.height - border);
			var offset = FlxPoint.get(0, 0);
			var angle:FlxFrameAngle = node.rotated ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;
			atlasFrames.addAtlasFrame(frame, sourceSize, offset, node.key, angle);
		}
	}

	/**
	 * Checks if the atlas already contains node with the same name.
	 *
	 * @param   nodeName   Node name to check.
	 * @return  `true` if atlas already contains node with the name.
	 */
	public function hasNodeWithName(nodeName:String):Bool
	{
		return nodes.exists(nodeName);
	}

	/**
	 * Gets a node by it's name.
	 *
	 * @param   key   Node name to search for.
	 * @return  node with searched name. `null` if atlas doesn't contain any node with that name.
	 */
	public function getNode(key:String):FlxNode
	{
		return nodes.get(key);
	}

	/**
	 * Optimized version of method for adding multiple nodes to atlas.
	 * Uses less of the atlas' area (it sorts images by the size before adding them to atlas).
	 *
	 * @param   bitmaps   `BitmapData`'s to insert
	 * @param   keys      Names of these `BitmapData` objects.
	 * @return  `this` `FlxAtlas`
	 */
	public function addNodes(bitmaps:Array<BitmapData>, keys:Array<String>):FlxAtlas
	{
		var numKeys:Int = keys.length;
		var numBitmaps:Int = bitmaps.length;

		if (numBitmaps != numKeys)
		{
			#if FLX_DEBUG
			throw "The number of bitmaps (" + numBitmaps + ") should be equal to number of keys (" + numKeys + ")";
			#end
			return null;
		}

		_tempStorage = new Array<TempAtlasObj>();
		for (i in 0...numBitmaps)
		{
			_tempStorage.push({bmd: bitmaps[i], keyStr: keys[i]});
		}

		addFromAtlasObjects(_tempStorage);
		return this;
	}

	function addFromAtlasObjects(objects:Array<TempAtlasObj>):Void
	{
		objects.sort(bitmapSorter);
		var numBitmaps:Int = objects.length;

		for (i in 0...numBitmaps)
			addNode(objects[i].bmd, objects[i].keyStr);

		_tempStorage = null;
	}

	/**
	 * Internal method for sorting bitmaps
	 */
	function bitmapSorter(obj1:TempAtlasObj, obj2:TempAtlasObj):Int
	{
		if (allowRotation)
		{
			var area1:Int = obj1.bmd.width * obj1.bmd.height;
			var area2:Int = obj2.bmd.width * obj2.bmd.height;
			return area2 - area1;
		}

		if (obj2.bmd.width == obj1.bmd.width)
			return obj2.bmd.height - obj1.bmd.height;

		return obj2.bmd.width - obj1.bmd.width;
	}

	/**
	 * Creates a new "queue" for adding new nodes.
	 * This method should be used with the `addToQueue()` and `generateFromQueue()` methods:
	 * - first, you create queue, like `atlas.createQueue()`;
	 * - second, you add several bitmaps to the queue: `atlas.addToQueue(bmd1, "key1").addToQueue(bmd2, "key2");`
	 * - third, you actually bake those bitmaps onto the atlas: `atlas.generateFromQueue();`
	 */
	public function createQueue():FlxAtlas
	{
		_tempStorage = new Array<TempAtlasObj>();
		return this;
	}

	/**
	 * Adds new object to queue for later creation of new node
	 *
	 * @param   data   `BitmapData` to bake on atlas
	 * @param   key    "name" of the `BitmapData`. You'll use it as a key for accessing the created node.
	 */
	public function addToQueue(data:BitmapData, key:String):FlxAtlas
	{
		if (_tempStorage == null)
			_tempStorage = new Array<TempAtlasObj>();

		_tempStorage.push({bmd: data, keyStr: key});
		return this;
	}

	/**
	 * Adds all objects in "queue" to existing atlas. Doesn't remove any nodes.
	 */
	public function generateFromQueue():FlxAtlas
	{
		if (_tempStorage != null)
			addFromAtlasObjects(_tempStorage);

		return this;
	}

	function onClear(_):Void
	{
		if (!persist || (_graphic != null && _graphic.useCount <= 0))
			destroy();
	}

	/**
	 * Destroys the atlas. Use only if you want to clear memory and don't need this atlas anymore,
	 * since it disposes the `BitmapData` and removes it from the cache.
	 */
	public function destroy():Void
	{
		_tempStorage = null;
		deleteSubtree(root);
		root = null;
		FlxG.bitmap.removeByKey(name);
		bitmapData = null;
		nodes = null;
		_graphic = null;

		FlxG.signals.preStateCreate.remove(onClear);
	}

	/**
	 * Clears all data in atlas. Use it when you want reuse this atlas.
	 * WARNING: it will destroy the graphic of this image, so you can get
	 * null pointer exceptions if you're still using it for your sprites.
	 */
	public function clear():Void
	{
		deleteSubtree(root);
		initRoot();
		FlxG.bitmap.removeByKey(name);
		bitmapData = null;
		nodes = new Map<String, FlxNode>();
		_graphic = null;
	}

	/**
	 * Returns atlas data in LibGdx packer format.
	 */
	public function getLibGdxData():String
	{
		var data:String = "\n";
		data += name + "\n";
		data += "format: RGBA8888\n";
		data += "filter: Linear,Linear\n";
		data += "repeat: none\n";

		for (node in nodes)
		{
			data += node.key + "\n";
			data += "  rotate: " + node.rotated + "\n";
			data += "  xy: " + node.x + ", " + node.y + "\n";

			if (allowRotation)
			{
				data += "size: " + node.height + ", " + node.width + "\n";
				data += "orig: " + node.height + ", " + node.width + "\n";
			}
			else
			{
				data += "size: " + node.width + ", " + node.height + "\n";
				data += "orig: " + node.width + ", " + node.height + "\n";
			}

			data += "  offset: 0, 0\n";
			data += "  index: -1\n";
		}

		return data;
	}

	function deleteSubtree(node:FlxNode):Void
	{
		if (node != null)
		{
			if (node.left != null)
				deleteSubtree(node.left);
			if (node.right != null)
				deleteSubtree(node.right);
			node.destroy();
		}
	}

	// Internal iteration method
	function findNodeToInsert(insertWidth:Int, insertHeight:Int):FlxNode
	{
		// Node stack
		var stack:Array<FlxNode> = new Array<FlxNode>();
		// Current node
		var current:FlxNode = root;

		var emptyNodes:Array<FlxNode> = new Array<FlxNode>();

		var canPlaceRight:Bool = false;
		var canPlaceLeft:Bool = false;

		var looping:Bool = true;

		var result:FlxNode = null;
		var minArea:Int = maxWidth * maxHeight + 1;
		var nodeArea:Int;

		// Main loop
		while (looping)
		{
			// Look into current node
			if (current.isEmpty && current.canPlace(insertWidth, insertHeight))
			{
				nodeArea = current.width * current.height;

				if (nodeArea < minArea)
				{
					minArea = nodeArea;
					result = current;
				}
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
					looping = false;
				}
			}
		}

		return result;
	}

	function set_bitmapData(value:BitmapData):BitmapData
	{
		// update graphic bitmapData
		if (value != null && _graphic != null)
			_graphic.bitmap = value;

		return bitmapData = value;
	}

	function get_graphic():FlxGraphic
	{
		if (_graphic != null)
			return _graphic;

		_graphic = FlxG.bitmap.add(bitmapData, false, name);
		_graphic.persist = persist;

		return _graphic;
	}

	function set_persist(value:Bool):Bool
	{
		if (_graphic != null)
			_graphic.persist = value;

		return persist = value;
	}

	function set_minWidth(value:Int):Int
	{
		if (value <= maxWidth)
		{
			minWidth = value;
			if (value > width)
				width = value;
		}

		return minWidth;
	}

	function set_minHeight(value:Int):Int
	{
		if (value <= maxHeight)
		{
			minHeight = value;
			if (value > height)
				height = value;
		}

		return minHeight;
	}

	function get_width():Int
	{
		if (root != null)
			return root.width;

		return 0;
	}

	function set_width(value:Int):Int
	{
		if (value > get_width())
		{
			if (powerOfTwo)
				value = getNextPowerOfTwo(value);

			if (value <= maxWidth)
			{
				if (root != null && root.width < value)
				{
					expandRoot(value, root.height, needToDivideHorizontally(root, root.width, root.height));
				}
			}
		}

		return value;
	}

	function get_height():Int
	{
		if (root != null)
			return root.height;
		return 0;
	}

	function set_height(value:Int):Int
	{
		if (value > get_height())
		{
			if (powerOfTwo)
				value = getNextPowerOfTwo(value);

			if (value <= maxHeight)
			{
				if (root != null && root.height < value)
				{
					expandRoot(root.width, value, needToDivideHorizontally(root, root.width, root.height));
				}
			}
		}

		return value;
	}

	function set_maxWidth(value:Int):Int
	{
		if (value >= minWidth && (root == null || value >= width))
			maxWidth = value;

		return maxWidth;
	}

	function set_maxHeight(value:Int):Int
	{
		if (value >= minHeight && (root == null || value >= height))
			maxHeight = value;

		return maxHeight;
	}

	function set_powerOfTwo(value:Bool):Bool
	{
		if (value != powerOfTwo && value && root != null)
		{
			var nextWidth:Int = getNextPowerOfTwo(root.width);
			var nextHeight:Int = getNextPowerOfTwo(root.height);

			if (nextWidth != root.width || nextHeight != root.height) // need to resize atlas
			{
				if ((maxWidth > 0 && nextWidth > maxWidth) || (maxHeight > 0 && nextHeight > maxHeight))
				{
					#if FLX_DEBUG
					throw "Can't set powerOfTwo property to true," + " since it requires to increase atlas size which is bigger that max size";
					#end
					return false;
				}

				var temp:FlxNode = root;
				root = new FlxNode(FlxRect.get(0, 0, nextWidth, nextHeight), this);

				if (temp.left != null) // this means that atlas isn't empty and we need to resize it's BitmapData
				{
					divideNode(root, temp.width, temp.height, needToDivideHorizontally(root, temp.width, temp.height));
					root.left.left = temp;
				}
			}
		}

		return powerOfTwo = value;
	}
}

private typedef TempAtlasObj =
{
	public var bmd:BitmapData;
	public var keyStr:String;
}
