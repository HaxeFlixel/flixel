#ifndef INCLUDED_flixel_system_debug_FlxDebuggerLayout
#define INCLUDED_flixel_system_debug_FlxDebuggerLayout

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

HX_DECLARE_CLASS3(flixel,system,debug,FlxDebuggerLayout)
namespace flixel{
namespace system{
namespace debug{


class FlxDebuggerLayout_obj : public hx::EnumBase_obj
{
	typedef hx::EnumBase_obj super;
		typedef FlxDebuggerLayout_obj OBJ_;

	public:
		FlxDebuggerLayout_obj() {};
		HX_DO_ENUM_RTTI;
		static void __boot();
		static void __register();
		::String GetEnumName( ) const { return HX_CSTRING("flixel.system.debug.FlxDebuggerLayout"); }
		::String __ToString() const { return HX_CSTRING("FlxDebuggerLayout.") + tag; }

		static ::flixel::system::debug::FlxDebuggerLayout BIG;
		static inline ::flixel::system::debug::FlxDebuggerLayout BIG_dyn() { return BIG; }
		static ::flixel::system::debug::FlxDebuggerLayout LEFT;
		static inline ::flixel::system::debug::FlxDebuggerLayout LEFT_dyn() { return LEFT; }
		static ::flixel::system::debug::FlxDebuggerLayout MICRO;
		static inline ::flixel::system::debug::FlxDebuggerLayout MICRO_dyn() { return MICRO; }
		static ::flixel::system::debug::FlxDebuggerLayout RIGHT;
		static inline ::flixel::system::debug::FlxDebuggerLayout RIGHT_dyn() { return RIGHT; }
		static ::flixel::system::debug::FlxDebuggerLayout STANDARD;
		static inline ::flixel::system::debug::FlxDebuggerLayout STANDARD_dyn() { return STANDARD; }
		static ::flixel::system::debug::FlxDebuggerLayout TOP;
		static inline ::flixel::system::debug::FlxDebuggerLayout TOP_dyn() { return TOP; }
};

} // end namespace flixel
} // end namespace system
} // end namespace debug

#endif /* INCLUDED_flixel_system_debug_FlxDebuggerLayout */ 
