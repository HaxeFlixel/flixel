#ifndef INCLUDED_openfl_display3D_Context3D
#define INCLUDED_openfl_display3D_Context3D

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS2(haxe,io,Bytes)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,DirectRenderer)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,OpenGLView)
HX_DECLARE_CLASS3(openfl,_v2,events,Event)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,geom,Rectangle)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLFramebuffer)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLObject)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLRenderbuffer)
HX_DECLARE_CLASS3(openfl,_v2,utils,ByteArray)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataInput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataOutput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IMemoryRange)
HX_DECLARE_CLASS2(openfl,display3D,Context3D)
HX_DECLARE_CLASS2(openfl,display3D,Context3DMipFilter)
HX_DECLARE_CLASS2(openfl,display3D,Context3DProgramType)
HX_DECLARE_CLASS2(openfl,display3D,Context3DTextureFilter)
HX_DECLARE_CLASS2(openfl,display3D,Context3DTextureFormat)
HX_DECLARE_CLASS2(openfl,display3D,Context3DVertexBufferFormat)
HX_DECLARE_CLASS2(openfl,display3D,Context3DWrapMode)
HX_DECLARE_CLASS2(openfl,display3D,IndexBuffer3D)
HX_DECLARE_CLASS2(openfl,display3D,Program3D)
HX_DECLARE_CLASS2(openfl,display3D,VertexBuffer3D)
HX_DECLARE_CLASS3(openfl,display3D,_Context3D,SamplerState)
HX_DECLARE_CLASS3(openfl,display3D,textures,CubeTexture)
HX_DECLARE_CLASS3(openfl,display3D,textures,RectangleTexture)
HX_DECLARE_CLASS3(openfl,display3D,textures,Texture)
HX_DECLARE_CLASS3(openfl,display3D,textures,TextureBase)
HX_DECLARE_CLASS2(openfl,geom,Matrix3D)
namespace openfl{
namespace display3D{


class HXCPP_CLASS_ATTRIBUTES  Context3D_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Context3D_obj OBJ_;
		Context3D_obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Context3D_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Context3D_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Context3D"); }

		::String driverInfo;
		bool enableErrorChecking;
		int blendDestinationFactor;
		bool blendEnabled;
		int blendSourceFactor;
		::openfl::display3D::Program3D currentProgram;
		bool disposed;
		bool drawing;
		::openfl::_v2::gl::GLFramebuffer framebuffer;
		Array< ::Dynamic > indexBuffersCreated;
		::openfl::_v2::display::OpenGLView ogl;
		Array< ::Dynamic > programsCreated;
		::openfl::_v2::gl::GLRenderbuffer renderbuffer;
		Array< ::Dynamic > samplerParameters;
		::openfl::_v2::geom::Rectangle scrollRect;
		::openfl::_v2::gl::GLRenderbuffer stencilbuffer;
		int stencilCompareMode;
		int stencilRef;
		int stencilReadMask;
		Array< ::Dynamic > texturesCreated;
		Array< ::Dynamic > vertexBuffersCreated;
		Float _yFlip;
		virtual Void clear( hx::Null< Float >  red,hx::Null< Float >  green,hx::Null< Float >  blue,hx::Null< Float >  alpha,hx::Null< Float >  depth,hx::Null< int >  stencil,hx::Null< int >  mask);
		Dynamic clear_dyn();

		virtual Void configureBackBuffer( int width,int height,int antiAlias,hx::Null< bool >  enableDepthAndStencil);
		Dynamic configureBackBuffer_dyn();

		virtual ::openfl::display3D::textures::CubeTexture createCubeTexture( int size,::openfl::display3D::Context3DTextureFormat format,bool optimizeForRenderToTexture,hx::Null< int >  streamingLevels);
		Dynamic createCubeTexture_dyn();

		virtual ::openfl::display3D::IndexBuffer3D createIndexBuffer( int numIndices);
		Dynamic createIndexBuffer_dyn();

		virtual ::openfl::display3D::Program3D createProgram( );
		Dynamic createProgram_dyn();

		virtual ::openfl::display3D::textures::RectangleTexture createRectangleTexture( int width,int height,::openfl::display3D::Context3DTextureFormat format,bool optimizeForRenderToTexture);
		Dynamic createRectangleTexture_dyn();

		virtual ::openfl::display3D::textures::Texture createTexture( int width,int height,::openfl::display3D::Context3DTextureFormat format,bool optimizeForRenderToTexture,hx::Null< int >  streamingLevels);
		Dynamic createTexture_dyn();

		virtual ::openfl::display3D::VertexBuffer3D createVertexBuffer( int numVertices,int data32PerVertex);
		Dynamic createVertexBuffer_dyn();

		virtual Void dispose( );
		Dynamic dispose_dyn();

		virtual Void drawToBitmapData( ::openfl::_v2::display::BitmapData destination);
		Dynamic drawToBitmapData_dyn();

		virtual Void drawTriangles( ::openfl::display3D::IndexBuffer3D indexBuffer,hx::Null< int >  firstIndex,hx::Null< int >  numTriangles);
		Dynamic drawTriangles_dyn();

		virtual Void present( );
		Dynamic present_dyn();

		virtual Void removeRenderMethod( Dynamic func);
		Dynamic removeRenderMethod_dyn();

