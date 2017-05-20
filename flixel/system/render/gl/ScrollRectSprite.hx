package flixel.system.render.gl;

import openfl.display.Sprite;
import openfl.geom.Rectangle;
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLRenderer;

@:access(openfl._internal.renderer.opengl.GLRenderer)
@:access(openfl.geom.Rectangle)

class ScrollRectSprite extends Sprite
{
	private var clipRect:Rectangle = new Rectangle();
	private var tempRect:Rectangle = new Rectangle();
	
	public function new() 
	{
		super();
	}
	
	override function __renderGL(renderSession:RenderSession):Void 
	{
		if (!__renderable || __worldAlpha <= 0) 
			return;
		
		super.__renderGL(renderSession);
		
		scissor(__scrollRect, renderSession);
		renderSession.filterManager.pushObject(this);
		
		for (child in __children)
			child.__renderGL(renderSession);
		
		for (orphan in __removedChildren) 
		{	
			if (orphan.stage == null)
				orphan.__cleanup();
		}
		
		__removedChildren.length = 0;
		
		renderSession.filterManager.popObject(this);
		scissor(null, renderSession);
	}
	
	private function scissor(?rect:Rectangle, renderSession:RenderSession):Void 
	{
		var gl = renderSession.gl;
		
		if (rect != null)
		{
			rect.__transform(tempRect, __renderTransform);
			
			if (tempRect.height < 0)
				tempRect.height = 0;
			
			if (tempRect.width < 0)
				tempRect.width = 0;
			
			var renderer:GLRenderer = cast renderSession.renderer;
			tempRect.__transform(clipRect, renderer.displayMatrix);
			
			var x = Std.int(clipRect.x);
			var y = Std.int(clipRect.y);
			var width = Math.ceil(clipRect.width);
			var height = Std.int(renderer.height - clipRect.y);
			
			if (width < 0) width = 0;
			if (height < 0) height = 0;
			
			gl.enable(gl.SCISSOR_TEST);
			gl.scissor(x, y, width, height);
		}
		else
		{
			gl.disable(gl.SCISSOR_TEST);
		}
	}
}