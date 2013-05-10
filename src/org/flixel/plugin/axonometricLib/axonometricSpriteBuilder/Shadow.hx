package org.flixel.plugin.axonometricLib.axonometricSpriteBuilder;

import flash.geom.Point;
import nme.Assets;
import org.flixel.FlxSprite;
/**
 * shadow of the sprite.
 * 
 * @author Miguel Ángel Piedras Carrillo, Jimmy Delas (Haxe port)
 */
class Shadow extends FlxSprite
{		
//	[Embed(source = "oval_shadow_anim.png")]  		   	  private static var img_shadow_anim  :Class;
	private static var img_shadow_anim:Dynamic = "axonometric_oval_shadow_anim";
	private var owner:AxonometricSprite;
	private var mywidth :Int = 210;
	private var myheight:Int= 80;
	private var shadow_size_steps:Int= 15;
	private var MaxHeight:Int = 300;
	
	/*
	 * the current drop size
	 */ 
	public var dropsize:Int = 0 ;
	
	
	/**
	 * contructor
	 * 
	 * @param owner the owner of the shadow
	 * 
	 */ 
	public function new(owner:AxonometricSprite){
		super();
		loadGraphic(img_shadow_anim, true, true, 18, 12);
		for (i in 0 ... shadow_size_steps) {				
			addAnimation(i+"", [i], 0, false);
		}			
		mywidth    = 18;
		myheight   = 12;						
		width      = 0;   
		height     = 0;	

		this.offset.x  = (mywidth  - width)  / 2;
		this.offset.y  = (myheight - height) / 2;
					
		if(owner != null){
			owner.offset.x += this.offset.x  ;
			owner.offset.y += this.offset.y  ;						
		}			
		this.owner = owner;
	}
	
	override public function update():Void {
		owner.moveOrder();
	}
			
	/**
	 * sets the size of the shadow
	 * 
	 * @param jumpHeight the size of the jummp
	 * 
	 * 
	 */
	public function shadowSize(jumpHeight:Int):Void {			
		jumpHeight = (jumpHeight <= 0)        ? 0         : jumpHeight  ;
		jumpHeight = (jumpHeight > MaxHeight) ? MaxHeight : jumpHeight  ;
		play
		(
			(
			Math.floor
				(
					(  jumpHeight * (shadow_size_steps-1)  ) / MaxHeight
				)
			)
			+""
		);
	}

	/**
	 * check the drop, of the shaeow
	 * 
	 * @param dropsize the size of the drop
	 * 
	 * 
	 */
	public function walldrop(dropsize:Int):Bool {
		var nudge:Int = 0;
		if(dropsize > 0){
			this.dropsize = dropsize;
			this.y += dropsize;			
			this.y += nudge;
			cast(owner, AxonometricSprite).jumping 	           =  true;
			cast(owner, AxonometricSprite).jumpHeight          +=  dropsize;
			cast(owner, AxonometricSprite).jump_now(0, 320);
			return true;
		}else if (dropsize < 0) {				
			if ( cast(owner, AxonometricSprite).jumpHeight > -dropsize) {
				this.dropsize = dropsize;
				this.y += dropsize;
				this.y -= nudge;
				cast(owner, AxonometricSprite).jumpHeight          +=  dropsize;
				cast(owner, AxonometricSprite).jump_now(0, 320);
				return true;
			}
		}
		return false;			
	}

}
