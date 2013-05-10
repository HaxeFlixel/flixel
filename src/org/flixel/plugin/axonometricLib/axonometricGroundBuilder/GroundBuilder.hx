package org.flixel.plugin.axonometricLib.axonometricGroundBuilder;

import nme.Assets;
import nme.display.BitmapData;
import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.blueprint.Model;
import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.blueprint.Node;
import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.tools.AxisManager;
import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.tools.BlockDescriptor;
import org.flixel.plugin.axonometricLib.axonometricSpriteBuilder.AxonometricSprite;

import flash.geom.Point;
import org.flixel.FlxGroup;
/**
 * The builder is in charge of using the tools to build the stage, and place sprites on their required layer.
 * 
 * @author Miguel Ángel Piedras Carrillo, Jimmy Delas (Haxe port)
 */
class GroundBuilder 
{
	public static var MIN_VALUE : Float = 0.000001;
	
	private static var floorTown:Dynamic = "axonometric_tile_town";
	private static var grounddirt:Dynamic = "axonometric_grounddirt";
	//[Embed(source = "tile_town.png")]			  private static var floorTown	 :Class<Dynamic>;
	//[Embed(source = "grounddirt.png")]			  private static var grounddirt	 :Class<Dynamic>;

	private var geography    :String;
	private var topography   :String;		
	private var center       :Point;		
	private var position     :AxisManager;
	private var model        :Model;
	private var layerManager :LayerManager;
			
	/**
	 * Initialize the parameters to begin construction.
	 * 
	 * @param	center					the position of the map with repect the stage.
	 * @param	topography				string that represents by numbers separated by commas and line breaks the height of the floor in each given position.
	 */				
	public function new(center:Point,topography:String) 
	{
		this.center     =  center;
		this.topography =  topography;
		layerManager = new LayerManager();
		SetBlockDescriptor(40, 40, 40, floorTown, grounddirt, grounddirt);
		RenderFunction(0, 0);
	}
	
	/**
	 * Sets a descriptor to have more control over the shape and texture of the ground, the ratios of the images must be accurate in order to this to work propertly.
	 * 
	 * @param	BlockWidth				The width of 1 block.
	 * @param	BlockHeight				The height of 1 block.
	 * @param	BlockDepth				The depth of 1 block.
	 * @param	TilemapWidthDepth		The image the ground tilemap uses, its width must be a multiple of BlockWidth and its height a multiple of BlockDepth.
	 * @param	TilemapWidthHeight		The image the right side of the block uses, its widht must be a multiple of BlockWidth and its height must be a multiple of BlockHeight.
	 * @param	TilemapDepthHeight		The image the left side of the block uses its width must be a multple of BlockDepth and its height must be a multiple of BlockHeight.
	 * 
	 * @param	geography				(Optional)string that represents by numbers separated by commas and line breaks the wich tile is in wich position, it mus have the same size 
	 * 									as the topography.
	 */				
	public function SetBlockDescriptor(BlockWidth:Int, BlockHeight:Int, BlockDepth:Int, TilemapWidthDepth:Dynamic, TilemapWidthHeight:Dynamic, TilemapDepthHeight:Dynamic, geography:String = ""):Void {
		this.geography  = geography;
		var descriptor:BlockDescriptor = new BlockDescriptor(
																BlockWidth,
																BlockHeight,
																BlockDepth,
																TilemapWidthDepth,
																TilemapWidthHeight,
																TilemapDepthHeight
															);
		position = new AxisManager(descriptor, center);						
	}
	
	/**
	 * Renders the stage
	 * 
	 * @param	theta					Angle measured in radians from the negative y axis
	 * @param	phi						Angle measured in radians from theta
	 * @param	debug					Sets the debugging mode.
	 */
	public function RenderFunction(theta:Float, phi:Float,debug:Bool=false):FlxGroup {			
//		var i:Number;
		var node         :Node;
		position.setAxis(theta, phi, debug);
		model = new Model(geography, topography,(theta > 0));		
		
		return layerManager.GetMap(model, position,debug);

		
	}
	
	 /**
	 * Adds an element to the world, if the position is invalid, it will be set on 0,0
	 * 
	 * @param	i						Position of the row to put the sprite, given the topography as reference
	 * @param	j						Position of the column to put the sprite, given the topography as reference
	 * @param	sprite					sprite of the AxonometricSprite class to be added to stage 
	 */
	public function AddElement(i:Int, j:Int, sprite:AxonometricSprite, leftSided:Bool):Void {
		if (leftSided) {
			j = (model.maxCols-1) - j;
		}
		var node:Node = model.getNodeInPos(i, j);
		if (node == null) {
			node = model.getNodeInPos(0, 0);
			i = 0;
			j = 0;
		}
		sprite.currentNode = node;
		sprite.builder = this;
		setSpriteBelongingLayer(sprite,i,j);
		var point:Point = position.getLocationFromGround(j, i, node.heightfromground);
		sprite.setLocation(point.x, point.y);

	}
	
