package com.asliceofcrazypie.flash;

#if flash11
import haxe.ds.StringMap;
import flash.display3D.Context3DBlendFactor;
import flash.display.BlendMode;
import flash.display3D.Context3D;

/**
 * ...
 * @author Zaphod
 */
class BlendModeUtil
{

	public static inline var BLEND_NORMAL:String = "normal";
	public static inline var BLEND_ADD:String = "add";
	public static inline var BLEND_MULTIPLY:String = "multiply";
	public static inline var BLEND_SCREEN:String = "screen";
	
	private static var premultipliedBlendFactors:StringMap<Array<Context3DBlendFactor>>;
	private static var noPremultipliedBlendFactors:StringMap<Array<Context3DBlendFactor>>;
	
	@:allow(com.asliceofcrazypie.flash)
	private static function initBlendFactors():Void
	{
		if (BlendModeUtil.premultipliedBlendFactors == null)
		{
			BlendModeUtil.premultipliedBlendFactors = new StringMap();
			BlendModeUtil.premultipliedBlendFactors.set(BLEND_NORMAL, [Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA]);
			BlendModeUtil.premultipliedBlendFactors.set(BLEND_ADD, [Context3DBlendFactor.ONE, Context3DBlendFactor.ONE]);
			BlendModeUtil.premultipliedBlendFactors.set(BLEND_MULTIPLY, [Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA]);
			BlendModeUtil.premultipliedBlendFactors.set(BLEND_SCREEN, [Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR]);
			
			BlendModeUtil.noPremultipliedBlendFactors = new StringMap();
			BlendModeUtil.noPremultipliedBlendFactors.set(BLEND_NORMAL, [Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA]);
			BlendModeUtil.noPremultipliedBlendFactors.set(BLEND_ADD, [Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.DESTINATION_ALPHA]);
			BlendModeUtil.noPremultipliedBlendFactors.set(BLEND_MULTIPLY, [Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA]);
			BlendModeUtil.noPremultipliedBlendFactors.set(BLEND_SCREEN, [Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE]);
		}
	}
	
	public static function applyToContext(blendMode:BlendMode, context:ContextWrapper, premultipliedAlpha:Bool):Void
	{
		var factors = BlendModeUtil.premultipliedBlendFactors;
		if (!premultipliedAlpha)
		{
			factors = BlendModeUtil.noPremultipliedBlendFactors;
		}
		
		var blendString:String = switch (blendMode)
		{
			case BlendMode.ADD:
				BlendModeUtil.BLEND_ADD;
			case BlendMode.MULTIPLY:
				BlendModeUtil.BLEND_MULTIPLY;
			case BlendMode.SCREEN:
				BlendModeUtil.BLEND_SCREEN;
			default:
				BlendModeUtil.BLEND_NORMAL;
		}
		
		var factor:Array<Context3DBlendFactor> = factors.get(blendString);
		if (factor == null)
		{
			factor = factors.get(BlendModeUtil.BLEND_NORMAL);
		}
		
		context.context3D.setBlendFactors(factor[0], factor[1]);
	}
}
#end