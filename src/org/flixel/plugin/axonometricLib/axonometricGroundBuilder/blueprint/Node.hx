package org.flixel.plugin.axonometricLib.axonometricGroundBuilder.blueprint;
import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.Platform;
//import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.tools.ParallelogramRendering.*;
/**
 * A node represents a square section of the topography of the map
 *
 * 
 * @author	Miguel Ángel Piedras Carrillo, Jimmy Delas (Haxe port)
 */
class Node 
{
	
	/**
	 * section of the topography that corresponds with this node
	 */
	public var geography:String;
	
	
	/**
	 * northen neighbors of the node
	 */
	public var northenNeighbors:Hash<NodeLink>;
	/**
	 * sourthern neighbors of the node
	 */
	public var southernNeighbors:Hash<NodeLink>;
	/**
	 * eastern neighbors of the node
	 */
	public var easternNeighbors:Hash<NodeLink>;
	/**
	 * western neighbors of the node
	 */
	public var westernNeighbors:Hash<NodeLink>;
			
	
	/**
	 * column of the leftmost, uppermost tile of the node
	 *
	 */		
	public var Ti:Int;
	/**
	 * row of the leftmost, uppermost tile of the node
	 *
	 */		
	public var Tj:Int;

	
	
	/**
	 * x position of the world
	 *
	 */
	public var x:Float;
	/**
	 * y position fo the world
	 *
	 */
	public var y:Float;
	/**
	 * z position of the world
	 *
	 */
	public var z:Float;
	
	
	/**
	 * amount of colums of this section
	 *
	 */
	public var cols:Int;
	/**
	 * amount of rows of this section
	 *
	 */
	public var rows:Int;
			
	/**
	 * tagname assigned to this node
	 */		
	public var tag:String;
	
	/*
	 * name of the platform assigned to this node
	 */ 
	public var platform:String;
	
	/*
	 * height of the platform from the ground
	 */		
	public var heightfromground:Int;

	
	/*
	 *  graphical object that is the representation of this node
	 */ 		
	public var platformRender:Platform;
	
	
	/*
	 *  Layer to add elements belonging to this node
	 */ 		
	public var SpriteBelongsToThisNodeLayer:Node;
	
	
	/*
	 * an anchor sets a layer to a specific layer;
	 */ 
	
	public var anchor:Node;
	
	
	/*
	 *   Object of the boats this node has.
	 */ 
	
	public var boats:Hash<Node>;
	
	
	
	/**
	 * Constructor
	 * 
	 * @param	tag		tagname assigned to this node.
	 * @param	cols	amount of colums of this node.
	 * @param	rows	amount of rows of this node.
	 * @param	Ti		row regarding the original topography.
	 * @param	Tj		column regarding the original topography.
	 * @param   height  heigh of the platform
	 * 
	 */		
	public function new(tag:String,cols:Int,rows:Int,Ti:Int,Tj:Int,height:Int) 
	{
		this.tag  = tag;
		this.cols = cols;
		this.rows = rows;
		this.Ti   = Ti;
		this.Tj   = Tj;			
		this.heightfromground = height;
		geography = "";
		
		this.x    = Tj;
		this.y    = 0;//-height;
		this.z    = Ti;
		
		platform = "";
		
		northenNeighbors = new Hash<NodeLink>();
		southernNeighbors = new Hash<NodeLink>();
		easternNeighbors = new Hash<NodeLink>();
		westernNeighbors = new Hash<NodeLink>();
		boats = new Hash<Node>();
		SpriteBelongsToThisNodeLayer = this;
		anchor = null;
	}
	
	/**
	 * adds a western neighbor
	 * 
	 * @param node neigbor to add
	 *
	 */		
	public function AddWesternNeighborsLink(node:Node):Void {
		SetLink(westernNeighbors, node.easternNeighbors, node);
	}
	/**
	 * adds a western neighbor
	 * 
	 * @param node neigbor to add
	 *
	 */		
	public function AddEasternNeighborsLink(node:Node):Void {
		SetLink(easternNeighbors, node.westernNeighbors, node);
	}
	/**
	/**
	 * adds a northern neighbor
	 * 
	 * @param node neigbor to add
	 *
	 */		
	public function AddNorthenNeighbors(node:Node):Void {
		SetLink(northenNeighbors, node.southernNeighbors, node);
	}
	/**
	 * adds a southern neighbor
	 * 
	 * @param node neigbor to add
	 *
	 */		
	public function AddSouthernNeighbors(node:Node):Void {
		SetLink(southernNeighbors, node.northenNeighbors, node);
	}
	