	private function setSpriteBelongingLayer(sprite:AxonometricSprite,  i:Int,j:Int):Void {
		
		var center:Node = model.getNodeInPos(i, j);
		if(sprite.currgroup != center.platformRender){
		
			var ND:Array<Node> = new Array<Node>();
			var south:Node = model.getNodeInPos(i+1, j);
			var node:Node;
			var select:Node = center;
			var biggerLayer:Float= center.platformRender.mylayer;
			
			ND.push(model.getNodeInPos(i-1,j-1)); ND.push(model.getNodeInPos(i-1,j)) ; ND.push(model.getNodeInPos(i-1,j+1));
			ND.push(model.getNodeInPos(i  ,j-1));                                      ND.push(model.getNodeInPos(i  ,j+1));
			ND.push(model.getNodeInPos(i+1,j-1)); ND.push(model.getNodeInPos(i+1,j)) ; ND.push(model.getNodeInPos(i+1,j+1));
 
			for ( i in 0 ... ND.length) {
				node = ND[i];
				if (node != null) {
					if ( node.heightfromground == center.heightfromground ) {
						if(node.platformRender.mylayer > biggerLayer){						
							biggerLayer = node.platformRender.mylayer;
							select = node;
						}
					}else if(node.heightfromground > center.heightfromground ){
						select = center;
						break;
					}
					
				}
			}			
			
			removeElement(sprite);
			sprite.currgroup = select.platformRender;
			sprite.currgroup.add(sprite.shadow);
			sprite.currgroup.add(sprite);
		}

	}				
	
	/**
	 * Removes a sprite from the world
	 * 
	 * @param	sprite					sprite of the AxonometricSprite class to be added to stage 
	 */		
	public function removeElement(sprite:AxonometricSprite):Void {
		if(sprite.currgroup!= null){
			sprite.currgroup.remove(sprite);
			sprite.currgroup.remove(sprite.shadow);
			sprite.currgroup = null;
			//trace("Remove");
		}
	}

	 /**
	 * cheks and changes the current bounds and location of the sprite.
	 * 
	 * @param	sprite						the sprite to be checked
	 */
	public function checkBounds(sprite:AxonometricSprite):Void {
		//	   ->      ->
		// P = αa  +  βb  		
		var P:Point = new Point(sprite.shadow.x - sprite.currentNode.platformRender.floor.X, sprite.shadow.y -sprite.currentNode.platformRender.floor.Y);
		var alpha:Float = getAlpha(P, position.axisX, position.axisZ);
		var beta:Float  = getBeta (P, position.axisX, position.axisZ);
		var correctionalpha:Float = alpha;
		var correctionbeta:Float = beta;			
		var currcol:Int = Math.floor( alpha / position.descriptor.BlockWidth);
		var currrow:Int = Math.floor( beta  / position.descriptor.BlockDepth);
		var touchingNeighboor:Bool = false;
		if ( currcol > sprite.currentNode.cols-1  ) {
			touchingNeighboor = true;
			correctionalpha = sprite.currentNode.cols * position.descriptor.BlockWidth;
		}
		if ( currcol < 0) {
			touchingNeighboor = true;
			correctionalpha = MIN_VALUE;
		}
		if ( currrow > sprite.currentNode.rows-1 ) {
			touchingNeighboor = true;
			correctionbeta = sprite.currentNode.rows * position.descriptor.BlockDepth;
		}			
		if (currrow < 0) {
			touchingNeighboor = true;
			correctionbeta = MIN_VALUE;
		}
		
		
		if (touchingNeighboor) {
			var neighbor:Node = model.getNodeInPos(sprite.currentNode.Ti +  currrow, sprite.currentNode.Tj + currcol);
			if (neighbor == null) {
				spriteColision(sprite, correctionalpha, correctionbeta);
			}else {
				var dropheight:Int  = sprite.currentNode.heightfromground - neighbor.heightfromground;
				if (dropheight == 0) {
					changeNode(sprite, neighbor,(sprite.currentNode.Ti +  currrow),(sprite.currentNode.Tj + currcol));
				}else {
					if (sprite.shadow.walldrop(dropheight * position.descriptor.BlockHeight)) {
						changeNode(sprite, neighbor,(sprite.currentNode.Ti +  currrow),(sprite.currentNode.Tj + currcol));
					}else {
						spriteColision(sprite, correctionalpha, correctionbeta);
					}
				}
			}
		}else {
			setSpriteBelongingLayer(sprite,(sprite.currentNode.Ti +  currrow),(sprite.currentNode.Tj + currcol));
		}
	}
	
	private function changeNode(sprite:AxonometricSprite,newnode:Node,i:Int,j:Int):Void {
//		trace("oldnode " + sprite.currentNode.tag);
		sprite.currentNode = newnode;
//		trace("newnode " + sprite.currentNode.tag);
		//trace("---------- ")

	}

	
	

	
	
			
	private function spriteColision(sprite:AxonometricSprite, correctionalpha:Float, correctionbeta:Float):Void {
		var correction:Point = new Point(
		position.axisX.x * correctionalpha + position.axisZ.x * correctionbeta
					   ,
		position.axisX.y * correctionalpha + position.axisZ.y * correctionbeta);
		correction.x += sprite.currentNode.platformRender.floor.X;
		correction.y += sprite.currentNode.platformRender.floor.Y;
		sprite.shadow.x = correction.x;
		sprite.shadow.y = correction.y;
	}

	private function getAlpha(P:Point, a:Point, b:Point):Float {
		return ( (P.x / a.x) - (b.x / a.x) * getBeta(P, a, b));
	}

	private function getBeta(P:Point, a:Point, b:Point):Float {
		return( 
				( P.y-(a.y/a.x)*P.x )
				/
				( b.y-(a.y/a.x)*b.x )
			);
	}
	
	/**
	 * Destroys this element, freeing memeory.
	 * 
	 */
	public function destroy():Void {
		layerManager.destroy();
		position.destroy();
		model.destroy();
	}
}