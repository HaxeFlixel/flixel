package org.flixel.plugin.axonometricLib.axonometricGroundBuilder.blueprint;
/**
 * Sets the model wich serves as a blueprint to create the stage
 * 
 * @author Miguel Ángel Piedras Carrillo, Jimmy Delas (Haxe port)
 */
class Model 
{
	private var highestValue:Float;
	private var lowestValue:Float;		
	private var geography:Array<String>;
	private var topography:Array<String>;
	private var nodeCount:Float;
	
	/**
	 *  The amount of rows of the map
	 */
	public var maxRows:Int = 0; 
	/**
	 *  The amount of cols of the map
	 */
	public var maxCols:Int = 0;
	
	/**
	 * The array of nodes genereted at creating the model
	 */
	public var nodes:Array<Node>;
	
	/**
	 * An array of the nodes created for easy access
	 */
	public var nodesObject:Hash<Node>;
	
	
	/**
	 * the roots of the model
	 */
	public var boats:Array<Node>;
	
	/**
	 * 
	 * The contructor of the class
	 * 
	 * @param	geographyMap	string that represents by numbers separated by commas and line breaks the tile of the floor in each given position.
	 * @param	topographyMap	string that represents by numbers separated by commas and line breaks the height of the floor in each given position.
	 * @param	invertNodes		inverts the order of the nodes, for when the orientation of the map is "leftsided"
	 */		
	public function new(geographyMap:String, topographyMap:String, invertNodes:Bool ) {		
		lowestValue = Math.POSITIVE_INFINITY;
		highestValue = Math.NEGATIVE_INFINITY;
		nodeCount = 0;
		geography = new Array<String>();
		topography = new Array<String>();
		nodes = new Array<Node>();
		nodesObject = new Hash<Node>();
		GenerateMap(topographyMap, topography, invertNodes);
		GenerateMap(geographyMap ,  geography ,invertNodes);	

		var i:Float = 0;
		var j:Float = 0;
		for (i in 0 ... maxRows) {
			for (j in 0 ... maxCols) {
				if ( Std.parseFloat(GetTopography(i,j)) > highestValue) {						
					highestValue = Std.parseFloat(GetTopography(i, j));
				}
				if ( Std.parseFloat(GetTopography(i,j)) < lowestValue) {
					lowestValue  = Std.parseFloat(GetTopography(i, j));
				}					
			}
		}
		boats = new Array<Node>();
		GenerateNodes();
		GenerateNodeLinks();
	}
	
	private function GenerateMap(Map:String, Arr:Array<String>, invertNodes:Bool):Void {
		if (Map == "") {
			for (i in 0 ... maxRows) {
				for (j in 0 ... maxCols) {
					Arr.push("1");
				}
			}
		}else{
			var columns:Array<String>;
			var rows:Array<String> = Map.split("\n");
			maxRows= rows.length;
			maxCols =0;
			var i : Int = 0;
			while(i < maxRows)
			{
				columns = rows[i++].split(",");
				if(maxCols == 0)
					maxCols = columns.length;
				var j : Int = 0;
				while (j < maxCols) {
					if(!invertNodes){
						Arr.push(columns[j]);
					}else {
						Arr.push(columns[maxCols-1-j]);
					}
					j++;
				}
			}
		}
	}
	
	private function GenerateNodes(debug:Bool=false):Void {
		var i:Float=0;
		var j:Float=0;			
		
		for (i in 0 ... maxRows) {
			for (j in 0 ... maxCols) {
				if ( GetTopography(i, j).indexOf("N") == -1) {
					checkNextNode(i, j, GetTopography(i, j));
				}
			}
		}
		
		if (true) {
//			trace("current Topography:");
			tracecurrentTopography();
		}				
	}
	
	private function tracecurrentTopography():Void {
		var row:String="";
		
		for (i in 0 ... maxRows) {
			for (j in 0 ... maxCols) {
				row += GetTopography(i, j);					
				if ((j + 1) != maxCols) {
					row+=",";
				}
			}
//			trace(row);
			row = "";
		}
//		trace("------------------");
	}
			
	private function checkNextNode(Ti:Int, Tj:Int, value:String):Void {
		var rows:Int = 1;
		var cols:Int = 1;
		
		var stopcol:Bool = false;
		var stoprow:Bool = false;
		
		while (  !stopcol || !stoprow ){			
			if (!stopcol) {
				if (tryRectangle(Ti, Tj, rows  , cols + 1, value)) {
					cols++;
				}else {
					stopcol = true;
				}					
			}				
			if(!stoprow ) {
				if (tryRectangle(Ti, Tj, rows + 1, cols    , value)) {
					rows++;
				}else {
					stoprow = true;
				}								
			}
		}

		var extra:String;
		
		if (nodeCount < 10) {
			extra = "0";
		}else {
			extra = "";
		}
		
		
		var node:Node = new Node("N"+extra+nodeCount,cols,rows,Ti,Tj,Std.parseInt(value));
		
		for ( i in 0 ... rows ) {
			for ( j in 0 ... cols) {					
				SetTopography(Ti + i, Tj + j,"N"+extra+nodeCount);					
				node.geography += GetGeography(Ti+i,Tj+j);					
				if ((j + 1) != cols) {
					node.geography +=",";
				}else if ((i + 1) != rows){
					node.geography +="\n";
				}					
			}
		}
		
		nodes.push(node);
		nodeCount++;
		nodesObject.set(node.tag, node);

	}
	
