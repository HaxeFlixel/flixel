#ifndef INCLUDED_openfl__v2_system_PixelFormat
#define INCLUDED_openfl__v2_system_PixelFormat

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(openfl,_v2,system,PixelFormat)
namespace openfl{
namespace _v2{
namespace system{


class PixelFormat_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef PixelFormat_obj OBJ_;

	public:
		PixelFormat_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("openfl._v2.system.PixelFormat"); }
		::String __ToString() const { return HX_CSTRING("PixelFormat.") + tag; }

		static ::openfl::_v2::system::PixelFormat ABGR1555;
		static inline ::openfl::_v2::system::PixelFormat ABGR1555_dyn() { return ABGR1555; }
		static ::openfl::_v2::system::PixelFormat ABGR4444;
		static inline ::openfl::_v2::system::PixelFormat ABGR4444_dyn() { return ABGR4444; }
		static ::openfl::_v2::system::PixelFormat ABGR8888;
		static inline ::openfl::_v2::system::PixelFormat ABGR8888_dyn() { return ABGR8888; }
		static ::openfl::_v2::system::PixelFormat ARGB1555;
		static inline ::openfl::_v2::system::PixelFormat ARGB1555_dyn() { return ARGB1555; }
		static ::openfl::_v2::system::PixelFormat ARGB2101010;
		static inline ::openfl::_v2::system::PixelFormat ARGB2101010_dyn() { return ARGB2101010; }
		static ::openfl::_v2::system::PixelFormat ARGB4444;
		static inline ::openfl::_v2::system::PixelFormat ARGB4444_dyn() { return ARGB4444; }
		static ::openfl::_v2::system::PixelFormat ARGB8888;
		static inline ::openfl::_v2::system::PixelFormat ARGB8888_dyn() { return ARGB8888; }
		static ::openfl::_v2::system::PixelFormat BGR24;
		static inline ::openfl::_v2::system::PixelFormat BGR24_dyn() { return BGR24; }
		static ::openfl::_v2::system::PixelFormat BGR555;
		static inline ::openfl::_v2::system::PixelFormat BGR555_dyn() { return BGR555; }
		static ::openfl::_v2::system::PixelFormat BGR565;
		static inline ::openfl::_v2::system::PixelFormat BGR565_dyn() { return BGR565; }
		static ::openfl::_v2::system::PixelFormat BGR888;
		static inline ::openfl::_v2::system::PixelFormat BGR888_dyn() { return BGR888; }
		static ::openfl::_v2::system::PixelFormat BGRA4444;
		static inline ::openfl::_v2::system::PixelFormat BGRA4444_dyn() { return BGRA4444; }
		static ::openfl::_v2::system::PixelFormat BGRA5551;
		static inline ::openfl::_v2::system::PixelFormat BGRA5551_dyn() { return BGRA5551; }
		static ::openfl::_v2::system::PixelFormat BGRA8888;
		static inline ::openfl::_v2::system::PixelFormat BGRA8888_dyn() { return BGRA8888; }
		static ::openfl::_v2::system::PixelFormat BGRX8888;
		static inline ::openfl::_v2::system::PixelFormat BGRX8888_dyn() { return BGRX8888; }
		static ::openfl::_v2::system::PixelFormat INDEX1LSB;
		static inline ::openfl::_v2::system::PixelFormat INDEX1LSB_dyn() { return INDEX1LSB; }
		static ::openfl::_v2::system::PixelFormat INDEX1MSB;
		static inline ::openfl::_v2::system::PixelFormat INDEX1MSB_dyn() { return INDEX1MSB; }
		static ::openfl::_v2::system::PixelFormat INDEX4LSB;
		static inline ::openfl::_v2::system::PixelFormat INDEX4LSB_dyn() { return INDEX4LSB; }
		static ::openfl::_v2::system::PixelFormat INDEX4MSB;
		static inline ::openfl::_v2::system::PixelFormat INDEX4MSB_dyn() { return INDEX4MSB; }
		static ::openfl::_v2::system::PixelFormat INDEX8;
		static inline ::openfl::_v2::system::PixelFormat INDEX8_dyn() { return INDEX8; }
		static ::openfl::_v2::system::PixelFormat IYUV;
		static inline ::openfl::_v2::system::PixelFormat IYUV_dyn() { return IYUV; }
		static ::openfl::_v2::system::PixelFormat RGB24;
		static inline ::openfl::_v2::system::PixelFormat RGB24_dyn() { return RGB24; }
		static ::openfl::_v2::system::PixelFormat RGB332;
		static inline ::openfl::_v2::system::PixelFormat RGB332_dyn() { return RGB332; }
		static ::openfl::_v2::system::PixelFormat RGB444;
		static inline ::openfl::_v2::system::PixelFormat RGB444_dyn() { return RGB444; }
		static ::openfl::_v2::system::PixelFormat RGB555;
		static inline ::openfl::_v2::system::PixelFormat RGB555_dyn() { return RGB555; }
		static ::openfl::_v2::system::PixelFormat RGB565;
		static inline ::openfl::_v2::system::PixelFormat RGB565_dyn() { return RGB565; }
		static ::openfl::_v2::system::PixelFormat RGB888;
		static inline ::openfl::_v2::system::PixelFormat RGB888_dyn() { return RGB888; }
		static ::openfl::_v2::system::PixelFormat RGBA4444;
		static inline ::openfl::_v2::system::PixelFormat RGBA4444_dyn() { return RGBA4444; }
		static ::openfl::_v2::system::PixelFormat RGBA5551;
		static inline ::openfl::_v2::system::PixelFormat RGBA5551_dyn() { return RGBA5551; }
		static ::openfl::_v2::system::PixelFormat RGBA8888;
		static inline ::openfl::_v2::system::PixelFormat RGBA8888_dyn() { return RGBA8888; }
		static ::openfl::_v2::system::PixelFormat RGBX8888;
		static inline ::openfl::_v2::system::PixelFormat RGBX8888_dyn() { return RGBX8888; }
		static ::openfl::_v2::system::PixelFormat UNKNOWN;
		static inline ::openfl::_v2::system::PixelFormat UNKNOWN_dyn() { return UNKNOWN; }
		static ::openfl::_v2::system::PixelFormat UYVY;
		static inline ::openfl::_v2::system::PixelFormat UYVY_dyn() { return UYVY; }
		static ::openfl::_v2::system::PixelFormat YUY2;
		static inline ::openfl::_v2::system::PixelFormat YUY2_dyn() { return YUY2; }
		static ::openfl::_v2::system::PixelFormat YV12;
		static inline ::openfl::_v2::system::PixelFormat YV12_dyn() { return YV12; }
		static ::openfl::_v2::system::PixelFormat YVYU;
		static inline ::openfl::_v2::system::PixelFormat YVYU_dyn() { return YVYU; }
};

} // end namespace openfl
} // end namespace _v2
} // end namespace system

#endif /* INCLUDED_openfl__v2_system_PixelFormat */ 
