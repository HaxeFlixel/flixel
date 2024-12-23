package flixel.system.frontEnds;

import flixel.FlxG.FlxRenderMethod as RenderMethod;

class DisplayFrontEnd
{
	public function new () {}
	
	public var render(get, never):FlxRenderMethod;
	inline function get_render():FlxRenderMethod
	{
		return FlxG.renderMethod;
	}
	
	public var pixelMode(default, set):FlxPixelMode;
	inline function set_pixelMode(value:FlxPixelMode)
	{
		switch value
		{
			case CUSTOM:// do nothing
			case PIXELATED:
				FlxSprite.defaultAntialiasing = false;
				
				if (FlxG.state != null)
					FlxG.stage.quality = LOW;
				
				#if html5
				lime.app.Application.current.window.element.style.setProperty("image-rendering", "pixelated");
				#end
			case SMOOTH:
				FlxSprite.defaultAntialiasing = true;
				
				if (FlxG.state != null)
					FlxG.stage.quality = HIGH;
				
				#if html5
				lime.app.Application.current.window.element.style.removeProperty("image-rendering");
				#end
		}
		return pixelMode = value;
	}
}

abstract FlxRenderMethod(RenderMethod) from RenderMethod
{
	public var blit(get, never):Bool;
	inline function get_blit() return this == BLITTING;
	
	public var tile(get, never):Bool;
	inline function get_tile() return this == DRAW_TILES;
}

enum FlxPixelMode
{
	/**
	 * Enables various features that result in crisp pixels, namely:
	 * - Changes `FlxSprite.defaultAntialiasing` to `false`
	 * - On web, changes the `image-rendering` to `"pixelated"`
	 */
	PIXELATED;
	
	/**
	 * Makes no changes to any default redering properties
	 */
	CUSTOM;
	
	/**
	 * Enables various features that result in crisp pixels, namely:
	 * - Changes `FlxSprite.defaultAntialiasing` to `true`
	 * - On web, changes the `image-rendering` to `"pixelated"`
	 */
	SMOOTH;
}
