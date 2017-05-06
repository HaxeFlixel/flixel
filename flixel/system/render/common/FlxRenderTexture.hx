package flixel.system.render.common;

/**
 * @author Zaphod
 */
typedef FlxRenderTexture = #if FLX_RENDER_GL
								flixel.system.render.gl.FlxRenderTexture
							#else 
								flixel.system.render.blit.FlxRenderTexture
							#end;