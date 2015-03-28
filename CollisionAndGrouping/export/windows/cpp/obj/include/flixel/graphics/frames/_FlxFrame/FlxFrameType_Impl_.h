#ifndef INCLUDED_flixel_graphics_frames__FlxFrame_FlxFrameType_Impl_
#define INCLUDED_flixel_graphics_frames__FlxFrame_FlxFrameType_Impl_

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS4(flixel,graphics,frames,_FlxFrame,FlxFrameType_Impl_)
namespace flixel{
namespace graphics{
namespace frames{
namespace _FlxFrame{


class HXCPP_CLASS_ATTRIBUTES  FlxFrameType_Impl__obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef FlxFrameType_Impl__obj OBJ_;
		FlxFrameType_Impl__obj();
		Void __construct();

	public:
		inline void *operator new( size_t inSize, bool inContainer=false)
			{ return hx::Object::operator new(inSize,inContainer); }
		static hx::ObjectPtr< FlxFrameType_Impl__obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		//~FlxFrameType_Impl__obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		::String __ToString() const { return HX_CSTRING("FlxFrameType_Impl_"); }

		static int REGULAR;
		static int ROTATED;
		static int EMPTY;
		static int GLYPH;
		static int FILTER;
};

} // end namespace flixel
} // end namespace graphics
} // end namespace frames
} // end namespace _FlxFrame

#endif /* INCLUDED_flixel_graphics_frames__FlxFrame_FlxFrameType_Impl_ */ 
