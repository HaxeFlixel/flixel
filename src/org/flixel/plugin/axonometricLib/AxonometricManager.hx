package org.flixel.plugin.axonometricLib;

import flash.display.BitmapData;
import org.flixel.plugin.axonometricLib.axonometricSpriteBuilder.AxonometricSprite;
//import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.Tools.*;
//import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.Tools.ParallelogramRendering.*;
//import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.Blueprint.*;
import org.flixel.plugin.axonometricLib.axonometricGroundBuilder.GroundBuilder;
import flash.geom.Point;
//import org.flixel.*;


/**
 * The delegate of the library and its classes, creates a floor from specific parameters, and puts sprites that interact with that floor.
 * 
 * @author	Miguel Ángel Piedras Carrillo, Jimmy Delas (Haxe port)
 */	

/**
 * TODO:
	 * Replace useless Float by Int or UInt
	 * Custom assets
	 * Some Dynamic should be typed
	 * Check for exceptions
	 * axonometricLib.axonometricGroundBuilder.tools.parallelogramRendering.ParallelTilemap.imageToCSV
 */

class AxonometricManager extends FlxGroup
{		
	private var builder	   :GroundBuilder;
	private var leftsided  :Bool;

	/**
	 * Initialize the parameters to begin construction.
	 * 
	 * @param	x						sets the x position of the map.
	 * @param	y						sets the y position of the map.
	 * @param	topography				string that represents by numbers separated by commas and line breaks the height of the floor in each given position.
	 */				
	public function new(x:Float,y:Float,topography:String){			
		super();
		builder = new GroundBuilder(new Point(x, y), topography);
	}
	
	/**
	 * Optional sets a descriptor to have more control over the shape and texture of the ground, the ratios of the images must be accurate in order to this to work propertly.
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
	public function SetBlockDescriptor(BlockWidth:Int, BlockHeight:Int, BlockDepth:Int, TilemapWidthDepth:BitmapData, TilemapWidthHeight:BitmapData, TilemapDepthHeight:BitmapData, geography:String=""):Void {
		builder.SetBlockDescriptor(BlockWidth, BlockHeight, BlockDepth, TilemapWidthDepth, TilemapWidthHeight, TilemapDepthHeight, geography);
	}

	/**
	 * Creates the stage with a trimetric shape.
	 * 
	 * @param	theta					Angle measured in radians, it defines the shape of the plane yx (for correct functionality , theta+phi must form an angle bigger thanPI).
	 * @param	phi						Angle measured in radians, it defines the shape of the plane xz (for correct functionality , theta+phi must form an angle bigger than PI).
	 * @param	leftsided				Sets the floor with a left inclination.
	 * @param	debug					Sets the debugging mode.
	 */						
	public function SetAsTrimetric(theta:Float, phi:Float, leftsided:Bool=false,debug:Bool = false):Void {			
		try{
			theta = Math.abs(theta);
			phi = Math.abs(phi);
						
			if(leftsided){			
				this.add(builder.RenderFunction( theta ,  phi, debug));
			}else {
				this.add(builder.RenderFunction(-theta , -phi, debug));
			}
			this.leftsided = leftsided;
		}catch (errObject:Dynamic) {
			
		}
	}
			
	/**
	 * Creates the stage with a dimetric shape.
	 * 
	 * @param	theta					Angle measured in radians, it defines the shape of the plane yx and yz (for correct functionality , theta must form an angle bigger than PI/2)
	 * @param	leftsided				Sets the floor with a left inclination.
	 * @param	debug					Sets the debugging mode.
	 */								
	public function SetAsDimetric(theta:Float, leftsided:Bool=false,debug:Bool = false):Void {			
		try{
			theta = Math.abs(theta);

			if(leftsided){			
				this.add(builder.RenderFunction( theta ,  (2*Math.PI-2*theta), debug));
			}else {
				this.add(builder.RenderFunction(-theta , -(2*Math.PI-2*theta), debug));
			}
			this.leftsided = leftsided;
		}catch (errObject:Dynamic) {
		}
	}
	
