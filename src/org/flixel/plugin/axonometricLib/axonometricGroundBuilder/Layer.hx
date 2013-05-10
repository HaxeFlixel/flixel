package org.flixel.plugin.axonometricLib.axonometricGroundBuilder; 

import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.blueprint.Model;
import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.blueprint.Node;
import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.tools.AxisManager;
import org.flixel.FlxGroup;
import org.flixel.plugin.axonometricLib.axonometricSpriteBuilder.AxonometricSprite;
/**
 *   A layer has a collection of the objects shown in screen
 * @author Miguel Ángel Piedras Carrillo
 */
class Layer extends FlxGroup
{
	/*
	 * the level of the layer
	 */ 		
	public var level:Int;
	
	
	private var layerNodes:Array<Node>;
//	private var PlatformObjects:Object;
	
	/**
	 * contructor of the layer
	 * 
	 * @param level  Sets the level of the layer
	 * 
	 */ 		
	public function new(level:Int) 
	{
		super();
		this.level = level;
		layerNodes = new Array<Node>();
	}
	
	
	public function RenderBoats(boat:Node,position:AxisManager,debug:Bool):FlxGroup {

		for (key in boat.boats.keys()) {
			layerNodes.push(boat.boats.get(key));
		}			
		//bubble-sorting the Nodes
		var node:Node  = null;
		for ( i in 0 ... layerNodes.length) {
			for ( j in i+1 ... layerNodes.length) {
				if ( layerNodes[j].Tj < layerNodes[i].Tj) {
					node = layerNodes[j];
					layerNodes[j] = layerNodes[i];
					layerNodes[i] =  node;
				}
			}
		}
		
		node = null;
		//adding the platforms 
		var layer:Layer;
		for ( i in 0 ... layerNodes.length) {
			node = layerNodes[i]; 
			layer = new Layer(0);
			add(layer.RenderBoats(node,position,debug));
		}
		boat.platformRender = new Platform(boat, position, debug);
		add( boat.platformRender);
		
		return this;
	}		

	/**
	 * Destroys this element, freeing memeory.
	 * 
	 */
	override public function destroy():Void {
		super.kill();
	}
	
	
}
