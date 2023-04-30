package flixel.effects.postprocess;

import flash.geom.Rectangle;
#if FLX_POST_PROCESS
import flixel.FlxG;
import openfl.Assets;
import openfl.display.OpenGLView;
import openfl.gl.GL;
import openfl.gl.GLFramebuffer;
import openfl.gl.GLRenderbuffer;
import openfl.gl.GLTexture;
import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;

private class Uniform
{
	public var id:Int;
	public var value:Float;

	public function new(id, value)
	{
		this.id = id;
		this.value = value;
	}
}

/**
 * Fullscreen post processing class.
 * Uses GLSL shaders to produce post processing effects.
 */
class PostProcess extends OpenGLView
{
	var screenWidth:Int;
	var screenHeight:Int;

	/**
	 * Create a new PostProcess object
	 *
	 * @param  fragmentShader  A GLSL file in your assets path
	 */
	public function new(fragmentShader:String)
	{
		super();
		uniforms = new Map<String, Uniform>();

		// create and bind the framebuffer
		framebuffer = GL.createFramebuffer();
		rebuild();
		#if (ios || tvos)
		defaultFramebuffer = new GLFramebuffer(GL.version, 1); // faked framebuffer
		#else
		var status = GL.checkFramebufferStatus(GL.FRAMEBUFFER);

		switch (status)
		{
			case GL.FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
				trace("FRAMEBUFFER_INCOMPLETE_ATTACHMENT");
			case GL.FRAMEBUFFER_UNSUPPORTED:
				trace("GL_FRAMEBUFFER_UNSUPPORTED");
			case GL.FRAMEBUFFER_COMPLETE:
			default:
				trace("Check frame buffer: " + status);
		}
		#end

		buffer = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
		GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(#if !openfl_next cast #end vertices), GL.STATIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);

		postProcessShader = new Shader([
			{src: VERTEX_SHADER, fragment: false},
			{src: Assets.getText(fragmentShader), fragment: true}
		]);

		// default shader variables
		imageUniform = postProcessShader.uniform("uImage0");
		timeUniform = postProcessShader.uniform("uTime");
		resolutionUniform = postProcessShader.uniform("uResolution");

		vertexSlot = postProcessShader.attribute("aVertex");
		texCoordSlot = postProcessShader.attribute("aTexCoord");
	}

	/**
	 * Set a uniform value in the shader
	 *
	 * @param   uniform   The uniform name within the shader source
	 * @param   value     Value to set the uniform to
	 */
	public function setUniform(uniform:String, value:Float):Void
	{
		if (uniforms.exists(uniform))
		{
			var uniform = uniforms.get(uniform);
			uniform.value = value;
		}
		else
		{
			var id:Int = postProcessShader.uniform(uniform);
			if (id != -1)
			{
				uniforms.set(uniform, new Uniform(id, value));
			}
			else
			{
				throw 'Uniform with name "$uniform" could not be found.';
			}
		}
	}

	/**
	 * Allows multi pass rendering by passing the framebuffer to another post processing class.
	 * Renders to a `PostProcess` framebuffer instead of the screen, if set.
	 * Set to `null` to render to the screen.
	 */
	public var to(never, set):PostProcess;

	function set_to(value:PostProcess):PostProcess
	{
		renderTo = (value == null ? defaultFramebuffer : value.framebuffer);
		return value;
	}

	/**
	 * Rebuilds the renderbuffer to match screen dimensions.
	 */
	public function rebuild()
	{
		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);

		if (texture != null)
			GL.deleteTexture(texture);
		if (renderbuffer != null)
			GL.deleteRenderbuffer(renderbuffer);

		this.screenWidth = FlxG.stage.stageWidth;
		this.screenHeight = FlxG.stage.stageHeight;
		createTexture(screenWidth, screenHeight);
		createRenderbuffer(screenWidth, screenHeight);

		GL.bindFramebuffer(GL.FRAMEBUFFER, null);
	}

	inline function createRenderbuffer(width:Int, height:Int)
	{
		// Bind the renderbuffer and create a depth buffer
		renderbuffer = GL.createRenderbuffer();

		GL.bindRenderbuffer(GL.RENDERBUFFER, renderbuffer);
		GL.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_COMPONENT16, width, height);

