#ifndef INCLUDED_openfl_display3D_textures_RectangleTexture
#define INCLUDED_openfl_display3D_textures_RectangleTexture

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <openfl/display3D/textures/TextureBase.h>
HX_DECLARE_CLASS2(haxe,io,Bytes)
HX_DECLARE_CLASS3(openfl,_v2,display,BitmapData)
HX_DECLARE_CLASS3(openfl,_v2,display,IBitmapDrawable)
HX_DECLARE_CLASS3(openfl,_v2,events,EventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,events,IEventDispatcher)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLObject)
HX_DECLARE_CLASS3(openfl,_v2,gl,GLTexture)
HX_DECLARE_CLASS3(openfl,_v2,utils,ByteArray)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataInput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IDataOutput)
HX_DECLARE_CLASS3(openfl,_v2,utils,IMemoryRange)
HX_DECLARE_CLASS3(openfl,display3D,textures,RectangleTexture)
HX_DECLARE_CLASS3(openfl,display3D,textures,TextureBase)
namespace openfl{
namespace display3D{
namespace textures{


class HXCPP_CLASS_ATTRIBUTES  RectangleTexture_obj : public ::openfl::display3D::textures::TextureBase_obj{
	public:
		typedef ::openfl::display3D::textures::TextureBase_obj super;
		typedef RectangleTexture_obj OBJ_;
		RectangleTexture_obj();
		Void __construct(::openfl::_v2::gl::GLTexture glTexture,bool optimize,int width,int height);

	public:
		inline void *operator new( size_t inSize, bool inContainer=true)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< RectangleTexture_obj > __new(::openfl::_v2::gl::GLTexture glTexture,bool optimize,int width,int height);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~RectangleTexture_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("RectangleTexture"); }

		bool optimizeForRenderToTexture;
		virtual Void uploadFromBitmapData( ::openfl::_v2::display::BitmapData bitmapData,hx::Null< int >  miplevel);
		Dynamic uploadFromBitmapData_dyn();

		virtual Void uploadFromByteArray( ::openfl::_v2::utils::ByteArray data,int byteArrayOffset);
		Dynamic uploadFromByteArray_dyn();

};

} // end namespace openfl
} // end namespace display3D
} // end namespace textures

#endif /* INCLUDED_openfl_display3D_textures_RectangleTexture */ 
