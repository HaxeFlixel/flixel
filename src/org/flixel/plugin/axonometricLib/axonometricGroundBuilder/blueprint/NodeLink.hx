package org.flixel.plugin.axonometricLib.axonometricGroundBuilder.blueprint;

/**
 * The conection between a node and its neighboor
 *
 * @author	Miguel Ángel Piedras Carrillo, Jimmy Delas (Haxe port)
 */
class NodeLink 
{
	/*
	 * tells if the link is the same height
	 */
	public var SameGround:Bool;
	/*
	 * sests the upper node
	 */
	public var UpperNode:Node;
	/*
	 * sets the lower node
	 */
	public var LowerNode:Node;
	/*
	 * diference of height between the nodes
	 */
	public var Height:Int;
	/*
	 * lenght of the link
	 */
	public var Linkspan:Int;
	
	
	/**
	 * constructor
	 * 
	 * @param UpperNode    Node with the greates height
	 * @param LowerNode    Node with the lowest height
	 * @param SameGround   Tells if the ground betweeen the nodes is the same
	 * 
	 */
	public function new(UpperNode:Node,LowerNode:Node,SameGround:Bool= false) 
	{
		this.UpperNode = UpperNode;
		this.LowerNode = LowerNode;
		this.SameGround = SameGround;
		Height = UpperNode.heightfromground - LowerNode.heightfromground;
		Linkspan = 1;
	}
	
	/**
	 * gets the neigbor of a node
	 * @param node   the node of wich the neighbor is wanted
	 */ 		
	public function getNeighbor(node:Node):Node {
		if (node == UpperNode) {
			return LowerNode;
		}else if (node == LowerNode) {
			return UpperNode;
		}
		return null;
	}
	
	/**
	 * tells if the node is the upper one
	 * @param node   the node to compare
	 */ 
	
	public function isUpperNode(node:Node):Bool {
		return node == UpperNode;
	}
	
}
