#ifndef INCLUDED_flixel_effects_postprocess_PostProcess
#define INCLUDED_flixel_effects_postprocess_PostProcess

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/display/OpenGLView.h>
HX_DECLARE_CLASS0(IMap)
HX_DECLARE_CLASS3(flixel,effects,postprocess,PostProcess)
HX_DECLARE_CLASS3(flixel,effects,postprocess,Shader)
HX_DECLARE_CLASS2(haxe,ds,StringMap)
HX_DECLARE_CLASS3(openfl,_v2,display,DirectRenderer)
HX_DECLARE_CLASS3(openfl,_v2,display,DisplayObject)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,display,OpenGLView)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,geom,Rectangle)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLBuffer)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLFramebuffer)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLObject)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLRenderbuffer)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLTexture)
namespace flixel{
namespace effects{
namespace postprocess{


class HXCPP_CLASS_ATTRIBUTES  PostProcess_obj : public ::openfl::_v2::display::OpenGLView_obj{
	public:
		typedef ::openfl::_v2::display::OpenGLView_obj super;
		typedef PostProcess_obj OBJ_;
		PostProcess_obj();
		Void __construct(::String fragmentShader);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< PostProcess_obj > __new(::String fragmentShader);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~PostProcess_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("PostProcess"); }

		int screenWidth;
		int screenHeight;
		virtual Void setUniform( ::String uniform,Float value);
		Dynamic setUniform_dyn();

		virtual ::flixel::effects::postprocess::PostProcess set_to( ::flixel::effects::postprocess::PostProcess value);
		Dynamic set_to_dyn();

		virtual Void rebuild( );
		Dynamic rebuild_dyn();

		virtual Void createRenderbuffer( int width,int height);
		Dynamic createRenderbuffer_dyn();

		virtual Void createTexture( int width,int height);
		Dynamic createTexture_dyn();

		virtual Void capture( );
		Dynamic capture_dyn();

		virtual Void update( Float elapsed);
		Dynamic update_dyn();

		
		::openfl::_v2::gl::GLFramebuffer framebuffer;
		::openfl::_v2::gl::GLRenderbuffer renderbuffer;
		::openfl::_v2::gl::GLTexture texture;
		::flixel::effects::postprocess::Shader shader;
		::openfl::_v2::gl::GLBuffer buffer;
		::openfl::_v2::gl::GLFramebuffer renderTo;
		::openfl::_v2::gl::GLFramebuffer defaultFramebuffer;
		Float time;
		int vertexSlot;
		int texCoordSlot;
		int imageUniform;
		int resolutionUniform;
		int timeUniform;
		::haxe::ds::StringMap uniforms;
		static ::String vertexShader;
		static Array< Float > get_vertices( );
		static Dynamic get_vertices_dyn();

};

} // end namespace flixel
} // end namespace effects
} // end namespace postprocess

#endif /* INCLUDED_flixel_effects_postprocess_PostProcess */ 