		virtual Void setBlendFactors( int sourceFactor,int destinationFactor);
		Dynamic setBlendFactors_dyn();

		virtual Void setColorMask( bool red,bool green,bool blue,bool alpha);
		Dynamic setColorMask_dyn();

		virtual Void setCulling( int triangleFaceToCull);
		Dynamic setCulling_dyn();

		virtual Void setDepthTest( bool depthMask,int passCompareMode);
		Dynamic setDepthTest_dyn();

		virtual Void setGLSLProgramConstantsFromByteArray( ::String locationName,::openfl::_v2::utils::ByteArray data,hx::Null< int >  byteArrayOffset);
		Dynamic setGLSLProgramConstantsFromByteArray_dyn();

		virtual Void setGLSLProgramConstantsFromMatrix( ::String locationName,::openfl::geom::Matrix3D matrix,hx::Null< bool >  transposedMatrix);
		Dynamic setGLSLProgramConstantsFromMatrix_dyn();

		virtual Void setGLSLProgramConstantsFromVector4( ::String locationName,Array< Float > data,hx::Null< int >  startIndex);
		Dynamic setGLSLProgramConstantsFromVector4_dyn();

		virtual Void setGLSLTextureAt( ::String locationName,::openfl::display3D::textures::TextureBase texture,int textureIndex);
		Dynamic setGLSLTextureAt_dyn();

		virtual Void setGLSLVertexBufferAt( ::String locationName,::openfl::display3D::VertexBuffer3D buffer,hx::Null< int >  bufferOffset,::openfl::display3D::Context3DVertexBufferFormat format);
		Dynamic setGLSLVertexBufferAt_dyn();

		virtual Void setProgram( ::openfl::display3D::Program3D program3D);
		Dynamic setProgram_dyn();

		virtual Void setProgramConstantsFromByteArray( ::openfl::display3D::Context3DProgramType programType,int firstRegister,int numRegisters,::openfl::_v2::utils::ByteArray data,int byteArrayOffset);
		Dynamic setProgramConstantsFromByteArray_dyn();

		virtual Void setProgramConstantsFromMatrix( ::openfl::display3D::Context3DProgramType programType,int firstRegister,::openfl::geom::Matrix3D matrix,hx::Null< bool >  transposedMatrix);
		Dynamic setProgramConstantsFromMatrix_dyn();

		virtual Void setProgramConstantsFromVector( ::openfl::display3D::Context3DProgramType programType,int firstRegister,Array< Float > data,hx::Null< int >  numRegisters);
		Dynamic setProgramConstantsFromVector_dyn();

		virtual Void setRenderMethod( Dynamic func);
		Dynamic setRenderMethod_dyn();

		virtual Void setRenderToBackBuffer( );
		Dynamic setRenderToBackBuffer_dyn();

		virtual Void setRenderToTexture( ::openfl::display3D::textures::TextureBase texture,hx::Null< bool >  enableDepthAndStencil,hx::Null< int >  antiAlias,hx::Null< int >  surfaceSelector);
		Dynamic setRenderToTexture_dyn();

		virtual Void setSamplerStateAt( int sampler,::openfl::display3D::Context3DWrapMode wrap,::openfl::display3D::Context3DTextureFilter filter,::openfl::display3D::Context3DMipFilter mipfilter);
		Dynamic setSamplerStateAt_dyn();

		virtual Void setScissorRectangle( ::openfl::_v2::geom::Rectangle rectangle);
		Dynamic setScissorRectangle_dyn();

		virtual Void setStencilActions( Dynamic triangleFace,Dynamic compareMode,Dynamic actionOnBothPass,Dynamic actionOnDepthFail,Dynamic actionOnDepthPassStencilFail);
		Dynamic setStencilActions_dyn();

		virtual Void setStencilReferenceValue( int referenceValue,hx::Null< int >  readMask,hx::Null< int >  writeMask);
		Dynamic setStencilReferenceValue_dyn();

		virtual Void setTextureAt( int sampler,::openfl::display3D::textures::TextureBase texture);
		Dynamic setTextureAt_dyn();

		virtual Void setTextureParameters( ::openfl::display3D::textures::TextureBase texture,::openfl::display3D::Context3DWrapMode wrap,::openfl::display3D::Context3DTextureFilter filter,::openfl::display3D::Context3DMipFilter mipfilter);
		Dynamic setTextureParameters_dyn();

		virtual Void setVertexBufferAt( int index,::openfl::display3D::VertexBuffer3D buffer,hx::Null< int >  bufferOffset,::openfl::display3D::Context3DVertexBufferFormat format);
		Dynamic setVertexBufferAt_dyn();

		virtual ::String __getUniformLocationNameFromAgalRegisterIndex( ::openfl::display3D::Context3DProgramType programType,int firstRegister);
		Dynamic __getUniformLocationNameFromAgalRegisterIndex_dyn();

		virtual Void __updateBlendStatus( );
		Dynamic __updateBlendStatus_dyn();

		static int TEXTURE_MAX_ANISOTROPY_EXT;
		static int MAX_SAMPLERS;
		static int MAX_TEXTURE_MAX_ANISOTROPY_EXT;
		static bool anisotropySupportTested;
		static bool supportsAnisotropy;
		static int maxSupportedAnisotropy;
};

} // end namespace openfl
} // end namespace display3D

#endif /* INCLUDED_openfl_display3D_Context3D */ 
