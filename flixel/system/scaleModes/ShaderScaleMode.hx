package flixel.system.scaleModes;

import flixel.FlxG;
import flixel.util.typeLimit.OneOfTwo;

#if !openfl_legacy
import shaders.ScaleShaderFilter;
import shaders.Nearest;
import shaders.Bilinear;

import openfl.filters.BitmapFilter;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import openfl.gl.GL;
#end

@:enum
abstract ShaderScaleEnum(Int){
	var NEAREST = 0;
	var BILINEAR = 1;
}

class ShaderScaleMode extends flixel.system.scaleModes.BaseScaleMode
{

	#if !openfl_legacy
	private var scaleX:Float;
	private var scaleY:Float;
	private var strength:Float;

	public var filter:shaders.ScaleShaderFilter;
	public var filters:Array<BitmapFilter>;

	public function new(?shader:OneOfTwo<ShaderScaleEnum, openfl.display.Shader> = ShaderScaleEnum.NEAREST, ?scaleX:Float = 1, ?scaleY:Float = 1){
		super();

		if(Std.is(shader,Shader)){
			this.filter = new ScaleShaderFilter(cast(shader,Shader));
		}else{
			switch (cast(shader,ShaderScaleEnum)) {
				case ShaderScaleEnum.NEAREST:
					this.filter = new ScaleShaderFilter(new Nearest());
				case ShaderScaleEnum.BILINEAR:
					this.filter = new ScaleShaderFilter(new Bilinear());
			}
		}

		this.setScale(scaleX, scaleY);
		this.setStrength(1);

		this.filters = [];

		FlxG.game.setFilters(filters);
		FlxG.game.filtersEnabled = true;

		FlxG.signals.postDraw.add(postDraw);
	}

	public function postDraw(){
		this.filter.resolution = [FlxG.stage.width, FlxG.stage.height];
	}

	public function setScale(?scaleX:Float = 1, ?scaleY:Float = 1){
		this.scaleX = scaleX;
		this.scaleY = scaleY;
		this.filter.scaleX = scaleX;
		this.filter.scaleY = scaleY;
		this.mouseMultiplier = new flixel.math.FlxPoint(1/scaleX, 1/scaleY);
	}

	public function setStrength(?strength:Float = 1){
		this.strength = strength;
	}

	public function activate(){
		filters.push(this.filter);
	}

	public function deactivate(){
		filters.remove(this.filter);
	}

	override private function updateScaleOffset():Void{
		scale.x = 1;
		scale.y = 1;
	}

	override private function updateGameSize(Width:Int, Height:Int):Void 
	{
		gameSize.x = FlxG.width;
		gameSize.y = FlxG.height;
	}

	override private function updateOffsetY(){
		offset.y = 0;
	}

	override private function updateOffsetX(){
		offset.x = 0;
	}
	#end
}