		// Specify renderbuffer as depth attachment
		GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, renderbuffer);
	}

	inline function createTexture(width:Int, height:Int)
	{
		texture = GL.createTexture();

		GL.bindTexture(GL.TEXTURE_2D, texture);
		GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGB, width, height, 0, GL.RGB, GL.UNSIGNED_BYTE, null);

		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);

		// specify texture as color attachment
		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);
	}

	/**
	 * Capture what is subsequently rendered to this framebuffer.
	 */
	public function capture()
	{
		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
		GL.clear(GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);
	}

	public function update(elapsed:Float)
	{
		time += elapsed;
	}

	#if openfl_legacy
	/**
	 * Renders to a framebuffer or the screen every frame.
	 */
	override public function render(rect:Rectangle)
	{
		GL.bindFramebuffer(GL.FRAMEBUFFER, renderTo);
		GL.viewport(0, 0, screenWidth, screenHeight);

		postProcessShader.bind();

		GL.enableVertexAttribArray(vertexSlot);
		GL.enableVertexAttribArray(texCoordSlot);

		GL.activeTexture(GL.TEXTURE0);
		GL.bindTexture(GL.TEXTURE_2D, texture);
		GL.enable(GL.TEXTURE_2D);

		GL.bindBuffer(GL.ARRAY_BUFFER, buffer);
		GL.vertexAttribPointer(vertexSlot, 2, GL.FLOAT, false, 16, 0);
		GL.vertexAttribPointer(texCoordSlot, 2, GL.FLOAT, false, 16, 8);

		GL.uniform1i(imageUniform, 0);
		GL.uniform1f(timeUniform, time);
		GL.uniform2f(resolutionUniform, screenWidth, screenHeight);

		for (u in uniforms)
		{
			GL.uniform1f(u.id, u.value);
		}

		GL.drawArrays(GL.TRIANGLES, 0, 6);

		GL.bindBuffer(GL.ARRAY_BUFFER, null);
		GL.disable(GL.TEXTURE_2D);
		GL.bindTexture(GL.TEXTURE_2D, null);

		GL.disableVertexAttribArray(vertexSlot);
		GL.disableVertexAttribArray(texCoordSlot);

		GL.useProgram(null);

		GL.bindFramebuffer(GL.FRAMEBUFFER, null);

		// check gl error
		if (GL.getError() == GL.INVALID_FRAMEBUFFER_OPERATION)
		{
			trace("INVALID_FRAMEBUFFER_OPERATION!!");
		}
	}
	#end

	var framebuffer:GLFramebuffer;
	var renderbuffer:GLRenderbuffer;
	var texture:GLTexture;

	var postProcessShader:Shader;
	var buffer:GLBuffer;
	var renderTo:GLFramebuffer;
	var defaultFramebuffer:GLFramebuffer = null;

	/* @Time accumulator passed to the shader */
	var time:Float = 0;

	var vertexSlot:Int;
	var texCoordSlot:Int;
	var imageUniform:Int;
	var resolutionUniform:Int;
	var timeUniform:Int;
	var uniforms:Map<String, Uniform>;

	/* @Simple full screen vertex shader */
	static inline var VERTEX_SHADER:String = "
#ifdef GL_ES
	precision mediump float;
#endif

attribute vec2 aVertex;
attribute vec2 aTexCoord;
varying vec2 vTexCoord;

void main() {
	vTexCoord = aTexCoord;
	gl_Position = vec4(aVertex, 0.0, 1.0);
}";

	static var vertices(get, never):Array<Float>;

	static inline function get_vertices():Array<Float>
	{
		return [
			-1.0, -1.0, 0, 0,
			 1.0, -1.0, 1, 0,
			-1.0,  1.0, 0, 1,
			 1.0, -1.0, 1, 0,
			 1.0,  1.0, 1, 1,
			-1.0,  1.0, 0, 1
		];
	}
}
#else
class PostProcess
{
	public function new(shader:String)
	{
		FlxG.log.error("Post processing is only supported on the CPP and Neko targets of OpenFL legacy - for newer OpenFL versions, please use shader filters.");
	}

	public function enable(?to:PostProcess) {}

	public function capture() {}

	public function rebuild() {}

	public function update(elapsed:Float) {}

	public function render(rect:Rectangle) {}

	public function setUniform(uniform:String, value:Float) {}

	public var to(never, set):PostProcess;

	public function set_to(value:PostProcess):PostProcess
		return null;
}
#end
