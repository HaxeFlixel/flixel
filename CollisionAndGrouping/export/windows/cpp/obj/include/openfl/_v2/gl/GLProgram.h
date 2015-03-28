#ifndef INCLUDED_openfl__v2_gl_GLProgram
#define INCLUDED_openfl__v2_gl_GLProgram

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/gl/GLObject.h>
HX_DECLARE_CLASS3(openfl,_v2,gl,GLObject)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLProgram)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLShader)
namespace openfl{
namespace _v2{
namespace gl{


class HXCPP_CLASS_ATTRIBUTES  GLProgram_obj : public ::openfl::_v2::gl::GLObject_obj{
	public:
		typedef ::openfl::_v2::gl::GLObject_obj super;
		typedef GLProgram_obj OBJ_;
		GLProgram_obj();
		Void __construct(int version,Dynamic id);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< GLProgram_obj > __new(int version,Dynamic id);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~GLProgram_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		void __Visit(HX_VISIT_PARAMS);
		::String __ToString() const { return HX_CSTRING("GLProgram"); }

		Array< ::Dynamic > shaders;
		virtual Void attach( ::openfl::_v2::gl::GLShader shader);
		Dynamic attach_dyn();

		virtual Array< ::Dynamic > getShaders( );
		Dynamic getShaders_dyn();

		virtual ::String getType( );

};

} // end namespace openfl
} // end namespace _v2
} // end namespace gl

#endif /* INCLUDED_openfl__v2_gl_GLProgram */ 
