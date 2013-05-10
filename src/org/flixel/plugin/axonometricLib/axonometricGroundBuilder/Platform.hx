package org.flixel.plugin.axonometricLib.axonometricGroundBuilder;
import nme.display.BitmapData;
import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.tools.AxisManager;
import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.tools.parallelogramRendering.ParallelTilemap;
import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.blueprint.Node;
//import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.Blueprint.*;
import flash.geom.Point;
//import org.flixel.*;

/**
 * A platform is the rendering of a node, the graphical part of the floor
 * 
 * @author Miguel Ángel Piedras Carrillo, Jimmy Delas (Haxe port)
 */
class Platform extends FlxGroup
{
	/*
	 *  the floor of the platform
	 */ 
	public var floor:ParallelTilemap;
	/*
	 *  the right side of the platform
	 */ 
	public var sideB:ParallelTilemap;
	/*
	 *  the left side of the platform
	 */ 
	public var sideA:ParallelTilemap;
	
	public static var layernum:Float=0;
	/*
	 *  the number of the current layer
	 */ 
	public var mylayer:Float; 
	
	
	
	/**
	 * Constructor
	 * 
	 * @param	node			node to be rendered into a platfom
	 * @param	position		instance of axismanager to guide the rendering
	 * @param	debug			sets the debugging mode
	 * 
	 */
	public function new(node:Node,position:AxisManager,debug:Bool=false) 
	{
		super();
		MakeParallelepiped(node, position, debug);
		mylayer = layernum;
		layernum++;
	}

	private function MakeParallelepiped(node:Node,Pos:AxisManager,debug:Bool,cannonical:Bool=false):Void {
		 var geography:String = node.geography;
		 
		 var geographyB:String;
		 var geographyA:String;
		 
		 geographyB = node.getLateralMapString(node.southernNeighbors , true ) ;
		 geographyA = node.getLateralMapString(node.easternNeighbors  , false) ;
		 
		 this.add(floor = MakeParallelepipedSide(geography  , Pos.descriptor.TilemapWidthDepth   , Pos.theta  , Pos.descriptor.BlockWidth, Pos.phi       	 , Pos.descriptor.BlockDepth ,false ,false ,false,debug)); //xz
		 this.add(sideB = MakeParallelepipedSide(geographyB , Pos.descriptor.TilemapWidthHeight  , 0      	, Pos.descriptor.BlockHeight , Pos.theta     	 , Pos.descriptor.BlockWidth ,false ,true  ,false,debug)); //xy
		 this.add(sideA = MakeParallelepipedSide(geographyA , Pos.descriptor.TilemapDepthHeight  , 0      	, Pos.descriptor.BlockHeight , Pos.theta+Pos.phi , Pos.descriptor.BlockDepth ,true	,true  ,true ,debug)); //yz
		 
		 //we are using the width, because both of the tilemaps are rotated
		 var Parallelepipedheight:Float = sideB.widthInTiles > sideA.widthInTiles ? sideB.widthInTiles : sideA.widthInTiles;
		 var x:Float =  node.x * Pos.descriptor.BlockWidth;
		 var y:Float = (node.heightfromground -Parallelepipedheight) * -Pos.descriptor.BlockHeight;
		 var z:Float =  node.z * Pos.descriptor.BlockDepth;
		 
		 var Location:Point = Pos.Get2dCord(x, y, z);
		 Location.x += Pos.center.x;
		 Location.y += Pos.center.y;

		 //transformed/working state
		 if(!cannonical){
			 
			 floor.setLocation(Location.x - Pos.axisY.x *Pos.descriptor.BlockHeight* Parallelepipedheight,
							   Location.y - Pos.axisY.y *Pos.descriptor.BlockHeight* Parallelepipedheight);
			 sideB.setLocation(Location.x + floor.myParallelogram.BigAxisB.x,
							   Location.y + floor.myParallelogram.BigAxisB.y);
			 sideA.setLocation(Location.x + floor.myParallelogram.BigAxisA.x,
							   Location.y + floor.myParallelogram.BigAxisA.y);
							   
			//putting the thing together if there is a difference in the sides height
			
			sideB.setLocation(sideB.X -  Pos.axisY.x*Pos.descriptor.BlockHeight*(Parallelepipedheight-sideB.widthInTiles),
							  sideB.Y -  Pos.axisY.y*Pos.descriptor.BlockHeight*(Parallelepipedheight-sideB.widthInTiles));	
			sideA.setLocation(sideA.X -  Pos.axisY.x*Pos.descriptor.BlockHeight*(Parallelepipedheight-sideA.widthInTiles),
							  sideA.Y -  Pos.axisY.y*Pos.descriptor.BlockHeight*(Parallelepipedheight-sideA.widthInTiles));
			
		 }else { //cannonical form, it shows the "center" of the block
			 floor.setLocation(Location.x, Location.y);
			 sideB.setLocation(Location.x, Location.y);
			 sideA.setLocation(Location.x, Location.y);
		 }
	}

	private function MakeParallelepipedSide(geography:String,tilemap:Dynamic,alpha:Float,a:Float,beta:Float,b:Float,positiveAngle:Bool= false,rotatetile:Bool = false,inverttile:Bool=false,tilemapdebug:Bool= false, showboundingboxes:Bool= false, hideTile:Bool= false,showmytiles:Bool=false):ParallelTilemap{			
		var map:ParallelTilemap = new ParallelTilemap();
		map.loadMap( geography, tilemap,positiveAngle, rotatetile,inverttile,cast(a, UInt), cast(b, UInt), FlxTilemap.OFF, 0, 1, 1,
		alpha,
		beta,
		tilemapdebug,
		showboundingboxes,
		hideTile,
		showmytiles 
		);
		map.scrollFactor.x = 1;
		map.scrollFactor.y = 1;
		return map;
	}
		
	 /**
	 * Destruye el objeto y sus elementos, liberando memoria
	 * 
	 */		
	override public function destroy():Void {
		floor.destroy();
		sideB.destroy();
		sideA.destroy();
	}
}
