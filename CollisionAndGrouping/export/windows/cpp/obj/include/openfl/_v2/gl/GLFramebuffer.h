#ifndef INCLUDED_openfl__v2_gl_GLFramebuffer
#define INCLUDED_openfl__v2_gl_GLFramebuffer

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/_v2/gl/GLObject.h>
HX_DECLARE_CLASS3(openfl,_v2,gl,GLFramebuffer)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLObject)
namespace openfl{
namespace _v2{
namespace gl{


class HXCPP_CLASS_ATTRIBUTES  GLFramebuffer_obj : public ::openfl::_v2::gl::GLObject_obj{
	public:
		typedef ::openfl::_v2::gl::GLObject_obj super;
		typedef GLFramebuffer_obj OBJ_;
		GLFramebuffer_obj();
		Void __construct(int version,Dynamic id);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< GLFramebuffer_obj > __new(int version,Dynamic id);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~GLFramebuffer_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("GLFramebuffer"); }

		virtual ::String getType( );

};

} // end namespace openfl
} // end namespace _v2
} // end namespace gl

#endif /* INCLUDED_openfl__v2_gl_GLFramebuffer */ 
