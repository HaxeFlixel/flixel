#ifndef INCLUDED_flixel_system_debug_FlxButtonAlignment
#define INCLUDED_flixel_system_debug_FlxButtonAlignment

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,system,debug,FlxButtonAlignment)
namespace flixel{
namespace system{
namespace debug{


class FlxButtonAlignment_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef FlxButtonAlignment_obj OBJ_;

	public:
		FlxButtonAlignment_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("flixel.system.debug.FlxButtonAlignment"); }
		::String __ToString() const { return HX_CSTRING("FlxButtonAlignment.") + tag; }

		static ::flixel::system::debug::FlxButtonAlignment LEFT;
		static inline ::flixel::system::debug::FlxButtonAlignment LEFT_dyn() { return LEFT; }
		static ::flixel::system::debug::FlxButtonAlignment MIDDLE;
		static inline ::flixel::system::debug::FlxButtonAlignment MIDDLE_dyn() { return MIDDLE; }
		static ::flixel::system::debug::FlxButtonAlignment RIGHT;
		static inline ::flixel::system::debug::FlxButtonAlignment RIGHT_dyn() { return RIGHT; }
};

} // end namespace flixel
} // end namespace system
} // end namespace debug

#endif /* INCLUDED_flixel_system_debug_FlxButtonAlignment */ 