	private function tryRectangle(Ti:Int, Tj:Int, rows:Int, cols:Int, value:String):Bool{
//		var t:Int;
		if ( (Ti + rows - 1) >= maxRows) {
			return false;
		}
		if ( (Tj + cols - 1) >= maxCols) {
			return false;
		}
		
		for ( i in 0 ... rows ) {
			for ( j in 0 ... cols ) {
				if ( GetTopography(Ti + i, Tj + j) != value) {
					return false;
				}
			}
		}
		return true;
		
	}				
			
	private function GenerateNodeLinks():Void {
		var i:Float = 0;
		var node:Node;
		for (i in 0 ... nodes.length) {
			node = nodes[i];
			SetNodeSides(node);
		}
		
		for (i in 0 ... nodes.length) {
			node = nodes[i];
			if ( node.anchor == null) {
				boats.push(node);
			}
			SetSpriteBelongingLayer(node);				
		}
		
		
		//bubble-sorting the boats
		node = null;
		var j:Float = 0;
		for ( i in 0 ... boats.length ) {
			for ( j in i+1 ... boats.length ) {
				if ( boats[j].Tj < boats[i].Tj) {
					node = boats[j];
					boats[j] = boats[i];
					boats[i] =  node;
				}
			}
			node = boats[i];
		}
		
	}
	
	private function SetNodeSides(node:Node):Void {
		SetWesternSide(node);
		SetEasternSide(node);
		SetNorthernSide(node);
		SetSouthernSide(node);
		SearchNodesToAnchor(node);
	}
	
	private function SetWesternSide(node:Node):Void {
		var i:Float = 0;
		
		for (i in 0 ... node.rows ) {
			if (SideExist(node.Ti + i, node.Tj-1)) {					
				node.AddWesternNeighborsLink( nodesObject.get(GetTopography(node.Ti + i, node.Tj - 1)));
			}
		}
	}
	
	private function SetEasternSide(node:Node):Void {
		var i:Float = 0;
		var firstval:Bool = true;			
		for (i in 0 ... node.rows ) {
			if (SideExist(node.Ti + (node.rows - 1 - i), node.Tj+(node.cols-1)+1 )) {					
				node.AddEasternNeighborsLink( nodesObject.get(GetTopography(node.Ti + (node.rows - 1 - i), node.Tj + (node.cols - 1) + 1)));
			}
		}
	}
	
	private function SetNorthernSide(node:Node):Void {
		var j:Float = 0;
		var firstval:Bool = true;
		
		for (j in 0 ... node.cols) {
			if (SideExist(node.Ti-1, node.Tj+j)) {					
				node.AddNorthenNeighbors( nodesObject.get(GetTopography(node.Ti - 1, node.Tj + j)));
			}
		}
	}
	
	private function SetSouthernSide(node:Node):Void {
		var j:Float = 0;
		
		for (j in 0 ... node.cols) {
			if (SideExist(node.Ti+ (node.rows-1)+1, node.Tj+j)) {					
				node.AddSouthernNeighbors( nodesObject.get(GetTopography(node.Ti + (node.rows - 1) + 1, node.Tj + j)));
			}
		}
	}		
	
	private function SetSpriteBelongingLayer(node:Node):Void {
	
			node.SpriteBelongsToThisNodeLayer = node;
	}
	
	private function SearchNodesToAnchor(node:Node):Void {
		var neighborlink:NodeLink;
		var neighbor:Node;
		for (key in node.northenNeighbors.keys()) {
			neighborlink = node.northenNeighbors.get(key);
				
				if( neighborlink.getNeighbor(node).anchor == null){					
					neighborlink.getNeighbor(node).anchor = node;
					node.addBoat(neighborlink.getNeighbor(node));
//					trace("anchor: "+node.tag+" ancled: "+neighborlink.getNeighbor(node).tag);
				}else if (node.Tj <  neighborlink.getNeighbor(node).anchor.Tj){
					neighborlink.getNeighbor(node).anchor.removeBoat(neighborlink.getNeighbor(node));						
					neighborlink.getNeighbor(node).anchor = node;
					node.addBoat(neighborlink.getNeighbor(node));
//					trace("anchor: "+node.tag+" ancled: "+neighborlink.getNeighbor(node).tag);
				}

		}
		
	}
	
			
	private function SideExist(i:Float, j:Float):Bool {
		if (i < 0 || i >= maxRows) {
			return false;
		}
		if (j < 0 || j >= maxCols) {
			return false;
		}
		return true;
	}
	
	/**
	 * 
	 * Gets the node in the corresponding i, j coordinate, it returns null if given an invalid location
	 * 
	 * @param	i	row of the node.
	 * @param	j	columnd of the node.
	 * 
	 */		
	public function getNodeInPos(i:Int, j:Int):Node {
		if (!SideExist(i, j)) {
			return null;
		}
		//tracecurrentTopography();
		
		var tag:String  = GetTopography(i, j);
		return nodesObject.get(tag);
	}
	
	
	private function GetTopography(i:Int, j:Int):String {
		return topography[i * maxCols + j];
	}
	
	private function SetTopography(i:Int, j:Int,val:String):Void{
		topography[i*maxCols + j] = val;
	}
	
	private function GetGeography(i:Int, j:Int):String {
		return geography[i * maxCols + j];
	}

	
	/**
	 * Destroys this element, freeing memeory.
	 * 
	 */
	public function destroy():Void {
		var i:Float;
		var j:Float;
		for (i in 0 ... maxRows) {
			for (j in 0 ... maxCols) {
				topography[i * maxCols + j] = null;
				geography[i * maxCols + j] = null;
			}
			
		}
		for (i in 0 ... nodes.length) {
			nodes[i].destroy();
		}

		// ????	
//		nodes
//		nodesObject
	}
	
	
}