package org.flixel.plugin.axonometricLib.axonometricGroundBuilder.tools;
import nme.display.BitmapData;
/**
 * The block descriptor sets the general shape of the floor by defining images and measures to be used in the new 2.5d stage
 * 
 * @author Miguel Ángel Piedras Carrillo, Jimmy Delas (Haxe port)
 */
class BlockDescriptor 
{
	/**
	 * The image the ground tilemap uses, its width must be a multiple of BlockWidth and its height a multiple of BlockDepth.
	 */
	public var TilemapWidthDepth:Dynamic;
	/**
	 * he image the right side of the block uses, its widht must be a multiple of BlockWidth and its height must be a multiple of BlockHeight.
	 */
	public var TilemapWidthHeight:Dynamic;
	/**
	 * The image the left side of the block uses its width must be a multple of BlockDepth and its height must be a multiple of BlockHeight.
	 */
	public var TilemapDepthHeight:Dynamic;
	
	/**
	 * The width of 1 block
	 */
	public var BlockWidth:Int;
	/**
	 * The height of 1 block
	 */
	public var BlockHeight:Int;
	/**
	 * The depth of 1 block
	 */
	public var BlockDepth:Int;
	
	/**
	 * sets the graphics needed to build the ground
	 * 
	 * @param	BlockWidth				The width of 1 block.
	 * @param	BlockHeight				The height of 1 block.
	 * @param	BlockDepth				The depth of 1 block.
	 * @param	TilemapWidthDepth		The image the ground tilemap uses, its width must be a multiple of BlockWidth and its height a multiple of BlockDepth.
	 * @param	TilemapWidthHeight		The image the right side of the block uses, its widht must be a multiple of BlockWidth and its height must be a multiple of BlockHeight.
	 * @param	TilemapDepthHeight		The image the left side of the block uses its width must be a multple of BlockDepth and its height must be a multiple of BlockHeight.
	 * 
	 */
	public function new( BlockWidth:Int,
									 BlockHeight:Int,
									 BlockDepth:Int,
									 TilemapWidthDepth:Dynamic,
									 TilemapWidthHeight:Dynamic,
									 TilemapDepthHeight:Dynamic
									) {
		this.BlockWidth  = BlockWidth;
		this.BlockHeight = BlockHeight;
		this.BlockDepth  = BlockDepth;
		this.TilemapWidthDepth = TilemapWidthDepth;
		this.TilemapDepthHeight = TilemapDepthHeight;
		this.TilemapWidthHeight = TilemapWidthHeight;
	}
	
	/**
	 * Destroys this element, freeing memeory.
	 * 
	 */
	public function destroy():Void {
		TilemapWidthDepth = null;
		TilemapWidthHeight = null;
		TilemapDepthHeight = null;
	}

	
}

