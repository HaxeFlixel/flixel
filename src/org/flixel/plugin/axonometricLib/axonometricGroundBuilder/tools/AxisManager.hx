package org.flixel.plugin.axonometricLib.axonometricGroundBuilder.tools;
import flash.geom.Point;	
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import org.flixel.FlxG;
/**
 * The axis manager is in charge of the positioning of the items on stage, in reference to the new 2.5d stage
 * 
 * @author Miguel Ángel Piedras Carrillo, Jimmy Delas (Haxe port)
 */
class AxisManager 
{

	/**
	 * the center of the stage in reference to the new 2.5d stage
	 */
	public var center:Point;
	/**
	 * vector pointing to the X axis
	 */
	public var axisX:Point;
	/**
	 * vector pointing to the Y axis, it's alwais pointing to the negative y axis of the original stage to use its jump physics 
	 */
	public var axisY:Point;
	/**
	 * vector pointing to the Z axis
	 */
	public var axisZ:Point;
	
	/*
	 * descritpor of the block used in the stage
	 */ 		
	public var descriptor:BlockDescriptor;
	
	/*
	 * angle of the first plane
	 */ 		
	public var theta:Float;

	/*
	 * angle of the second plane
	 */ 		
	public var phi:Float;

	/**
	 * constructor of the manager
	 * 
	 * @param	Descriptor	block descriptor
	 * @param	Center   	center of the stge with reference at the old stage
	 */
	public function new(Descriptor:BlockDescriptor,Center:Point) 
	{
		this.descriptor = Descriptor;
		this.center     = Center;
	}
			
	/**
	 * gets the equivalent 2D position of the stage given it's unitary coordinates of the floor
	 * 
	 * @param	i	coordinate on the x axis
	 * @param	j	coordinate on the z axis
	 * @param	k	coordinate on the y axis
	 */
	public function getLocationFromGround(i:Float, j:Float, k:Float):Point {
		var x:Float =  i * descriptor.BlockWidth+descriptor.BlockWidth/2;
		var y:Float = -k * descriptor.BlockHeight;
		var z:Float =  j * descriptor.BlockDepth+descriptor.BlockDepth/2;
		var point:Point = Get2dCord(x, y, z);
		point.x += center.x;
		point.y += center.y;
		return point;
	}

	/**
	 * sets the shape of the axis
	 * 
	 * @param	theta	the angle of the first plane
	 * @param	phi		the angle of the second plane
	 * @param	debug	coordinate on the y axis
	 */
	public function setAxis(theta:Float, phi:Float,debug:Bool = false):Void {
		this.theta = theta;
		this.phi = phi;
		
		//y is negative "up" in computers, so a "computer positve angle" is a trig negative
		axisX        = new Point(Math.sin(-theta)         ,-Math.cos(-theta)      );
		axisZ        = new Point(Math.sin(-theta - phi)   ,-Math.cos(-theta - phi));
		axisY        = new Point(0                        , 1);
		
		if(debug){
			var gfx:Graphics = FlxG.flashGfx;
			var dist:Float = 1500;
			var linesize:Float = 1;															
			gfx.lineStyle(1,FlxG.WHITE,linesize);//
			gfx.moveTo((center.x                 )*FlxG.camera.zoom , (center.y                 )*FlxG.camera.zoom);
			gfx.lineTo((center.x+axisX.x*dist    )*FlxG.camera.zoom , (center.y + axisX.y*dist  )*FlxG.camera.zoom);
			gfx.moveTo((center.x                 )*FlxG.camera.zoom , (center.y                 )*FlxG.camera.zoom);
			gfx.lineTo((center.x-axisY.x*dist    )*FlxG.camera.zoom , (center.y - axisY.y*dist  )*FlxG.camera.zoom);
			gfx.moveTo((center.x                 )*FlxG.camera.zoom , (center.y                 )*FlxG.camera.zoom);
			gfx.lineTo((center.x + axisZ.x * dist)*FlxG.camera.zoom , (center.y + axisZ.y * dist)*FlxG.camera.zoom);
			var Axis:BitmapData = new BitmapData(Math.floor(FlxG.stage.width), Math.floor(FlxG.stage.height), true, 0x00000000);
			Axis.draw(FlxG.flashGfxSprite);
			FlxG.stage.addChild(new Bitmap(Axis));
		}
	}
	
	/**
	 * gets the equivalent 2D position of the stage given it's coordinates of the floor
	 * 
	 * @param	x	coordinate on the x axis
	 * @param	y	coordinate on the y axis
	 * @param	z	coordinate on the z axis
	 */
	public function Get2dCord(x:Float, y:Float , z:Float):Point{
		return new Point
			(
			Math.floor(x * axisX.x + y * axisY.x + z * axisZ.x)
			,
			Math.floor(x * axisX.y + y * axisY.y + z * axisZ.y)
			);
	}
	
	/**
	 * Destroys this element, freeing memeory.
	 * 
	 */		
	public function destroy():Void {
		descriptor.destroy();
		center=null;
		axisX=null;
		axisY=null;
		axisZ=null;
	}

}
