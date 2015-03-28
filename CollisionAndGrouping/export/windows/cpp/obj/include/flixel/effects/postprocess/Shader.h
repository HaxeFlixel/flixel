#ifndef INCLUDED_flixel_effects_postprocess_Shader
#define INCLUDED_flixel_effects_postprocess_Shader

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,effects,postprocess,Shader)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLObject)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLProgram)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLShader)
namespace flixel{
namespace effects{
namespace postprocess{


class HXCPP_CLASS_ATTRIBUTES  Shader_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Shader_obj OBJ_;
		Shader_obj();
		Void __construct(Dynamic sources);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< Shader_obj > __new(Dynamic sources);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~Shader_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("Shader"); }

		::openfl::_v2::gl::GLProgram program;
		virtual ::openfl::_v2::gl::GLShader compile( ::String source,int type);
		Dynamic compile_dyn();

		virtual int attribute( ::String a);
		Dynamic attribute_dyn();

		virtual int uniform( ::String u);
		Dynamic uniform_dyn();

		virtual Void bind( );
		Dynamic bind_dyn();

};

} // end namespace flixel
} // end namespace effects
} // end namespace postprocess

#endif /* INCLUDED_flixel_effects_postprocess_Shader */ 