	/**
	 * Creates the stage wit an isometric shape.
	 * 
	 * @param	leftsided				Sets the floor with a left inclination.
	 * @param	debug					Sets the debugging mode.
	 */								
	public function SetAsIsometric(leftsided:Bool = false, debug:Bool = false):Void {
		try{
			if (leftsided) {
				this.add(builder.RenderFunction(  2*Math.PI/3 ,  2*Math.PI/3, debug));
			}else {
				this.add(builder.RenderFunction( -2*Math.PI/3 , -2*Math.PI/3, debug));
			}			
			this.leftsided = leftsided;
		}catch (errObject:Dynamic) {				
		}
	}
	
	/**
	 * Creates an oblique stage on the yx plane.
	 * 
	 * @param	phi						Angle measured in radians, it defines the shape of the plane xz (for correct functionality phi must form a bigger angle than PI/2)
	 * @param	leftsided				Sets the floor with a left inclination.
	 * @param	debug					Sets the debugging mode.
	 */								
	public function SetAsObliqueYX(phi:Float,leftsided:Bool = false, debug:Bool = false):Void {
		try{
			phi = Math.abs(phi);
			if(leftsided){			
				this.add(builder.RenderFunction(  Math.PI/2 ,  phi, debug));
			}else {
				this.add(builder.RenderFunction( -Math.PI/2 , -phi, debug));
			}
			this.leftsided = leftsided;
		}catch (errObject:Dynamic){}
	}
			
	/**
	 * Creates an oblique stage on the xz plane.
	 * 
	 * @param	theta					Angle measured in radians, it defines the shape of the plane yx (for correct functionality theta must form a bigger angle than PI/2)
	 * @param	leftsided				Sets the floor with a left inclination.
	 * @param	debug					Sets the debugging mode.
	 */
	public function SetAsObliqueXZ(theta:Float,leftsided:Bool = false, debug:Bool = false):Void {
		try{
			theta = Math.abs(theta);
			if(leftsided){			
				this.add(builder.RenderFunction(  theta,  Math.PI/2 , debug));
			}else {
				this.add(builder.RenderFunction( -theta, -Math.PI/2 , debug));
			}
			this.leftsided = leftsided;
		}catch (errObject:Dynamic) {				
		}
	}
	
	/**
	 * Creates an oblique stage on the zy plane.
	 * 
	 * @param	theta					Angle measured in radians, it defines the shape of the plane yx (for correct functionality theta must form a bigger angle than PI/2)
	 * @param	leftsided				Sets the floor with a left inclination.
	 * @param	debug					Sets the debugging mode.
	 */
	public function SetAsObliqueZY(theta:Float,leftsided:Bool = false, debug:Bool = false):Void {
		try{
			theta = Math.abs(theta);			
			if(leftsided){			
				this.add(builder.RenderFunction(  theta,  (2*Math.PI-theta-Math.PI/2) , debug));
			}else {
				this.add(builder.RenderFunction( -theta, -(2*Math.PI-theta-Math.PI/2) , debug));
			}
			this.leftsided = leftsided;
		}catch (errObject:Dynamic) {
		}
	}

	/**
	 * Adds an element to the world, if the position is invalid, it will be set on 0,0
	 * 
	 * @param	i						Position of the row to put the sprite, given the topography as reference
	 * @param	j						Position of the column to put the sprite, given the topography as reference
	 * @param	sprite					sprite of the AxonometricSprite class to be added to stage 
	 */		
	public function AddElement(i:Int, j:Int, sprite:AxonometricSprite):Void {
		builder.AddElement(i, j, sprite,leftsided);
	}
	/**
	 * Removes a sprite from the world
	 * 
	 * @param	sprite					sprite of the AxonometricSprite class to be added to stage 
	 */		
	public function removeElement(sprite:AxonometricSprite):Void {			
		builder.removeElement(sprite);
	}

	/**
	 * Destroys this element, freeing memeory.
	 * 
	 */		
	override public function destroy():Void {
		builder.destroy();
		//super.destroy();
	}
}