	private function SetLink(MyNeighbors:Hash<NodeLink>, HisNeighbors:Hash<NodeLink>,node:Node):Void {
		var link:NodeLink;
		link = HisNeighbors.get(tag);
		if (link != null) {
			MyNeighbors.set(node.tag, link);
		}else {
			link = MyNeighbors.get(node.tag);
			if (link != null) {
				link.Linkspan++;
			}else {
				if 		 ( node.heightfromground > heightfromground) {
					link = new NodeLink(node, this);
				}else if ( node.heightfromground < heightfromground) {
					link = new NodeLink(this, node);						
				}else {
					link = new NodeLink(node, this, true);
				}
				MyNeighbors.set(node.tag, link);
			}
		}
	}

	
	/** 
	 * sets the string that defines the shape of the lateral sides of the node
	 * 
	 * @param Neighboors     wich neighbors are used to create this string
	 * @param horizontal     if the neighbors are horizontal to the node
	 * 
	 */
	public function getLateralMapString(Neighboors:Hash<NodeLink>,horizontal:Bool=true):String {
		
		var ordered:Array<Node>= new Array<Node>();
		var temporal:Node;
		var i:Float = 0;			
		var j:Float = 0;
		var map:String="";

		
		//retrieve all the neighbors
		for (link in Neighboors) {
			ordered.push(link.getNeighbor(this));
		}
		
		if (ordered.length == 0 ) {
			if (horizontal) {
				return GenerateLateralGeography(cols, heightfromground);
			}else {
				return GenerateLateralGeography(rows, heightfromground);
			}
		}
		
		
		
		
		//order them
		for ( i in 0 ... ordered.length ) {
			for (j in i + 1 ... ordered.length) {
				if ( lateramMapStringCondition( ordered[i], ordered[j],horizontal)) {
					temporal = ordered[i];
					ordered[i] = ordered[j];
					ordered[j] = temporal;
					temporal = null;
				}					
			}
		}
		
		//create the map 
		
		if( ordered.length > 0){
			var rowpart:String = "";
			var row:String = "";
			var lastaxis:Float;
			var allzeros:Bool=false;
			var gap:Int = 0;
			var lenght:Int = 0;
			j = 0;
			
			while (!allzeros) {
				allzeros = true; 
				lenght   = 0;
				
				if (horizontal) {
					lastaxis =  this.Tj;
				}else {
					lastaxis =  this.Ti;
				}
						
				//iterate through the neighboors
				for (i in 0 ... ordered.length) {
					//check if there is a gap between the last node and this
					if (horizontal) {
						gap = Math.floor(ordered[i].Tj - lastaxis);
					}else {
						gap = Math.floor(ordered[i].Ti - lastaxis);
					}
					if (gap > 0) {
						rowpart = getrowpart(gap, 0);
						lenght += gap;
						row += buildnextrowpart(row,rowpart);
					}
											
					//add the next node part of the row
					if(Neighboors.get(ordered[i].tag).isUpperNode(this)){						
						if( j >= Neighboors.get(ordered[i].tag).Height){ 				
							rowpart = getrowpart(Neighboors.get(ordered[i].tag).Linkspan, 0);
						}else{
							rowpart = getrowpart(Neighboors.get(ordered[i].tag).Linkspan, 1);
							allzeros = false;
						}
					}else {
						rowpart = getrowpart(Neighboors.get(ordered[i].tag).Linkspan, 0);
					}
					lenght += Math.floor(Neighboors.get(ordered[i].tag).Linkspan);
					row += buildnextrowpart(row,rowpart);
					
					
					//get the value to check gaps
					if(horizontal){
						lastaxis = ordered[i].Tj + ordered[i].cols; 
					}else{
						lastaxis = ordered[i].Ti + ordered[i].rows; 
					}
				}
				
				//check if there is a gap in the end
				if ( horizontal) {
					gap = lenght - this.cols;
				}else {
					gap = lenght - this.rows;
				}					 					
				if (gap!=0) {
					rowpart = getrowpart(gap, 0);
					row += buildnextrowpart(row,rowpart);
				}					
				
				if (!allzeros) {
					if (j == 0) {
						map += row;
					}else {
						map += "\n"+row;
					}
				}
				row = "";
				j++;
			}
		}
		return map;
	}
	
	private function buildnextrowpart(row:String, rowpart:String):String {
		if (row == "") {
			return  ""   + rowpart;
		}else {
			return "," + rowpart;
		}
		return "";
	}
	
	private function getrowpart(lenght:Int, value:Float):String {
		var i:Float = 0;
		var result:String="";
		for ( i in 0 ... lenght ) {
			result += "" + value;
			if ( (i + 1) < lenght) {
				result += ",";
			}
		}
		return result;
	}		
	
	private function lateramMapStringCondition(actualNode:Node,tocompare:Node,horizontal:Bool):Bool {
		if (horizontal){
			return tocompare.Tj < actualNode.Tj;
		}else {
			return tocompare.Ti < actualNode.Ti;				
		}
	}
	
	private function GenerateLateralGeography(Width:Int, Height:Int):String {
		var i:UInt;
		var j:UInt;
		var lateralgeography:String="";
		for (i in 0 ... Height) {
			for (j in 0 ... Width) {
				lateralgeography+="1";
				if ((j + 1) != Width) {
					lateralgeography+=",";
				}else if ((i + 1) != Height){
					lateralgeography+="\n";
				}
			}
		}
		return lateralgeography;
	}
	
	
	/*
	 * sort the order of this node boats
	 */ 
	
	public function sortBoats():Void {
		
	}
	
	
	/*
	 * adds a boat to this node
	 */ 		
	public function addBoat(node:Node):Void {
		var name:String = getBoatName(node);
		boats.set(name, node);
	}
	/*
	 * removes a boat to this node
	 */ 		
	public function removeBoat(node:Node):Void {
		var name:String = getBoatName(node);
		boats.remove(name);
	}
	
	private function getBoatName(node:Node):String {
		return "BO" + node.Ti + node.Tj;
	}
	
	
	
	
					
	/**
	 * Destroys this element, freeing memeory.
	 * 
	 */

	public function destroy():Void {
		destroyneighborobjec(northenNeighbors);
		destroyneighborobjec(southernNeighbors);
		destroyneighborobjec(westernNeighbors);
		destroyneighborobjec(easternNeighbors);
		
	}
	
	private function destroyneighborobjec(neighboors:Hash<NodeLink>):Void {
		for (key in neighboors.keys()) {
			try{
				neighboors.set(key, null);
			}catch(e:Dynamic ) {
				
			}
		}
		neighboors = null;
	}
	
}	
