package flixel.system.render.gl;

import lime.graphics.opengl.GL;
import flixel.system.render.gl.FlxBatchElement.FlxQuadBatchElement;
import flixel.util.FlxPool;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.quad.FlxDrawTrianglesItem.DrawData;
import flixel.util.FlxColor;
import haxe.Constraints.Function;
import openfl.display.BlendMode;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Point;

class FlxGLView extends FlxCameraView
{
    // TODO: abstract away the camera adding so that we don't need a flash sprite
    var dummySprite:Sprite = new Sprite();


    var _elements:Array<FlxBatchElement> = [];

    var _renderer(get, never):FlxGLRenderer;
	inline function get__renderer() return cast (FlxG.renderer, FlxGLRenderer);

    public function new(camera:FlxCamera)
    {
        super(camera);

        dummySprite.visible = false;
    }

    // =============================================================================
	//{ region                         RENDERING
	// =============================================================================

    override function clear() 
    {
        _renderer.resize(camera.width, camera.height);
    }

    override function render()
    {
        // Submit all the collected sprites to the batcher
        for (element in _elements)
            _renderer.quadBatcher.add(cast element);

        // Force a flush to draw whatever was left in the buffer
        _renderer.quadBatcher.flush();

        _elements.resize(0);
    }

    override function fill(color:FlxColor, blendAlpha:Bool = true)
	{
		// super.fill(color, blendAlpha);
	}
	
	override function drawPixels(pixels, matrix, ?transform, ?blend, smoothing = false, ?shader)
	{
		// super.drawPixels(frame, matrix, transform, blend, smoothing, shader);
		throw "Not implemented";
	}
	
	override function copyPixels(pixels, ?sourceRect, destPoint, ?transform, ?blend, smoothing = false, ?shader)
	{
		// super.copyPixels(pixels, sourceRect, destPoint, transform, blend, smoothing, shader);
		throw "Not implemented";
	}
	
	override function drawFrame(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing = false, ?shader)
	{
		// super.drawFrame(frame, matrix, transform, blend, smoothing, shader);
        // _renderer.QuadBatcher.addQuad(frame, matrix,)

        var mat = new FlxMatrix();
        mat.copyFrom(matrix);

        // var quad = quadElementPool.get();
        var quad = new FlxQuadBatchElement();
        quad.frame = frame;
        quad.matrix = mat;
        quad.colorTransform = transform;
        quad.blend = blend;
        quad.textureSmoothing = smoothing;
        quad.shader = shader;

        _elements.push(quad);

        // _elements[_elementIndex++] = quad;
	}
	
	@:noCompletion
	static final _helperMatrix = new FlxMatrix();
	override function copyFrame(frame:FlxFrame, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode, smoothing = false, ?shader:FlxShader)
	{
		// super.copyFrame(frame, destPoint, transform, blend, smoothing, shader);
	}
	
	override function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>,
			?position:FlxPoint, ?blend:BlendMode, repeat = false, smoothing = false, ?transform:ColorTransform, ?shader:FlxShader)
	{
		// super.drawTriangles(graphic, vertices, indices, uvtData, colors, position, blend, repeat, smoothing, transform, shader);
	}

    // =============================================================================
	//} endregion                      RENDERING
	// =============================================================================

    // =============================================================================
	//{ region                            DEBUG DRAW
	// =============================================================================

    public function beginDrawDebug():Void {}

	public function endDrawDebug():Void {}

    #if FLX_DEBUG
	public function getDebugBuffer():FlxCanvas { return null; }
	
	function worldToDebugX(worldX:Float):Float
    {
        //TODO: find out what "debug space" actually is, rename and make public
        return worldX;
    }

	function worldToDebugY(worldY:Float):Float
    {
        //TODO: find out what "debug space" actually is, rename and make public
        return worldY;
    }
	#end

    // =============================================================================
	//} endregion                         DEBUG DRAW
	// =============================================================================

    // =============================================================================
	//{ region                             HELPERS
	// =============================================================================

    public function offsetView(x:Float, y:Float):Void {}

    function updateInternals():Void {}

    function updateOffset():Void {}

    function updatePosition():Void {}
    
    function updateScale():Void {}

    function updateScrollRect():Void {}

    // =============================================================================
	//} endregion                          HELPERS
	// =============================================================================

    // =============================================================================
	//{ region                             GETTERS
	// =============================================================================

    function get_display():DisplayObjectContainer
    {
        return dummySprite;
    }

    // =============================================================================
	//} endregion                          GETTERS
	// =============================================================================
}
