package org.flixel.plugin.axonometricLib.axonometricGroundBuilder;

import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.blueprint.Model;
import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.blueprint.Node;
import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.tools.AxisManager;
import org.flixel.FlxGroup;
/**
 * The layer manager is in charge of setting platforms and sprites on corresponding layers to aVoid collsions between them
 * 
 * @author ??, Jimmy Delas (haxe Port)
 */
class LayerManager 
{
//	private var layersObject:Object;
//	private var ordered:Array;
	
	public function new()
	{
//		layersObject = new Object();
//		ordered = new Array();
	}
	
	public function GetMap(model:Model, position:AxisManager,debug:Bool):FlxGroup {
		var map:FlxGroup = new FlxGroup();
		var node:Node;
		var layer:Layer;
		for (i in 0 ... model.boats.length) {
			node = model.boats[i];
			layer = new Layer(0);
			map.add( layer.RenderBoats(node,position,debug));
		}
		return map;
	}

	/**
	 * Destroys this element, freeing memeory.
	 * 
	 */
	public function destroy():Void {
		//layersObject = null;
		//for (i in 0 ... ordered.length) {
			//try {
				//ordered[i].destroy();
				//ordered[i]= null;
			//}catch(e:Error){}
		//}
		//ordered = null;
	}
	
}